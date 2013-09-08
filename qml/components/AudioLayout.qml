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
import Ubuntu.Components.ListItems 0.1 as ListItem

Flickable {
    id: flickable
    visible: false

    anchors {
        left: parent.left
        right: parent.right
    }

    height: row.height

    contentWidth: row.width
    interactive: contentWidth > width

    flickableDirection: Flickable.HorizontalFlick

    // Component properties
    property Memory memory
    property string path
    property bool editable: true
    property bool recording: false
    property int iconSize: units.gu(8)

    onMemoryChanged: path = memory.audio

    Row {
        id: row
        spacing: units.gu(2)

        Button {
            iconSource: image("microphone.png")
            height: iconSize
            width: height

            visible: editable

            onClicked: print("nothing")
            onPressAndHold: {
                recording = true
                utils.recordAudioStart()
            }
            onPressedChanged: {
                if(!pressed && recording)
                    utils.audioRecordStop()
            }
        }

        Label {
            id: label
        }
    }
}
