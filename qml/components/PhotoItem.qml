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
