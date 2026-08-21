import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property bool hasAdapter: adapter !== null

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: root.powered ? "󰂯" : "󰂲"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Bluetooth"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Rectangle {
            width: 44; height: 24; radius: 12
            color: root.powered ? Theme.accent : Theme.surface0
            border.color: Theme.surface1
            opacity: root.hasAdapter ? 1 : 0.5
            Rectangle {
                width: 18; height: 18; radius: 9
                color: Theme.text
                x: root.powered ? parent.width - width - 3 : 3
                y: 3
                Behavior on x { NumberAnimation { duration: Theme.animFast } }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: root.hasAdapter
                onClicked: adapter.enabled = !adapter.enabled
            }
        }
    }

    Text {
        text: !root.hasAdapter ? "No adapter found" : (root.powered ? "On" : "Off")
        color: Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }

    // Lista de devices conectados — máx 4
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: root.powered
        Repeater {
            model: {
                const devs = [...Bluetooth.devices.values];
                // prioriza conectados
                devs.sort((a,b) => (b.connected?1:0) - (a.connected?1:0));
                return devs.slice(0,4);
            }
            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS
                Text {
                    text: modelData.connected ? "󰂱" : "󰂯"
                    color: modelData.connected ? Theme.accent : Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                }
                Text {
                    text: modelData.name || modelData.address || "Unknown"
                    color: Theme.subtext1
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: modelData.connected ? "Connected" : "Paired"
                    color: modelData.connected ? Theme.green : Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
        Text {
            text: "No devices"
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            visible: Bluetooth.devices.values.length === 0
        }
    }
}
