import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Flickable {
    id: flickable

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(2)
        rightMargin: units.gu(2)
    }
    clip: true

    height: memoryGrid.height

    contentWidth: memoryGrid.width
    interactive: contentWidth > width

    flickableDirection: Flickable.VerticalFlick

    // Component properties
    property var memories: [ ]
    property int itemSize: units.gu(18)

    property int currentIndex: 0

    Grid {
        id: memoryGrid
        spacing: units.gu(2)
        columns: (flickable.width - memories.length * spacing) / (itemSize)

        Repeater {
            id: repeater
            model: [ ]

            delegate: UbuntuShape {
                height: itemSize
                width: itemSize

                property int idx;
                property Memory memory: modelData

                /*image: Image {
                    source: memory.getPhotoList()[1]
                    fillMode: Image.PreserveAspectCrop
                }*/

                CrossFadeImage {
                    id: crossFade
                    anchors.fill: parent
                    anchors.bottomMargin: parent.height / 2
                    source: memory.getPhotoList()[0]
                    fadeDuration: 1000
                    MouseArea {
                        anchors.fill: parent
                        onClicked: print("")//parent.source = "http://design.ubuntu.com/wp-content/uploads/canonical-logo1.png"
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.top: crossFade.bottom
                    anchors.topMargin: parent.height / 2
                    radius: units.gu(1)
                    clip: true
                    gradient: UbuntuColors.orangeGradient
                Column {
                    //anchors.bottom: image.bottom

                    //anchors.topMargin: parent.bottom
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)

                    spacing: units.gu(1)
                    clip: true

                    Label {
                        text: memory.date
                    }

                    Label {
                        text: memory.location
                    }

                    Label {
                        text: memory.title
                    }
                }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        idx = index;
                        memoryGrid.showMemory(idx);
                    }
                }

                UbuntuNumberAnimation on opacity { from: 0; to: 100; }

            }
        }

        function showMemory(index) {
            console.log("Not implemented feature.");
        }

        function selectMemory() {
            PopupUtils.open(Qt.resolvedUrl("./PhotoChooser.qml"), memoryGrid);
        }

        function addMemories(list) {
            // Clean the list before add anything else
            memories = []

            for(var n = 0; n < list.length; n++)
                memories.push(list[n]);
            // Update the model manually, since push() doesn't trigger
            // the *Changed event
            repeater.model = memories
        }

        function removeMemory(index) {
            memories.splice(index, 1);
            repeater.model = memories
        }
    }

    onMemoriesChanged: {
        repeater.model = memories
    }

    function addMemories(list) {
        memoryGrid.addMemories(list)
    }
}
