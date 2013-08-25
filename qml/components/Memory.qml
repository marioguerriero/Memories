import QtQuick 2.0

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

    property string title;
    property string tags;
    property string description;
    property string date;
    property string location;
    property string weather;
    property var photos: []
    property bool favorite

    property bool visible: true

    function getTags() {
        var list = []

        for(var n = 0; n < tags.split(",").length; n++)
            list.push(tags.split(",")[n].replace(" ", ""))

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
        return string
    }

    function getPhotoList() {
        var array = photos.split("||")
        return array.slice(0, array.length-1)
    }

    function exportAsPdf() {
        var fileName = utils.homePath() + "/" + title + ".pdf";

        if (utils.exportAsPdf(fileName, toJSON()))
            print("Saved PDF: " + fileName);
    }
}
