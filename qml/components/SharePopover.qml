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
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0

Popover {
    id: popover

    signal send(var id)

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: childrenRect.height

        ListView {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: childrenRect.height
            interactive: false

            model: accountsModel

            delegate: Item {
                width: parent.width
                height: childrenRect.height

                MultiValue {                   
                    text: provider
                    values: [ displayName ]
                    property real accountId: id
                    property string serviceName: provider
                    iconSource: {
                        return "/usr/share/icons/ubuntu-mobile/apps/144/" + iconName + ".png"
                    }
                    onClicked: {
                        send(accountId)
                    }
                }
            }
        }
    }
}
