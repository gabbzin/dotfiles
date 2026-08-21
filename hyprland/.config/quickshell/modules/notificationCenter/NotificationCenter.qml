import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs

PopupWindow {
    id: root
    required property var barWindow
    property bool isOpen: false

    anchor.window: barWindow
    anchor.rect.x: barWindow.width - implicitWidth - 12
    anchor.rect.y: barWindow.height + 8
    anchor.rect.width: implicitWidth
    anchor.rect.height: implicitHeight

    implicitWidth: 400
    implicitHeight: 560
    visible: isOpen
    color: "transparent"

    // DND state — persistente via PersistentProperties futuramente
    property bool dndEnabled: false
    readonly property int notifCount: NotificationServer.trackedNotifications ? NotificationServer.trackedNotifications.values.length : 0
    // Histórico em memória — NotificationServer.trackedNotifications já persiste se keepOnReload true
    // Vamos usar trackedNotifications como fonte principal

    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: root.isOpen = false
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bgAlt
        radius: Theme.radiusM
        border.color: Theme.barBorder
        border.width: 1

        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.98
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Notifications"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }
                Text {
                    text: root.notifCount > 0 ? "(" + root.notifCount + ")" : ""
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                }
                Item { Layout.fillWidth: true }
                // DND toggle
                RowLayout {
                    spacing: 6
                    Text {
                        text: "DND"
                        color: Theme.subtext1
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    Rectangle {
                        width: 44; height: 24; radius: 12
                        color: root.dndEnabled ? Theme.accent : Theme.surface0
                        border.color: Theme.surface1
                        Rectangle {
                            width: 18; height: 18; radius: 9
                            color: Theme.text
                            x: root.dndEnabled ? parent.width - width - 3 : 3
                            y: 3
                            Behavior on x { NumberAnimation { duration: Theme.animFast } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dndEnabled = !root.dndEnabled
                        }
                    }
                }
                // Clear all
                Text {
                    text: "󰅖 Clear"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // dismiss all tracked
                            if (NotificationServer.trackedNotifications) {
                                for (const n of NotificationServer.trackedNotifications.values) {
                                    n.dismiss();
                                }
                            }
                        }
                    }
                }
                // close
                Text {
                    text: "󰅖"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    leftPadding: 8
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.isOpen = false
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

            // Lista
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: listContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: listContent
                    width: parent.width
                    spacing: Theme.spacingS

                    // Empty state
                    Item {
                        Layout.fillWidth: true
                        height: 120
                        visible: root.notifCount === 0
                        ColumnLayout {
                            anchors.centerIn: parent
                            Text {
                                text: root.dndEnabled ? "󰂛 DND enabled" : "󰂚"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: 32
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: root.dndEnabled ? "Notifications paused" : "No notifications"
                                color: Theme.subtext0
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    Repeater {
                        model: NotificationServer.trackedNotifications
                        delegate: NotificationItem {
                            notification: modelData
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Footer info
            Text {
                text: "Quickshell NotificationServer • " + (root.dndEnabled ? "DND on" : "DND off")
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Lógica de captura: quando nova notificação chega, decide se tracka
    // Se DND, não tracka (silencia)
    Connections {
        target: NotificationServer
        function onNotification(n) {
            if (root.dndEnabled) {
                // silencia: não tracka e descarta
                n.tracked = false;
                return;
            }
            n.tracked = true;
        }
    }

    // Garante que server persiste após reload
    Component.onCompleted: {
        NotificationServer.keepOnReload = true;
        NotificationServer.bodySupported = true;
        NotificationServer.actionsSupported = true;
        NotificationServer.imageSupported = true;
    }
}
