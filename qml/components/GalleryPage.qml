/**
 * This file is part of Memories.
 *
 * Copyright 2013-2015 (C) Mario Guerriero <marioguerriero33@gmail.com>
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

import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0

Page {
    id: gallery
    title: memory ? memory.title : i18n.tr("Gallery")
    visible: false

    property var memory
    property var photos: []
    property var current

    onPhotosChanged: repeater.model = photos

    onWidthChanged: showPhoto(current)

    Rectangle {
        id: rect
        anchors.fill: parent
        color: "black"

        Flickable {
            id: flickable

            maximumFlickVelocity: mainView.width * 1.5

            onMovementEnded: {
                var unit = mainView.width
                animate.from = contentX
                animate.to = repeater.itemAt(Math.round(contentX / unit)).x
                animate.start()
                current = Math.round(getCurrentPhoto())
            }

            ParallelAnimation {
                id: animate
                property real from: 0
                property real to: 0
                NumberAnimation {
                    target: flickable
                    properties: "contentX"
                    from: animate.from
                    to: animate.to
                    duration: UbuntuAnimation.FastDuration
                }
            }

            anchors {
                left: parent.left
                right: parent.right
            }

            height: row.height
            contentWidth: mainView.width * repeater.model.length

            flickableDirection: Flickable.HorizontalFlick

            Row {
                id: row

                Repeater {
                    id: repeater
                    model: [ ]
                    delegate: Image {
                        height: rect.height
                        width: rect.width

                        source: modelData
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }
        }
    }

    function showPhoto(index) {
        current = index
        flickable.contentX =  mainView.width * index
    }

    function getCurrentPhoto() {
        return flickable.contentX / mainView.width
    }
}
