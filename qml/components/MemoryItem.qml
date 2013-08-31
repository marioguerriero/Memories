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
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.MultiValue {
    id: item
    progression: true
    icon: {
        var photo = memory.photos[0]
        if(photo == "" || !utils.fileExists(photo))
            return Qt.resolvedUrl("../../resources/images/empty.png")
        return photo
    }

    onClicked: {
        memoryPage.memory = memory
        stack.push(memoryPage);
    }

    property Memory memory;
    onMemoryChanged: {
        if(!memory)
            return
        item.text = memory.title
        values = [ memory.location, memory.date, memory.tags ]
        // Make it a bit nicer
        var val = []
        for(var n = 0; n < values.length; n++)
            if(values[n] != "")
                val.push(values[n])
        values = val
    }

    property bool memoryVisible: memory.visible
    onMemoryVisibleChanged: {
        if(memoryVisible)
            show()
        else
            hide()
    }
    function show() {
        height = units.gu(6.3)
        visible = true
    }

    function hide() {
        height = 0
        visible = false
    }
}
