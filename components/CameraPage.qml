import QtQuick 2.0
import Ubuntu.Components 0.1

Page {
    id: cameraPage
    objectName: "cameraPage"
    title: i18n.tr("Camera")
    visible: false

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: tools
                locked: true
                opened: true
            }

            PropertyChanges {
                target: parent
                anchors.bottomMargin: units.gu(-2)
            }
        }

    ]

    Camera {
        id: camera
        anchors.fill: parent

        onImagePathChanged: {
            memoryEditPage.addPhoto(imagePath)
            stack.pop()
            stack.push(memoryEditPage)
        }
    }

    function start() {
        camera.start()
    }

    function stop() {
        camera.stop()
    }

    tools: ToolbarItems {

        ToolbarButton {
            id: snapButton
            text: i18n.tr("Snaps")
            iconSource: "../resources/images/camera.svg"

            onTriggered: {
                camera.capture()
            }
        }
    }
}
