import QtQuick 2.0
import Ubuntu.Components 0.1
import QtMultimedia 5.0

UbuntuShape {
    /*width: parent.width
    height: parent.height
    anchors.top: parent.top
    anchors.fill: parent*/

    VideoOutput {
        id: videoPreview
        source: camera
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        focus: visible

        /* This rotation needs to be applied since the camera hardware in the
           Galaxy Nexus phone is mounted at an angle inside the device, so the video
           feed is rotated too.
           FIXME: This should come from a system configuration option so that we
           don't have to have a different codebase for each different device we want
           to run on */
        //orientation: device.naturalOrientation === "portrait"  ? -90 : 0
    }

    property alias imagePath: camera.imagePath
    Camera {
        id: camera
        cameraState: Camera.UnloadedStatus
        flash.mode: Camera.FlashAuto
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto
        exposure.exposureMode: Camera.ExposureAuto

        property string imagePath: ""

        imageCapture {
            //resolution: Qt.size(640, 480)

            onImageSaved: {
                camera.imagePath = path
                print("Picture saved as " + path)
            }
        }
    }

    function start() {
        camera.start()
    }

    function stop() {
        camera.stop()
    }

    function capture() {
        camera.imageCapture.capture()
    }
}
