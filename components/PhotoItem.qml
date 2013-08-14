import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

MouseArea {
    id: area
    width: units.gu(8)
    height: units.gu(8)

    property alias source : image.source
    property bool editing: false

    UbuntuShape {
        objectName: "imageShape"

        MouseArea {
            id: closeItem
            width: units.gu(3)
            height: units.gu(3)

            visible: false

            Image {
                width: parent.width
                height: parent.height
                source: "../resources/images/close_badge.png"
            }
            onClicked: {
                print("Delete")
                area.destroy()
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
        //if(source != "")
        //    PopupUtils.open(dialog)
    }

    hoverEnabled: true
    onHoveredChanged: {
        if(!editing)
            return
        closeItem.visible = area.containsMouse
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
                source: area.source
                fillMode: Image.Stretch
            }
        }
    }
}
