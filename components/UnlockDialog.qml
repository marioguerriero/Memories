import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Dialog {
    id: dialogue
    title: i18n.tr("Unlock Memories")
    text: i18n.tr("Enter your password to continue to use Memories.")

    Label {
        id: errorLabel
        color: "red"
        text: i18n.tr("The password you entered is not good.")
        visible: false
    }

    TextField {
        id: passwordField
        placeholderText: i18n.tr("Password...")
        echoMode: TextInput.Password
    }

    Button {
        text: i18n.tr("Unlock")
        color: UbuntuColors.orange
        onClicked: {
            if(passwordField.text == caller.password) {
                caller.locked = false
                PopupUtils.close(dialogue)
            }
            else
                errorLabel.visible = true
        }
    }
}
