import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: newMemoryPage
    title: i18n.tr("New Memory")
    visible: false

    // Some functions
    function clear() {
        title.text = ""
        description.text = ""
    }

    // Toolbar
    ToolbarItems {
        id: toolbar
        property int index: 0
        ToolbarButton {
            text: i18n.tr("Clear")
            iconSource: Qt.resolvedUrl("../resources/images/clear.png")

            onTriggered: {
                newMemoryPage.clear()
            }
        }

        ToolbarButton {
            text: i18n.tr("Save")
            iconSource: Qt.resolvedUrl("../resources/images/save.png")

            onTriggered: {
                var component = Qt.createComponent("Memory.qml")
                var memory = component.createObject(toolbar,
                                                {   "title": title.text,
                                                    "tags" : tags.text,
                                                    "description": description.text,
                                                    "date": date.text,
                                                    "loc": "",
                                                    "wt": "",
                                                    "count": model.count
                                                })
                model.append ({
                                  "mem": memory
                              })
                newMemoryPage.clear()
                stack.push(home);
            }
        }

        locked: true
        opened: true
    }

    // Page content
    Column {
        id: col
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        UbuntuShape {
            id: date
            width: 150
            height: 35

            property alias text : label.text


            Label {
                id: label
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
                color: UbuntuColors.orange
            }
        }

        TextField {
            id: title
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Title...")
        }

        TextField {
            id: tags
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Tags...")
            visible: false
        }

        TextArea {
            id: description
            placeholderText: "Memory"
            autoSize: true
            maximumLineCount: 5
            anchors.left: parent.left
            anchors.right: parent.right
        }

        ListItem.Standard {
            id: location
            text: i18n.tr("Location")
            control: Switch {}
        }

        ListItem.Standard {
            id: weather
            text: i18n.tr("Weather")
            control: Switch {}
        }

    }
    tools: toolbar

}
