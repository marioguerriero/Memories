import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Flickable {
    id: flickable

    anchors {
        left: parent.left
        right: parent.right
        topMargin: units.gu(2)
        leftMargin: units.gu(2)
        rightMargin: units.gu(2)
    }

    clip: true

    height: memoryGrid.height

    contentWidth: memoryGrid.width
    //interactive: contentWidth > width

    flickableDirection: Flickable.VerticalFlick

    // Component properties
    property var memories: [ ]
    property int itemSize: units.gu(18)

    property int currentIndex: 0

    onWidthChanged: {
        memoryGrid.columns = memoryGrid.calculateColumns()
    }

    Grid {
        id: memoryGrid
        spacing: units.gu(6)
        columns: calculateColumns()

        // Used to get columns value according to the window width
        function calculateColumns() {
            var tmp = (flickable.width - memories.length * spacing - (flickable.anchors.leftMargin + flickable.anchors.rightMargin))
            return tmp / (itemSize)
        }


        Repeater {
            id: repeater
            model: [ ]

            delegate: UbuntuShape {
                id: shape
                height: itemSize
                width: itemSize

                property int idx
                property Memory memory: modelData

                color: UbuntuColors.orange

                CrossFadeImage {
                    id: crossFade
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop

                    fadeDuration: 1000
                    source: parseSources()

                    property var photos: photos = memory.getPhotoList()
                    property int index: 0
                    function parseSources() {
                        if(photos.length == 0)
                            return
                        source = photos[index]
                        if(index == photos.length - 1)
                            index = 0
                        else
                            index++
                    }
                    // Change the source each interval
                    Timer {
                        interval: 2500
                        running: true
                        repeat: true
                        onTriggered: {
                            crossFade.parseSources()
                        }
                    }
                }

                Column {
                    anchors.top: shape.bottom
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
                    clip: true

                    Label {
                        text: truncate(memory.title, itemSize * 1.5) // * 2.5 because of the large size
                        fontSize: "large"
                    }

                    Label {
                        text: truncate(memory.location + ", " + memory.date, itemSize * 2.9) // * 2.5 because of the small size
                        fontSize: "small"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.showMemory(memory)
                }

                function showMemory(memory) {
                    memoryPage.memory = memory
                    stack.push(memoryPage);
                }
            }
        }

        function addMemories(list) {
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
        memoryGrid.columns = (flickable.width - memories.length * memoryGrid.spacing - (flickable.anchors.leftMargin + flickable.anchors.rightMargin)) / (itemSize)
    }

    function addMemories(list) {
        memories = []
        memoryGrid.addMemories(list)
    }

    function truncate(text, width) {
        if (text.length > width / units.gu(2)) {
            text = text.substring(0, width / units.gu(2.3));
            text += "...";
        }
        return text
    }

    function filterByTag(filter) {
        for(var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i)
            var memory = item.memory
            var tags = memory.getTags()
            for(var n = 0; n < tags.length; n++) {
                if(tags[n] == filter) {
                    item.visible = true
                    break
                }
                else
                    item.visible = false
            }
        }
    }

}
