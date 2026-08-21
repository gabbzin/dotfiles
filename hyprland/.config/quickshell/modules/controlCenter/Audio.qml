import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: Pipewire.ready && sink !== null && sink.audio !== null
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property real volume: ready ? sink.audio.volume : 0

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: root.muted ? "󰝟" : (root.volume > 0.66 ? "󰕾" : root.volume > 0.33 ? "󰖀" : "󰕿")
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (root.ready) sink.audio.muted = !sink.audio.muted }
            }
        }
        Text {
            text: "Volume"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }
        Item { Layout.fillWidth: true }
        Text {
            text: root.ready ? Math.round(root.volume * 100) + "%" : "—"
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            Layout.alignment: Qt.AlignVCenter
        }
        Text {
            text: root.muted ? "󰍭 Muted" : ""
            color: Theme.red
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            visible: root.muted
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Slider custom
    Rectangle {
        id: sliderBg
        Layout.fillWidth: true
        height: 28
        radius: Theme.radiusS
        color: Theme.surface0
        visible: root.ready

        Rectangle {
            id: sliderFill
            width: parent.width * root.volume
            height: parent.height
            radius: parent.radius
            color: root.muted ? Theme.surface1 : Theme.accent
            Behavior on width { NumberAnimation { duration: Theme.animFast } }
        }

        // thumb
        Rectangle {
            x: sliderFill.width - 8
            y: (parent.height - 16) / 2
            width: 16; height: 16; radius: 8
            color: Theme.text
            border.color: Theme.surface1
            border.width: 1
            visible: root.ready
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: updateVolume(mouse.x)
            onPositionChanged: if (pressed) updateVolume(mouse.x)
            function updateVolume(x) {
                if (!root.ready) return;
                const v = Math.max(0, Math.min(1, x / width));
                sink.audio.volume = v;
                if (sink.audio.muted && v > 0) sink.audio.muted = false;
            }
        }
    }

    Text {
        text: "No audio device"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        visible: !root.ready
    }
}
