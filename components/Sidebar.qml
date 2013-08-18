import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1

Rectangle {
    //color: "lightgray"

    property bool expanded: true

    Item {
        ThinDivider {
            rotation: 90

        //Rectangle {
            //color: "lightgray"

            //width: 1
            width: parent.height
            height: 2
            anchors {
                left: undefined
                right: undefined
                centerIn: parent
            }
        }
        width: 2

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: 0
        }
    }

    width: units.gu(35)


    x: expanded ? 0 : -width

    Behavior on x {
        PropertyAnimation {
            duration: 250
        }
    }

    default property alias contents: contents.data

    Item {
        id: contents

        anchors {
            fill: parent
            rightMargin: 1
        }
    }
}
