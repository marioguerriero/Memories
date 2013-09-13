/***************************************************************************
 * Whatsoever ye do in word or deed, do all in the name of the             *
 * Lord Jesus, giving thanks to God and the Father by him.                 *
 * - Colossians 3:17                                                       *
 *                                                                         *
 * Ubuntu Tasks - A task management system for Ubuntu Touch                *
 * Copyright (C) 2013 Michael Spencer <sonrisesoftware@gmail.com>          *
 *                                                                         *
 * This program is free software: you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation, either version 3 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the            *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License       *
 * along with this program. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * This file was orignally written for Ubuntu Tasks                        *
 ***************************************************************************/
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: root

    title: i18n.tr("Select Date")

    property var date

    UbuntuShape {
        id: datePicker
        color: Qt.rgba(0.5,0.5,0.5,0.4)

        width: units.gu(20)
        height: units.gu(18)

        property var initialDate: new Date()

        property var date: {
            var date = new Date()
            date.setHours(0)
            date.setMinutes(0)
            date.setSeconds(0)

            date.setFullYear(yearSpinner.value)
            date.setMonth(monthSpinner.selectedIndex + 1)
            date.setDate(dateSpinner.value)
            return date
        }

        Item {
            id: rectangle
            anchors.fill: parent

            ValuesSpinner {
                id: monthSpinner
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.horizontalCenter
                }

                value: Qt.formatDateTime(new Date(), "MMMM")

                width: units.gu(20)
                values: {
                    var months = []
                    for(var n = 1; n <= 12; n++) {
                        var date = new Date()
                        date.setMonth(n)
                        print(Qt.formatDateTime(date, "MMMM"))
                        months.push(Qt.formatDateTime(date, "MMMM"))
                    }
                    return months
                }
            }
            VerticalDivider {
                id: divider1
                anchors.margins: 1
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                anchors {
                    left: parent.horizontalCenter
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                Spinner {
                    id: dateSpinner
                    anchors {
                        left: parent.left
                        right: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                    }

                    value: Qt.formatDateTime(new Date(), "d")
                    minValue: 1
                    maxValue: 31
                }

                VerticalDivider {
                    id: divider2
                    anchors.margins: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Spinner {
                    id: yearSpinner
                    anchors {
                        left: parent.horizontalCenter
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }

                    value: Qt.formatDateTime(new Date(), "yyyy")
                    minValue: Qt.formatDateTime(new Date(), "yyyy") - 100
                    maxValue: Qt.formatDateTime(new Date(), "yyyy")
                }
            }
        }
    }

    Button {
        objectName: "cancelButton"
        text: i18n.tr("Cancel")

        gradient: UbuntuColors.greyGradient

        onClicked: {
            PopupUtils.close(root)
        }
    }

    Button {
        id: okButton
        text: i18n.tr("Ok")

        onClicked: {
            caller.date = datePicker.date
            PopupUtils.close(root)
        }
    }
}
