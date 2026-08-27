import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

PanelWindow {
    id: root
    // OSD flutuante centralizado na parte inferior — overlay, não rouba foco
    anchors {
        bottom: true
    }
    margins {
        bottom: 80
    }
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    color: "transparent"
    // sempre visível como layer, controla conteúdo via visibleOsd/opacity
    visible: true

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    // estado
    property string mode: "volume" // "volume" | "brightness"
    property int volumePercent: 0
    property bool isMuted: false
    property int brightnessPercent: 50
    property bool visibleOsd: false

    implicitWidth: 380
    implicitHeight: 72

    // timer hide
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.visibleOsd = false
    }

    function showVolume(percent, muted) {
        root.mode = "volume";
        root.volumePercent = Math.max(0, Math.min(150, percent));
        root.isMuted = muted;
        root.visibleOsd = true;
        hideTimer.restart();
    }

    function showBrightness(percent) {
        root.mode = "brightness";
        root.brightnessPercent = Math.max(0, Math.min(100, percent));
        root.visibleOsd = true;
        hideTimer.restart();
    }

    // ── Watch volume via Pipewire ──
    readonly property var sink: Pipewire.defaultAudioSink
    property int lastVolume: -1
    property bool lastMuted: false

    function checkVolume(show) {
        if (!root.sink || !root.sink.audio) return;
        const v = root.sink.audio.volume;
        if (!isFinite(v)) return;
        const p = Math.round(v * 100);
        const m = root.sink.audio.muted;
        if (p !== root.lastVolume || m !== root.lastMuted) {
            if (show && root.lastVolume !== -1) root.showVolume(p, m);
            root.lastVolume = p;
            root.lastMuted = m;
        }
    }
    // init sem mostrar
    Timer { interval: 400; running: true; repeat: false; onTriggered: root.checkVolume(false) }

    // polling + signal
    Timer {
        id: volumeWatcher
        interval: 250
        running: true
        repeat: true
        onTriggered: root.checkVolume(true)
    }
    Connections {
        target: root.sink ? root.sink.audio : null
        ignoreUnknownSignals: true
        function onVolumeChanged() { root.checkVolume(true) }
        function onMutedChanged() { root.checkVolume(true) }
    }

    // ── Watch brightness via brightnessctl polling ──
    property int lastBrightness: -1
    function checkBrightness(show) {
        brightnessPollProc.running = true;
        brightnessPollProc._show = show;
    }
    Process {
        id: brightnessPollProc
        command: ["brightnessctl", "g"]
        property int _val: 0
        property bool _show: true
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim());
                if (isNaN(val)) return;
                brightnessPollProc._val = val;
                maxProc.running = true;
            }
        }
    }
    Process {
        id: maxProc
        command: ["brightnessctl", "m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const max = parseInt(text.trim());
                if (isNaN(max) || max <= 0) return;
                const val = brightnessPollProc._val;
                const show = brightnessPollProc._show;
                const p = Math.round((val / max) * 100);
                if (root.lastBrightness === -1) {
                    root.lastBrightness = p;
                    root.brightnessPercent = p;
                    return;
                }
                if (p !== root.lastBrightness) {
                    if (show) root.showBrightness(p);
                    root.lastBrightness = p;
                    root.brightnessPercent = p;
                }
            }
        }
    }
    Timer {
        id: brightnessWatcher
        interval: 700
        running: true
        repeat: true
        onTriggered: root.checkBrightness(true)
    }
    Timer { interval: 600; running: true; repeat: false; onTriggered: root.checkBrightness(false) }

    // UI
    Rectangle {
        anchors.fill: parent
        anchors.margins: 0
        color: Theme.bgAlt
        radius: Theme.radiusM
        border.color: Theme.barBorder
        border.width: 1
        opacity: root.visibleOsd ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM

            // ícone
            Text {
                text: root.mode === "volume"
                    ? (root.isMuted ? "󰝟" : root.volumePercent > 66 ? "󰕾" : root.volumePercent > 33 ? "󰖀" : "󰕿")
                    : "󰃠"
                color: root.mode === "volume" && root.isMuted ? Theme.muted : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 22
                Layout.alignment: Qt.AlignVCenter
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: root.mode === "volume" ? (root.isMuted ? "Volume • Muted" : "Volume") : "Brilho"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                }
                // barra
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Theme.surface0
                    Rectangle {
                        width: parent.width * (root.mode === "volume" ? Math.min(1, root.volumePercent/100) : root.brightnessPercent/100)
                        height: parent.height
                        radius: parent.radius
                        color: root.mode === "volume" && root.isMuted ? Theme.surface1 : Theme.accent
                        Behavior on width { NumberAnimation { duration: Theme.animFast } }
                    }
                }
            }
            Text {
                text: root.mode === "volume" ? (root.isMuted ? "Muted" : root.volumePercent + "%") : root.brightnessPercent + "%"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    Component.onCompleted: {
        // inicializa sem mostrar
        brightnessPollProc.running = true;
    }
