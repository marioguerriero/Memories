import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

ToolbarItems {

    ToolbarButton {
        text: i18n.tr("New")
        iconSource: icon("add")

        onTriggered: {
            stack.push(newMemory)
        }
    }

    locked: false
    opened: false
}
