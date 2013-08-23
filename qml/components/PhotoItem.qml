import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

MouseArea {
    id: photoItem
    width: units.gu(8)
    height: units.gu(8)

    property real iconSize: units.gu(8)
    property alias source : image.source
    property bool editing: true

    UbuntuShape {
        height: iconSize
        width: iconSize

        MouseArea {
            id: closeItem
            objectName: "closeItem"
            width: units.gu(3)
            height: units.gu(3)

            visible: editing

            Image {
                width: parent.width
                height: parent.height
                source: image("close_badge.png")
            }
            onClicked: {
                photoItem.destroy()
            }
        }

        image: Image {
            id: image
            source: ""
            fillMode: Image.PreserveAspectCrop
        }
    }

    onClicked: {
        // Nothing for now
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            width: mainView.width
            height: mainView.height
            Image {
                id: imageBig
                anchors.centerIn: parent
                source: photoItem.source
                fillMode: Image.Stretch
            }
        }
    }
}
