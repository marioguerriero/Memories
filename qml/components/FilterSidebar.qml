import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import "../ubuntu-ui-extras"

Sidebar {
    id: root
    color: "#555555"
    width: units.gu(35)

    ListModel {
        id: tagsModel
    }

    property string currentCategory: nullCategory
    property string lastCategory: ""
    property string nullCategory: "null"
    property string favoritesCategory: "Favorites"

    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        header: Column {
            width: parent.width

            Standard {
                text: i18n.tr("All")
                selected: (currentCategory == nullCategory)
                onClicked: {
                    lastCategory = currentCategory
                    currentCategory = nullCategory
                    if(lastCategory != currentCategory)
                        clearFilter()
                }
            }

            SingleValue {
                text: i18n.tr("Favorites")
                selected: (currentCategory == favoritesCategory)
                value: {
                    var count = 0

                    for(var i = 0; i < memoryModel.count; i++) {
                        var memory = memoryModel.get(i).mem
                        if(memory.favorite)
                                count++
                    }

                    return count
                }
                visible: value > 0
                onClicked: {
                    lastCategory = currentCategory
                    currentCategory = favoritesCategory
                    if(lastCategory != currentCategory)
                        filterFavorites()
                }
            }

            Header {
                text: i18n.tr("Tags")
            }
        }
        model: tagsModel
        delegate: SingleValue {
            text: tag
            selected: (text == currentCategory)
            value: {
                var count = 0

                for(var i = 0; i < memoryModel.count; i++) {
                    var memory = memoryModel.get(i).mem
                    var tags = memory.getTags()
                    for(var n = 0; n < tags.length; n++) {
                        if(tags[n] == tag)
                            count++
                    }
                }

                return count
            }
            onClicked: {
                lastCategory = currentCategory
                currentCategory = tag
                if(lastCategory != currentCategory)
                    filterByTag(tag)
            }
        }
    }
    Scrollbar {
        flickableItem: listView
    }

    property var tagsList: [] // Used to get counts
    function appendTags(tags) {
        // Clear tagsList and tagsModel
        tagsModel.clear()
        tagsList.length = 0

        var added_tags = []
        var tag = undefined
        for(var n = 0; n < tags.length; n++) {
            tag = tags[n]
            for (var i = 0; i < added_tags.length; i++)
                if (added_tags[i] === tag)
                    tag = undefined
            if(tag) {
                tagsModel.append({"tag": tag})
                added_tags.push(tag)
            }
            tagsList.push(tag)
        }
    }

}
