/*
    Copyright 2013-2014 Jan Grulich <jgrulich@redhat.com>
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

import QtQuick 2.2
import org.qbluez 1.0 as QBluez
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ListItem {
    id: deviceItem;

    property bool expanded : visibleDetails;
    property bool visibleDetails : false;
    property bool connecting : false;
    property int baseHeight : deviceItemBase.height;
    property variant currentDeviceDetails : [];

    height: expanded ? baseHeight + expandableComponentLoader.height + Math.round(units.gridUnit / 3) : baseHeight;
    checked: ListView.isCurrentItem;
    enabled: true;

    Item {
        id: deviceItemBase;

        anchors {
            left: parent.left;
            right: parent.right;
            top: parent.top;
            // Reset top margin from PlasmaComponents.ListItem
            topMargin: -Math.round(units.gridUnit / 3);
        }

        height: Math.max(units.iconSizes.medium, deviceNameLabel.height + deviceAddressLabel.height) + Math.round(units.gridUnit / 2);

        PlasmaCore.IconItem {
            id: deviceIcon;

            anchors {
                left: parent.left;
                verticalCenter: parent.verticalCenter;
            }

            height: units.iconSizes.medium;
            width: height;
            source: Icon;
        }

        PlasmaComponents.Label {
            id: deviceNameLabel;

            anchors {
                bottom: deviceIcon.verticalCenter;
                left: deviceIcon.right;
                leftMargin: Math.round(units.gridUnit / 2);
                right: deviceActionsRect.visible ? deviceActionsRect.left : parent.right;
            }

            height: paintedHeight;
            elide: Text.ElideRight;
            text: DeviceFullName;
        }

        PlasmaComponents.Label {
            id: deviceAddressLabel;

            anchors {
                left: deviceIcon.right;
                leftMargin: Math.round(units.gridUnit / 2);
                right: deviceActionsRect.visible ? deviceActionsRect.left : parent.right;
                top: deviceNameLabel.bottom;
            }

            height: paintedHeight;
            elide: Text.ElideRight;
            font.pointSize: theme.smallestFont.pointSize;
            opacity: 0.6;
            text: Address;
        }

        PlasmaComponents.BusyIndicator {
            id: connectingIndicator;

            anchors {
                right: parent.right;
                rightMargin: Math.round(units.gridUnit / 2);
                verticalCenter: deviceIcon.verticalCenter;
            }

            height: units.iconSizes.medium;
            width: height;
            running: connecting;
            visible: running && !connectButton.visible;
        }

        Row {
            id: deviceActionsRect;
            spacing: 2;
            opacity: deviceItem.containsMouse ? 1 : 0;
            visible: opacity != 0;
            Behavior on opacity { NumberAnimation { duration: units.shortDuration } }

            anchors {
                right: parent.right;
                rightMargin: Math.round(units.gridUnit / 2);
                verticalCenter: deviceIcon.verticalCenter;
            }

            PlasmaComponents.ToolButton {
                id: sendFileButton;
                flat: false;
                tooltip: i18n("Send File");
                iconSource: "edit-copy";
                visible: Uuids.indexOf(QBluez.Services.ObexObjectPush) != -1;
                onClicked: {
                    appLauncher.runCommand("bluedevil-sendfile", [ "-u", Ubi ]);
                }
            }

            PlasmaComponents.ToolButton {
                id: browseFilesButton;
                flat: false;
                tooltip: i18n("Browse Files");
                iconSource: "edit-find";
                visible: Uuids.indexOf(QBluez.Services.ObexFileTransfer) != -1;
                onClicked: {
                    var url = "obexftp://" + Address.replace(/:/g, "-");
                    appLauncher.runUrl(url, "inode/directory");
                }
            }

            PlasmaComponents.ToolButton {
                id: connectButton;
                flat: false;
                tooltip: Connected ? i18n("Disconnect") : i18n("Connect");
                iconSource: Connected ? "network-disconnect" : "network-connect";
                onClicked: {
                    if (Connected) {
                        Device.disconnectDevice();
                        return;
                    }

                    if (connecting) {
                        return;
                    }

                    connecting = true;
                    runningActions++;

                    Device.connectDevice().finished.connect(function(call) {
                        connecting = false;
                        runningActions--;
                    });
                }
            }
        }
    }

    Loader {
        id: expandableComponentLoader;

        anchors {
            left: parent.left;
            right: parent.right;
            top: deviceItemBase.bottom;
        }
    }

    Component {
        id: detailsComponent;

        Item {
            height: childrenRect.height;

            PlasmaCore.SvgItem {
                id: detailsSeparator;

                anchors {
                    left: parent.left;
                    right: parent.right;
                    top: parent.top;
                }

                height: lineSvg.elementSize("horizontal-line").height;
                width: parent.width;
                elementId: "horizontal-line";
                svg: PlasmaCore.Svg { id: lineSvg; imagePath: "widgets/line" }
            }

            Column {
                id: details;

                anchors {
                    left: parent.left;
                    leftMargin: units.iconSizes.medium;
                    right: parent.right;
                    top: detailsSeparator.bottom;
                    topMargin: Math.round(units.gridUnit / 3);
                }

                Repeater {
                    id: repeater;

                    property int longestString: 0;

                    model: currentDeviceDetails.length / 2;

                    Item {
                        anchors {
                            left: parent.left;
                            right: parent.right;
                            topMargin: Math.round(units.gridUnit / 3);
                        }

                        height: Math.max(detailNameLabel.height, detailValueLabel.height);

                        PlasmaComponents.Label {
                            id: detailNameLabel;

                            anchors {
                                left: parent.left;
                                leftMargin: repeater.longestString - paintedWidth + Math.round(units.gridUnit / 2);
                                verticalCenter: parent.verticalCenter;
                            }

                            height: paintedHeight;
                            font.pointSize: theme.smallestFont.pointSize;
                            horizontalAlignment: Text.AlignRight;
                            opacity: 0.6;
                            text: "<b>" + currentDeviceDetails[index*2] + "</b>: &nbsp";

                            Component.onCompleted: {
                                if (paintedWidth > repeater.longestString) {
                                    repeater.longestString = paintedWidth;
                                }
                            }
                        }

                        PlasmaComponents.Label {
                            id: detailValueLabel;

                            anchors {
                                left: detailNameLabel.right;
                                right: parent.right;
                                verticalCenter: parent.verticalCenter;
                            }

                            height: paintedHeight;
                            elide: Text.ElideRight;
                            font.pointSize: theme.smallestFont.pointSize;
                            opacity: 0.6;
                            text: currentDeviceDetails[(index*2)+1];
                            textFormat: Text.StyledText;
                        }
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "collapsed";
            when: !visibleDetails;

            StateChangeScript {
                script: if (expandableComponentLoader.status == Loader.Ready) {
                            expandableComponentLoader.sourceComponent = undefined;
                        }
            }
        },

        State {
            name: "expandedDetails";
            when: visibleDetails;

            StateChangeScript {
                script: createContent();
            }
        }
    ]

    function boolToString(v)
    {
        if (v) {
            return i18n("Yes");
        }
        return i18n("No");
    }

    function createContent() {
        if (visibleDetails) {
            var details = [];

            details.push(i18n("Name"));
            details.push(Name);

            if (Alias != Name) {
                details.push(i18n("Alias"));
                details.push(Alias);
            }

            details.push(i18n("Trusted"));
            details.push(boolToString(Trusted));

            details.push(i18n("Blocked"));
            details.push(boolToString(Blocked));

            details.push(i18n("Adapter"));
            details.push(AdapterFullName);

            currentDeviceDetails = details;
            expandableComponentLoader.sourceComponent = detailsComponent;
        }
    }

    onStateChanged: {
        if (state == "expandedDetails") {
            ListView.view.currentIndex = index;
        }
    }

    onClicked: {
        visibleDetails = !visibleDetails;

        if (!visibleDetails) {
            ListView.view.currentIndex = -1;
        }
    }
}
