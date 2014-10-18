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

Dialog {
    id: dialogue
    title: i18n.tr("Are you sure?")
    text: i18n.tr("Do you really want to delete this photo?")

    property alias imm: imm.source
    property int photoIndex: -1

    UbuntuShape {
        height: units.gu(22)
        width: height
        image: Image {
            id: imm
            anchors.fill: parent
        }
    }

    Button {
        id: confirmBtn
        text: i18n.tr("Delete")
        color: UbuntuColors.orange
        onClicked: {
            if(photoIndex != -1)
                caller.removePhoto(imm)
            PopupUtils.close(dialogue)
        }
    }

    Button {
        id: cancelBtn
        text: i18n.tr("Cancel")
        gradient: UbuntuColors.greyGradient
        onClicked: PopupUtils.close(dialogue)
    }
}
