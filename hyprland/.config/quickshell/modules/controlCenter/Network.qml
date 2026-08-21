import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property var wifiDevice: {
        for (const d of Networking.devices.values) {
            if (d.networks !== undefined) return d;
        }
        return null;
    }
    readonly property var wiredDevice: {
        for (const d of Networking.devices.values) {
            if (d.networks === undefined) return d;
        }
        return null;
    }
    readonly property var connectedWifi: {
        if (!wifiDevice) return null;
        for (const n of wifiDevice.networks.values) {
            if (n.connected) return n;
        }
        return null;
    }
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wiredConnected: wiredDevice ? (wiredDevice.connected ?? false) : false

    // Header Wi-Fi
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: root.wifiEnabled ? "󰖩" : "󰖪"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Wi-Fi"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        // Toggle Wi-Fi
        Rectangle {
            width: 44; height: 24; radius: 12
            color: root.wifiEnabled ? Theme.accent : Theme.surface0
            border.color: Theme.surface1
            Rectangle {
                width: 18; height: 18; radius: 9
                color: Theme.text
                x: root.wifiEnabled ? parent.width - width - 3 : 3
                y: 3
                Behavior on x { NumberAnimation { duration: Theme.animFast } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }
    }

    Text {
        text: root.connectedWifi ? ("Connected: " + (root.connectedWifi.ssid || root.connectedWifi.name || "Unknown")) : (root.wifiEnabled ? "Not connected" : "Wi-Fi disabled")
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        elide: Text.ElideRight
        Layout.fillWidth: true
    }

    // Lista de redes — limitada a 4 para não estourar o popup
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: root.wifiEnabled
        Repeater {
            model: {
                if (!root.wifiDevice) return [];
                // filtra redes visíveis, ordena por intensidade
                const nets = [...root.wifiDevice.networks.values];
                nets.sort((a,b) => (b.signal||0) - (a.signal||0));
                return nets.slice(0,4);
            }
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS
                Text {
                    text: modelData.connected ? "󰤨" : "󰤯"
                    color: modelData.connected ? Theme.accent : Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                }
                Text {
                    text: modelData.ssid || modelData.name || "Hidden"
                    color: modelData.connected ? Theme.text : Theme.subtext1
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: modelData.signal ? modelData.signal + "%" : ""
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
                // futuro: onClick conectar
            }
        }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.surface0 }

    // Ethernet
    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: root.wiredConnected ? "󰈀" : "󰈂"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Ethernet"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: root.wiredConnected ? "Connected" : "Disconnected"
            color: root.wiredConnected ? Theme.green : Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
