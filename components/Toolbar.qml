import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

ToolbarItems {

    ToolbarButton {
        text: i18n.tr("Cloud Sync")
        iconSource: Qt.resolvedUrl("../resources/images/cloud.png")

        //onTriggered: stack.push()

    }

    ToolbarButton {
        text: i18n.tr("New")
        iconSource: Qt.resolvedUrl("../resources/images/add.png")

        onTriggered: {
            stack.push(newMemory)
        }
    }

    locked: true
    opened: true
}
