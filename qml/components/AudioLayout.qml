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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

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
    property int seconds: 0
    property int iconSize: units.gu(8)

    onMemoryChanged: path = memory.audio
    onRecordingChanged: {
        if(recording)
            timer.start()
        else
            timer.stop()
    }

    Row {
        id: row
        spacing: units.gu(2)

        Button {
            id: recordButton
            iconSource: image("microphone.png")
            height: iconSize
            width: height

            visible: editable

            onClicked: PopupUtils.open(popoverComponent, recordButton)
            onPressAndHold: {
                recording = true
                utils.recordAudioStart()
            }
            onPressedChanged: {
                if(!pressed && recording)
                    utils.audioRecordStop()
                recording = false
            }
        }

        Timer {
            id: timer
            repeat: true
            onTriggered: seconds++;
        }

        Label {
            visible: seconds > 0
            text: seconds
        }
    }

    // Popover
    Component {
        id: popoverComponent

        Popover {
            id: popover
            Column {
                id: containerLayout
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                ListItem.Standard { text: i18n.tr("Press and hold to record") }
            }
        }
    }
}
