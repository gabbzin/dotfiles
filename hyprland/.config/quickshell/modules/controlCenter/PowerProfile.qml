import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property bool hasPerf: PowerProfiles.hasPerformanceProfile

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: "󰐧"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Power Profile"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: {
                switch (PowerProfiles.profile) {
                    case PowerProfile.PowerSaver: return "Eco";
                    case PowerProfile.Balanced: return "Balanced";
                    case PowerProfile.Performance: return "Performance";
                    default: return "";
                }
            }
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS

        Repeater {
            model: [
                { label: "Eco", profile: PowerProfile.PowerSaver, icon: "󰌪" },
                { label: "Balanced", profile: PowerProfile.Balanced, icon: "󰾅" },
                { label: "Performance", profile: PowerProfile.Performance, icon: "󰓅" }
            ]
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: Theme.radiusS
                color: PowerProfiles.profile === modelData.profile ? Theme.accent : Theme.surface0
                border.color: PowerProfiles.profile === modelData.profile ? Theme.accent : Theme.surface1
                border.width: 1
                opacity: (modelData.profile === PowerProfile.Performance && !root.hasPerf) ? 0.4 : 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: modelData.icon
                        color: PowerProfiles.profile === modelData.profile ? Theme.crust : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                    Text {
                        text: modelData.label
                        color: PowerProfiles.profile === modelData.profile ? Theme.crust : Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: !(modelData.profile === PowerProfile.Performance && !root.hasPerf)
                    onClicked: PowerProfiles.profile = modelData.profile
                }
            }
        }
    }

    Text {
        text: "power-profiles-daemon required"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        visible: PowerProfiles.profile === undefined
    }
}
