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
            photos: photos
        }
    }

    function remove() {
        removeMemory(memory)
    }

    property string title;
    property string tags;
    property string description;
    property string date;
    property string location;
    property string weather;
    property string photos; // A list of photos divided by a '||'
}
