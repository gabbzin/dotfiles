import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

ColumnLayout {
    id: root
    spacing: Theme.spacingS
    Layout.fillWidth: true

    property int brightness: 50
    property int maxBrightness: 100
    property bool ready: false

    // ── Lógica brightnessctl ──
    // dependência externa documentada: brightnessctl (já presente via dnf)
    // Chamada via Process a cada interação; sem polling contínuo para economizar.
    Process {
        id: getProcess
        command: ["brightnessctl", "g"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                // brightnessctl g retorna valor absoluto; precisamos do max para %
                // Simplificação: assume max 255 ou usa `m`. Para robustez, lê arquivo max diretamente.
                const val = parseInt(text.trim());
                if (!isNaN(val)) {
                    // tenta obter max via segundo processo se ainda não temos
                    if (root.maxBrightness <= 100) {
                        // usa 255 como fallback comum, mas busca real async
                        maxProcess.running = true;
                    }
                    // enquanto max não vem, estima com 255
                    const max = root.maxBrightness > 100 ? root.maxBrightness : 255;
                    root.brightness = Math.round((val / max) * 100);
                    root.ready = true;
                }
            }
        }
    }

    Process {
        id: maxProcess
        command: ["brightnessctl", "m"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const max = parseInt(text.trim());
                if (!isNaN(max) && max > 0) {
                    root.maxBrightness = max;
                    // recalcula %
                    getProcess.running = true;
                }
            }
        }
    }

    Process {
        id: setProcess
        // command setado dinamicamente
    }

    function refresh() {
        getProcess.running = true;
    }

    function setBrightness(percent) {
        const val = Math.round((percent / 100) * root.maxBrightness);
        setProcess.command = ["brightnessctl", "s", val.toString()];
        setProcess.running = true;
        root.brightness = percent;
    }

    Component.onCompleted: refresh()

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingS
        Text {
            text: "󰃠"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 18
        }
        Text {
            text: "Brightness"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
        }
        Item { Layout.fillWidth: true }
        Text {
            text: root.ready ? root.brightness + "%" : "—"
            color: Theme.subtext0
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    Rectangle {
        id: sliderBg
        Layout.fillWidth: true
        height: 28
        radius: Theme.radiusS
        color: Theme.surface0

        Rectangle {
            width: parent.width * (root.brightness / 100)
            height: parent.height
            radius: parent.radius
            color: Theme.accent
            Behavior on width { NumberAnimation { duration: Theme.animFast } }
        }
        Rectangle {
            x: parent.width * (root.brightness / 100) - 8
            y: (parent.height - 16) / 2
            width: 16; height: 16; radius: 8
            color: Theme.text
            border.color: Theme.surface1
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: update(mouse.x)
            onPositionChanged: if (pressed) update(mouse.x)
            function update(x) {
                const p = Math.max(5, Math.min(100, Math.round((x / width) * 100)));
                setBrightness(p);
            }
        }
    }

    Text {
        text: "requires brightnessctl"
        color: Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        visible: !root.ready
    }
}
