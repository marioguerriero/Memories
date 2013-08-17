import QtQuick 2.0
import Ubuntu.Components 0.1
import QtMultimedia 5.0

Page {
    id: cameraPage
    objectName: "cameraPage"
    title: i18n.tr("Camera")
    visible: false

    Camera {
        id: camera
        flash.mode: Camera.FlashOff
        captureMode: Camera.CaptureStillImage
        focus.focusMode: Camera.FocusAuto
        //focus.focusPointMode: focusRing.opacity > 0 ? Camera.FocusPointCustom : Camera.FocusPointAuto

        /*property AdvancedCameraSettings advanced: AdvancedCameraSettings {
            camera: camera
        }*/
    }
}
