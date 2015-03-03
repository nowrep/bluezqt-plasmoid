/*
    Copyright 2013-2014 Jan Grulich <jgrulich@redhat.com>
    Copyright 2014-2015 David Rosca <nowrep@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.bluetooth 1.0 as PlasmaBt

FocusScope {
    PlasmaBt.DevicesProxyModel {
        id: devicesModel
        sourceModel: BluezQt.DevicesModel { }
    }

    PlasmaExtras.Heading {
        id: noAdaptersHeading
        level: 3
        opacity: 0.6
        text: i18n("No Adapters Available")

        anchors {
            top: parent.top
            left: parent.left
        }
    }

    Toolbar {
        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollView
        visible: toolbar.visible

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: toolbar.bottom
        }

        Item {
            id: noDevicesView
            anchors.fill: parent

            PlasmaExtras.Heading {
                id: noDevicesHeading
                level: 3
                opacity: 0.6
                text: i18n("No Devices Found")

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: addDeviceButton.top
                    bottomMargin: 5
                }
            }

            PlasmaComponents.Button {
                id: addDeviceButton
                text: i18n("Add New Device")
                iconSource: "list-add"

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                onClicked: {
                    appLauncher.runCommand("bluedevil-wizard");
                }
            }
        }

        ListView {
            id: devicesView
            anchors.fill: parent
            clip: true
            model: devicesModel
            currentIndex: -1
            enabled: btManager.bluetoothOperational
            boundsBehavior: Flickable.StopAtBounds
            section.property: showSections ? "Section" : ""
            section.delegate: Header {
                text: section == "Connected" ? i18n("Connected devices") : i18n("Available devices")
            }
            delegate: DeviceItem { }
        }
    }

    states: [
        State {
            name: "DevicesState"
            when: btManager.devices.length > 0
        },
        State {
            name: "NoDevicesState"
            when: btManager.adapters.length > 0 && btManager.devices.length == 0
        },
        State {
            name: "NoAdaptersState"
            when: btManager.adapters.length == 0
        }
    ]

    onStateChanged: {
        noAdaptersHeading.visible = (state == "NoAdaptersState");
        toolbar.visible = (state == "DevicesState" || state == "NoDevicesState");
        noDevicesView.visible = (state == "NoDevicesState");
        devicesView.visible = (state == "DevicesState");
    }
}
