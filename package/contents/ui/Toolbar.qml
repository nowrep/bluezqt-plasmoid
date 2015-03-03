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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: toolbar

    height: btSwitchButton.height

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }

    Row {
        anchors {
            bottom: parent.bottom
            left: parent.left
            top: parent.top
        }

        SwitchButton {
            id: btSwitchButton

            checked: btManager.bluetoothOperational
            enabled: btManager.adapters.length > 0
            icon: "preferences-system-bluetooth"

            onClicked: {
                for (var i = 0; i < btManager.adapters.length; ++i) {
                    var adapter = btManager.adapters[i];
                    adapter.powered = !adapter.powered;
                }
            }
        }
    }

    Row {
        id: rightButtons
        spacing: 5

        anchors {
            right: parent.right
            rightMargin: Math.round(units.gridUnit / 2)
            verticalCenter: parent.verticalCenter
        }

        PlasmaComponents.ToolButton {
            id: addDeviceButton

            iconSource: "list-add"
            tooltip: i18n("Add New Device")

            onClicked: {
                appLauncher.runCommand("bluedevil-wizard");
            }
        }

        PlasmaComponents.ToolButton {
            id: openSettingsButton

            iconSource: "configure"
            tooltip: i18n("Bluetooth Settings")

            onClicked: {
                var args = [ "bluedevildevices", "bluedeviltransfer", "bluedeviladapters" ];
                appLauncher.runCommand("kcmshell5", args);
            }
        }
    }
}
