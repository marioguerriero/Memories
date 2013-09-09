/**
 * This file is part of Memories.
 *
 * Copyright 2013 (C) Mario Guerriero <mefrio.g@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Flickable {
    id: flickable
    objectName: "gridLayout"

    anchors {
        left: parent.left
        right: parent.right
    }

    clip: true

    height: memoryGrid.height

    flickableDirection: Flickable.VerticalFlick

    // Component properties
    //property var memories: [ ]
    property int itemSize: wideAspect ? units.gu(18.5) : units.gu(14)

    property int currentIndex: 0

    Grid {
        id: memoryGrid
        spacing: wideAspect ? units.gu(6) : units.gu(4.5)

        // Used to get columns value according to the window width
        function calculateColumns() {
            var width = wideAspect ? flickable.width : mainView.width
            var tmp = (width - (itemSize + spacing))
            return Math.round(tmp / (itemSize))
        }
        onWidthChanged: {
            var value = calculateColumns()
            if(value < 1)
                columns = 1
            else
                columns = value
        }
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: units.gu(2)
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }

        Repeater {
            id: repeater
            model: memoryModel

            delegate: UbuntuShape {
                id: shape
                height: itemSize
                width: itemSize

                property int idx
                property Memory memory: mem
                visible: memory.visible

                color: UbuntuColors.orange

                CrossFadeImage {
                    id: crossFade
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop

                    fadeDuration: 1000
                    source: {
                        var tmp = parseSources()
                        return tmp ? tmp : Qt.resolvedUrl("../../resources/images/empty.png")
                    }

                    property var photos: photos = memory.photos
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
                        fontSize: wideAspect ? "large" : "medium"
                        onWidthChanged: {
                            if(wideAspect)
                                text = truncate(memory.title, itemSize * 1.5)
                            else
                                text = truncate(memory.title, itemSize * 2.3)
                        }
                    }

                    Label {
                        text: truncate(buildText(), itemSize * 2.9) // * 2.5 because of the small size
                        fontSize: wideAspect ? "small" : "x-small"
                        onWidthChanged: {
                            if(wideAspect)
                                text = truncate(buildText(), itemSize * 2.9)
                            else
                                text = truncate(buildText(), itemSize * 3.6)
                        }
                        function buildText() {
                            var text = ""
                            if(memory.location && memory.date)
                                text = memory.location + ", " + memory.date
                            else if(memory.location && !memory.date)
                                text = memory.location
                            else if(!memory.location && memory.date)
                                text = memory.date
                            return text
                        }
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

                Behavior on height { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                Behavior on width { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
            }
        }
    }

    function updateColumns() {
        memoryGrid.columns = memoryGrid.calculateColumns()
    }
}
