import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1

Sidebar {
    id: root
    color: "#555555"
    width: units.gu(25)

    ListModel {
        id: tagsModel
    }

    property string currentCategory: ""
    property string nullCategory: "null"

    ListView {
        id: listView
        anchors.fill: parent
        clip: true
        header: Column {
            width: parent.width

            Standard {
                text: i18n.tr("All")
                selected: (currentCategory == nullCategory)
                onClicked: currentCategory = nullCategory
            }

            Header {
                text: i18n.tr("Tags")
            }
        }
        model: tagsModel
        delegate: Standard {
            text: tag
            selected: (text == currentCategory)
            onClicked: currentCategory = text
        }
    }
    Scrollbar {
        flickableItem: listView
    }

    function appendTags(tags) {
        tagsModel.clear()
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
        }
    }

}
