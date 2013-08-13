import QtQuick 2.0
import Ubuntu.Components 0.1
import QtMultimedia 5.0

UbuntuShape {
    width: parent.width
    height: parent.height
    anchors.top: parent.top

    VideoOutput {
        id: videoPreview
        source: camera
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
//        width: parent.width
//        height: parent.width

        focus: visible

        /* This rotation needs to be applied since the camera hardware in the
           Galaxy Nexus phone is mounted at an angle inside the device, so the video
           feed is rotated too.
           FIXME: This should come from a system configuration option so that we
           don't have to have a different codebase for each different device we want
           to run on */
        orientation: device.naturalOrientation === "portrait"  ? -90 : 0
    }

    Camera {
        id: camera
        flash.mode: Camera.FlashAuto
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto
        exposure.exposureMode: Camera.ExposureAuto

        imageCapture {
            //resolution: Qt.size(640, 480)

            onImageSaved: {
                debugLog("Picture saved as " + path);
                decoder.decode(path);
            }
        }

        function capture() {
            return camera.imageCapture.capture()
        }
    }

    DeviceOrientation {
        id: device
    }
}
