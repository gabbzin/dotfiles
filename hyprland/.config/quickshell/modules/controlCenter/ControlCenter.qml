import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs
import "."

PopupWindow {
    id: root

    // ── API pública ──
    required property var barWindow
    property bool isOpen: false

    // ── PopupWindow config ──
    // anchor.window é obrigatório para o popup aparecer
    anchor.window: barWindow
    // posicionamento: canto superior direito, abaixo da barra + gap
    anchor.rect.x: barWindow.width - implicitWidth - 12
    anchor.rect.y: barWindow.height + 8
    anchor.rect.width: implicitWidth
    anchor.rect.height: implicitHeight

    implicitWidth: 380
    implicitHeight: 520
    visible: isOpen
    color: "transparent"

    // Fechar ao clicar fora — HyprlandFocusGrab é mais robusto que grabFocus em Hyprland
    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: root.isOpen
        onCleared: barWindow.controlCenterOpen = false
    }

    // ── Container visual ──
    Rectangle {
        id: container
        anchors.fill: parent
        color: Theme.bgAlt
        radius: Theme.radiusM
        border.color: Theme.barBorder
        border.width: 1

        // sombra sutil (opcional, sem blur por enquanto)
        // animação de entrada
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.98
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            // Título
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Control Center"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                // botão fechar
                Text {
                    text: "󰅖"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barWindow.controlCenterOpen = false
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

            // ── Conteúdo real — Fase 3 completa ──
            Flickable {
                id: ccFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: ccContent.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                interactive: false
                WheelHandler {
                    onWheel: event => {
                        const step = 40;
                        if (event.angleDelta.y > 0) ccFlick.contentY = Math.max(0, ccFlick.contentY - step);
                        else ccFlick.contentY = Math.min(ccFlick.contentHeight - ccFlick.height, ccFlick.contentY + step);
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    id: ccContent
                    width: parent.width
                    spacing: Theme.spacingM

                    Network { id: networkSection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    Bluetooth { id: bluetoothSection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    Audio { id: audioSection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    Brightness { id: brightnessSection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    Battery { id: batterySection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    PowerProfile { id: powerProfileSection }
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

                    Notifications { id: notificationsSection }
                    // Atalho para Notification Center dedicado
                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: Theme.radiusS
                        color: Theme.surface0
                        border.color: Theme.surface1
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Text { text: "󰂚"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: 16 }
                            Text { text: "Open Notification Center"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                barWindow.controlCenterOpen = false
                                root.barWindow.notificationCenterOpen = true
                            }
                        }
                    }
                }
            }
        }
    }
}
