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
        var string = text
        var title = ""
        var length = string.length
        var pixel = 1 // The approximative size of each character
        var dif = mainView.width / (length*pixel) + units.gu(4) // -1 as it is for spacing

        for(var n = 0; n < string.length; n++) {
            if(dif < length && n >= dif)
                title = string.substring(0, dif-2) + "..."
            else
                title = string
        }
        page.title = title
    }

    visible: false

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
                    /*Grid {
                        columns: 1
                        Label {
                            text: provider
                            fontSize: "medium"
                            color: Theme.palette.normal.overlayText
                        }
                        Label {
                            text: displayName
                            fontSize: "small"
                            color: UbuntuColors.warmGrey
                        }
                    }*/
                    values: [ displayName ]
                    property real accountId: id
                    property string serviceName: provider
                    icon: {
                        return "/usr/share/icons/ubuntu-mobile/apps/144/" + iconName+ ".png"
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
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        Label {
            id: dateLabel
            objectName: "dateLabel"
            width: parent.width
            height: units.gu(3)
            color: UbuntuColors.orange
        }

        TextArea {
            id: memoryArea
            anchors.right: parent.right
            anchors.left: parent.left
            textFormat: TextEdit.RichText
            readOnly: !editing
            visible: (length > 0) && (text != "") || editing
        }

        Label {
            id: tags
            visible: (text != "") && !editing
        }

        Label {
            id: location
            visible: (text != "") && !editing
        }

        Label {
            id: weather
            //visible: (text != "") && !editing
            visible: false // for now
        }

        // Photos
        Grid {
            id: photoViewGrid
            objectName: "photoViewGrid"
            columns: (mainView.width - units.gu(4)) / units.gu(8) - 1
            spacing: 12
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
        location.text = memory.location
        weather.text = memory.weather
        // Clean photo views
        photoViewGrid.children = ""
        // Append photos
        var photo_list = memory.photos.split("||")
        for(var i = 0; i < photo_list.length; i++) {
            if(photo_list[i] == "")
                return
            var component = Qt.createComponent("./PhotoItem.qml")
            var params = {
                "source": photo_list[i],
                "editing": false
            }
            // Add to photoViewGrid...
            var shape = component.createObject(photoViewGrid, params)
            photoViewGrid.children.append += shape
        }
    }

}
