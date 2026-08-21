import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root
    visible: activePlayer !== null
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    // Escolhe player mais relevante: playing > paused with title > any
    readonly property var activePlayer: {
        if (Mpris.players.values.length === 0) return null;
        // 1º: player tocando
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i];
            if (p.isPlaying) return p;
        }
        // 2º: player com título
        for (let i = 0; i < Mpris.players.values.length; i++) {
            const p = Mpris.players.values[i];
            if (p.trackTitle) return p;
        }
        // 3º: primeiro da lista
        return Mpris.players.values[0];
    }

    readonly property string trackTitle: activePlayer ? (activePlayer.trackTitle || "Unknown Title") : ""
    readonly property string trackArtist: activePlayer ? (activePlayer.trackArtist || "") : ""
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Theme.spacingS

        // Texto: "󰎈  After Dark — Mr.Kitty"  ou só título se sem artista
        Text {
            id: mediaText
            text: {
                if (!root.activePlayer) return "";
                const icon = root.isPlaying ? "󰎈 " : "󰏤 ";
                if (root.trackArtist) return icon + root.trackTitle + " — " + root.trackArtist;
                return icon + root.trackTitle;
            }
            color: Theme.subtext1
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            elide: Text.ElideRight
            Layout.maximumWidth: 300
            Layout.alignment: Qt.AlignVCenter
        }
    }

    // Preparado para controles futuros — clique alterna play/pause
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.activePlayer && root.activePlayer.canTogglePlaying
        onClicked: {
            if (root.activePlayer) root.activePlayer.togglePlaying();
        }
    }
}
