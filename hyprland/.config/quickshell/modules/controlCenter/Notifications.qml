import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property var server: NotificationServer

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: "󰂚"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Notifications"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: server && server.dnd ? "DND On" : "DND Off"
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
        // Toggle DND — NotificationServer tem `inhibited` ou similar dependendo da versão
        // Fallback: apenas visual por enquanto; Fase 4 implementa histórico
        Rectangle {
            width: 44; height: 24; radius: 12
            color: (server && server.inhibited) ? Theme.accent : Theme.surface0
            border.color: Theme.surface1
            Rectangle {
                width: 18; height: 18; radius: 9
                color: Theme.text
                x: (server && server.inhibited) ? parent.width - width - 3 : 3
                y: 3
                Behavior on x { NumberAnimation { duration: Theme.animFast } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // API varia: algumas versões expõem `inhibited` writable, outras `dnd`
                    if (server) {
                        if ("inhibited" in server) server.inhibited = !server.inhibited;
                        else console.log("DND toggle — implementar na Fase 4");
                    }
                }
            }
        }
    }

    Text {
        text: "Notification Center — Fase 4"
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
    Text {
        text: "Histórico, ações e DND completo virão no Notification Center"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }
}
