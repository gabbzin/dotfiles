import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import Quickshell.Networking
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
    id: root
    spacing: Theme.spacingS

    // ── Wi-Fi / Ethernet ──
    readonly property var wifiDevice: {
        for (const dev of Networking.devices.values) {
            // WifiDevice tem propriedade isWifi? Checa por networks
            if (dev.networks !== undefined) return dev;
        }
        return null;
    }
    readonly property var wiredDevice: {
        for (const dev of Networking.devices.values) {
            if (dev.networks === undefined) return dev;
        }
        return null;
    }
    readonly property bool wifiConnected: {
        if (!wifiDevice) return false;
        for (const net of wifiDevice.networks.values) {
            if (net.connected) return true;
        }
        return wifiDevice.connected ?? false;
    }
    readonly property bool wiredConnected: wiredDevice ? (wiredDevice.connected ?? false) : false

    // ── Bluetooth ──
    readonly property bool bluetoothEnabled: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
    readonly property bool bluetoothConnected: {
        for (const d of Bluetooth.devices.values) {
            if (d.connected) return true;
        }
        return false;
    }

    // ── Bateria ──
    readonly property var displayDevice: UPower.displayDevice
    readonly property bool batteryReady: displayDevice && displayDevice.ready
    readonly property int batteryPercent: batteryReady ? Math.round(displayDevice.percentage * 100) : 0
    readonly property bool isCharging: batteryReady ? (displayDevice.state === UPowerDeviceState.Charging) : false

    // ── Áudio ──
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool audioMuted: sink && sink.audio ? sink.audio.muted : false
    readonly property int audioVolume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    // Ícones — compactos, Nerd Font
    Text {
        id: wifiIcon
        text: root.wifiConnected ? "󰖩" : (root.wiredConnected ? "󰈀" : "󰖪")
        color: (root.wifiConnected || root.wiredConnected) ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        id: btIcon
        text: root.bluetoothEnabled ? (root.bluetoothConnected ? "󰂯" : "󰂯") : "󰂲"
        color: root.bluetoothEnabled ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
        visible: Bluetooth.defaultAdapter !== null
    }

    Text {
        id: audioIcon
        text: root.audioMuted ? "󰝟" : (root.audioVolume > 66 ? "󰕾" : root.audioVolume > 33 ? "󰖀" : "󰕿")
        color: root.audioMuted ? Theme.muted : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
        visible: root.sink !== null
    }

    Text {
        id: batteryIcon
        // ícone varia por % e charging
        text: {
            if (!root.batteryReady) return "";
            if (root.isCharging) return "󰂄";
            if (root.batteryPercent > 80) return "󰁹";
            if (root.batteryPercent > 60) return "󰂂";
            if (root.batteryPercent > 40) return "󰁾";
            if (root.batteryPercent > 20) return "󰁼";
            return "󰁺";
        }
        color: root.batteryPercent < 20 && !root.isCharging ? Theme.red : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
        visible: root.batteryReady
    }

    Text {
        id: batteryText
        text: root.batteryReady ? root.batteryPercent + "%" : ""
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
        visible: root.batteryReady
    }

    // Notificação — contagem via NotificationServer
    readonly property int notifCount: NotificationServer.trackedNotifications ? NotificationServer.trackedNotifications.values.length : 0
    Item {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: notifRow.implicitWidth
        implicitHeight: notifRow.implicitHeight
        visible: true
        RowLayout {
            id: notifRow
            anchors.centerIn: parent
            spacing: 2
            Text {
                id: notifIcon
                text: root.notifCount > 0 ? "󰂚" : "󰂜"
                color: root.notifCount > 0 ? Theme.accent : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: root.notifCount > 0 ? root.notifCount.toString() : ""
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                Layout.alignment: Qt.AlignVCenter
                visible: root.notifCount > 0
            }
        }
    }
}
