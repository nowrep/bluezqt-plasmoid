/*
    Copyright 2014 David Rosca <nowrep@gmail.com>

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

function init()
{
    btManager.adapterAdded.connect(slotAdapterAdded);
    btManager.bluetoothOperationalChanged.connect(updateStatus);

    for (var i = 0; i < btManager.adapters.length; ++i) {
        slotAdapterAdded(btManager.adapters[i]);
    }

    for (var i = 0; i < btManager.devices.length; ++i) {
        slotDeviceAdded(btManager.devices[i]);
    }

    updateStatus();
}

function slotAdapterAdded(adapter)
{
    adapter.deviceFound.connect(slotDeviceAdded);
}

function slotDeviceAdded(device)
{
    device.deviceChanged.connect(slotDeviceChanged);
}

function slotDeviceChanged(device)
{
    updateStatus();
}

function updateStatus()
{
    var connectedDevices = new Array();

    for (var i = 0; i < btManager.devices.length; ++i) {
        var device = btManager.devices[i];
        if (device.connected) {
            connectedDevices.push(device);
        }
    }

    var text = "";

    if (!btManager.bluetoothOperational) {
        if (btManager.adapters.length == 0) {
            text = i18n("No adapters available");
        } else {
            text = i18n("Bluetooth is offline");
        }
    } else if (connectedDevices.length > 0) {
        text = i18ncp("Number of connected devices", "%1 connected device", "%1 connected devices", connectedDevices.length);
        for (var i = 0; i < connectedDevices.length; ++i) {
            var device = connectedDevices[i];
            text += "\n • " + device.friendlyName + " (" + device.address + ")";
        }
    } else {
        text = i18n("No connected devices");
    }

    plasmoid.toolTipSubText = text;

    if (btManager.bluetoothOperational) {
        plasmoid.status = PlasmaCore.Types.ActiveStatus;
    } else {
        plasmoid.status = PlasmaCore.Types.PassiveStatus;
    }
}

