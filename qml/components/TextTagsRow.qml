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

Row {
    id: row
    objectName: "textTagsRow"

    spacing: units.gu(1)

    // Dialogs
    Component {
        id: linkComp
        Dialog {
            id: linkDialog
            title: i18n.tr("Enter a link")
            TextField {
                id: field
                placeholderText: i18n.tr("Link...")
            }
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(linkDialog)
                }
            }
            Button {
                text: i18n.tr("Confirm")
                onClicked: {
                    var open = "<a href=\"" +  field.text + "\">"
                    var close = "</a>"
                    PopupUtils.close(linkDialog)
                    descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                    descriptionArea.cursorVisible = true
                    descriptionArea.cursorPosition -= close.length
                }
            }
        }
    }

    // Buttons
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("bold.png")
        clip: true
        onClicked: {
            var open = "<b>"
            var close = "</b>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("italic.png")
        clip: true
        onClicked: {
            var open = "<i>"
            var close = "</i>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("underline.png")
        clip: true
        onClicked: {
            var open = "<u>"
            var close = "</u>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("barred.png")
        clip: true
        onClicked: {
            var open = "<del>"
            var close = "</del>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("link.png")
        clip: true
        onClicked: {
            PopupUtils.open(linkComp)
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("ordered-list.png")
        clip: true
        onClicked: {
            var open = "<ol>\n\t<li>"
            var close = "</li>\n</ol>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
    Button {
        height: parent.height
        width: units.gu(4)
        iconSource: image("unordered-list.png")
        clip: true
        onClicked: {
            var open = "<ul>\n\t<li>"
            var close = "</li>\n</ul>"
            descriptionArea.insert(descriptionArea.cursorPosition, open + close)
            descriptionArea.cursorPosition -= close.length
        }
    }
}
