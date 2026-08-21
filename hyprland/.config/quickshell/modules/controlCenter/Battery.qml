import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property var device: UPower.displayDevice
    readonly property bool ready: device && device.ready
    readonly property int percent: ready ? Math.round(device.percentage * 100) : 0
    readonly property bool charging: ready ? (device.state === UPowerDeviceState.Charging) : false
    readonly property bool onBattery: UPower.onBattery
    readonly property string stateText: {
        if (!ready) return "Unknown";
        switch (device.state) {
            case UPowerDeviceState.Charging: return "Charging";
            case UPowerDeviceState.Discharging: return "Discharging";
            case UPowerDeviceState.FullyCharged: return "Fully charged";
            case UPowerDeviceState.Empty: return "Empty";
            default: return "Unknown";
        }
    }
    readonly property string icon: {
        if (!ready) return "󰂑";
        if (charging) return "󰂄";
        if (percent > 80) return "󰁹";
        if (percent > 60) return "󰂂";
        if (percent > 40) return "󰁾";
        if (percent > 20) return "󰁼";
        return "󰁺";
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: root.icon
            color: root.percent < 20 && !root.charging ? Theme.red : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Battery"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: root.ready ? root.percent + "%" : "—"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    // barra de progresso
    Rectangle {
        Layout.fillWidth: true
        height: 8
        radius: 4
        color: Theme.surface0
        visible: root.ready
        Rectangle {
            width: parent.width * (root.percent / 100)
            height: parent.height
            radius: parent.radius
            color: root.charging ? Theme.green : (root.percent < 20 ? Theme.red : Theme.accent)
            Behavior on width { NumberAnimation { duration: Theme.animFast } }
        }
    }

    Text {
        text: root.ready ? (root.stateText + (onBattery ? " • On battery" : " • On AC")) : "No battery"
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        visible: root.ready
    }

    Text {
        text: "No battery detected (desktop)"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        visible: !root.ready
    }
}
