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

// It is used only to get informations about memories

QtObject {

    id: memory

    function toJSON() {
        return {
            title: title,
            tags: tags,
            description: description,
            date: date,
            location: location,
            weather: weather,
            photos: photos,
            favorite: favorite
        }
    }

    function remove() {
        homePage.removeMemory(memory)
    }

    property string title
    property string tags
    property string description
    property string date
    property string location
    property string weather
    property var photos: []
    property string audio
    property bool favorite

    property bool visible: true

    function getTags() {
        var list = []

        for(var n = 0; n < tags.split(",").length; n++) {
            var tag = tags.split(",")[n]
            if(tag != "")
                list.push(tag)
        }
        return list
    }

    function getShareString() {
        var max_length = 140
        var hashtag = "#memories"
        var string = ""
        // Add the title
        string += title
        // Add the description (if exists)
        if(description) {
            string += (": " + description)
            if(string.length > 100) {
                string = string.substring(0, 98) + "..."
            }
        }
        // Add the location (if exists)
        if(location)
            string += " @ " + location
        // Add the date
        string += " " + date
        // Add a nice hashtag
        string += " " + hashtag
        // Finally return the ready to be posted string
        if(string.length > max_length)
            string = string.substring(0, max_length - hashtag.length - 4) + "... " + hashtag
        return string.replace(/<(?:.|\n)*?>/gm, '')
    }

    function getPhotoList() {
        var array = photos.split("||")
        return array.slice(0, array.length-1)
    }

}
