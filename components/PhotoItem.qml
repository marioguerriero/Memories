import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape {
    objectName: "ubuntushape_image"
    width: units.gu(8)
    height: units.gu(8)

    property alias source : image.source

    image: Image {
        id: image
        source: "../resources/images/sun.png"
        fillMode: Image.PreserveAspectCrop
    }
}
