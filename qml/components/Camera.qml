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
import QtQuick.Window 2.0
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
            fill: parent
            //horizontalCenter: parent.horizontalCenter
            //verticalCenter: parent.verticalCenter
        }

        focus: visible

        /* This rotation needs to be applied since the camera hardware in the
           Galaxy Nexus phone is mounted at an angle inside the device, so the video
           feed is rotated too.
           FIXME: This should come from a system configuration option so that we
           don't have to have a different codebase for each different device we want
           to run on */
         //orientation: device.naturalOrientation === "portrait"  ? -90 : 0
          orientation: Screen.primaryOrientation == Qt.LandscapeOrientation ? 0 : -90
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
