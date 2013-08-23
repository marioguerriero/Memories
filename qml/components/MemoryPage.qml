import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0
import Ubuntu.OnlineAccounts 0.1
import Friends 0.1

Page {
    id: page
    title: ""   
    function setTitle(text) {
        if (text.length > parent.width / units.gu(2)) {
            text = text.substring(0, parent.width / units.gu(2.3));
            text += "...";
        }
        page.title = text
    }

    visible: false

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: tools
                locked: true
                opened: true
            }

            PropertyChanges {
                target: parent
                anchors.bottomMargin: units.gu(-2)
            }
        }

    ]

    property bool editing: false
    onParentNodeChanged: {
        editing = false
    }

    // Social network sharing utilities
    ListModel {
        id: accountsModel
    }

    FriendsDispatcher {
        id: friends
        onSendComplete: {
            if (success) {
                console.log ("Send completed successfully");
            } else {
                console.log ("Send failed: " + errorMessage.split("str: str:")[1]);
                // TODO: show some error dialog/widget
            }
        }
    }

    AccountServiceModel {
        id: accounts
        serviceType: "microblogging"
        Component.onCompleted: {
            for(var i=0; i<accounts.count; i++) {
                var displayName = accounts.get(i, "displayName");
                var accountId = accounts.get(i, "accountId");
                var serviceName = accounts.get(i, "serviceName");
                var features = friends.featuresForProtocol(serviceName.toLowerCase().replace(".",""));
                if(features.indexOf("send") > -1) {
                    console.log (serviceName + " Supports send");
                     /* FIXME: we should get the iconName and serviceName from the accountService
                     but I am not sure we can access that from JS */
                    accountsModel.append({
                        "displayName": displayName,
                        "id": accountId,
                        "provider": serviceName,
                        "iconName": serviceName.toLowerCase().replace(".",""),
                        "sendEnabled": true
                    });
                }
            }
        }
    }

    Component {
        id: popoverComponent

        Popover {
            id: popover

            Repeater {
                width: parent.width
                height: parent.height
                anchors.fill: parent
                model: accountsModel
                delegate: ListItem.MultiValue {
                    // HACK because of there is a bug with custom colors
                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            margins: units.gu(2)
                        }
                        text: provider
                        fontSize: "medium"
                        color: Theme.palette.normal.overlayText
                    }
                    values: [ displayName ]
                    property real accountId: id
                    property string serviceName: provider
                    icon: {
                        return "/usr/share/icons/ubuntu-mobile/apps/144/" + iconName + ".png"
                    }
                    onClicked: {
                        var share_string = page.memory.getShareString()
                        friends.sendForAccountAsync(accountId, share_string)
                    }
                }
            }
        }
    }

    tools: ToolbarItems {

        ToolbarButton {
            id: shareButton
            objectName: "shareButton"
            text: i18n.tr("Share")
            iconSource: icon("share")
            visible: accountsModel.count > 0

            onTriggered: {
                PopupUtils.open(popoverComponent, shareButton)
            }
        }

        ToolbarButton {
            text: i18n.tr("Edit")
            iconSource: icon("edit")

            onTriggered: {
                memoryEditPage.setMemory(memory)
                stack.push(memoryEditPage);
            }
        }

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")

            onTriggered: {
                onClicked: PopupUtils.open(dialog)
            }
        }

        locked: false
        opened: false
    }

    // Delete dialog
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: "Delete"
            text: "Are you sure you want to delete this memory?"
            Button {
                text: "Cancel"
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                text: "Delete"
                color: UbuntuColors.orange
                onClicked: {
                    PopupUtils.close(dialogue)
                    memory.remove()
                    stack.clear()
                    stack.push(homePage)
                }
            }
        }
    }

    // Page content
    Column {
        id: col
        spacing: units.gu(2)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        Label {
            id: dateLabel
            objectName: "dateLabel"
            color: UbuntuColors.orange
            fontSize: "large"
        }

        Label {
            id: locationLabel
            fontSize: "large"
            font.bold: true
        }

        Text {
            id: memoryArea
            anchors.right: parent.right
            anchors.left: parent.left
            width: parent.width
            wrapMode: Text.WordWrap
            color: "white"
            font.pointSize: units.gu(1.5)
        }

        ListItem.ThinDivider { }

        Label {
            text: i18n.tr("Tags")
            fontSize: "large"
            font.bold: true
        }

        Label {
            id: tags
            fontSize: "medium"
        }

        /*Label {
            id: weather
            //visible: (text != "") && !editing
            visible: false // for now
        }*/

        ListItem.ThinDivider { }

        // Photos
        PhotoLayout {
            id: photoLayout
            editable: false
            iconSize: units.gu(12)
        }
    }

    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        dateLabel.text = memory.date
        setTitle(memory.title)
        memoryArea.text = memory.description
        tags.text = memory.tags
        locationLabel.text = memory.location
        //weather.text = memory.weather
        photoLayout.photos = memory.getPhotoList()
    }

}
