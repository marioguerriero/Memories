import QtQuick 2.0
import Ubuntu.Components 0.1

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
                model.append ({   "name":title.text,
                                  "desc": description.text,
                                  "dt": date.text,
                                  "loc": "", // FIXME
                                  "wt": "", // FIXME
                                  "count":model.count
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

        TextArea {
            id: description
            anchors.left: parent.left
            anchors.right: parent.right
        }

        CheckBox {
            id: location
            checked: false
            text: i18n.tr("Add your location")
        }

        CheckBox {
            id: weather
            checked: false
            text: i18n.tr("Add the weather conditions")
        }

    }
    tools: toolbar

}
