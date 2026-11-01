// DIVERGÊNCIA NixOS (arquivo novo, copiado para modules/bar/components/ no build).
// Workspaces horizontais para a barra do topo (variante glass). Mesma seleção de
// workspaces do Workspaces.qml original, mas como "pílulas": a ativa fica alongada.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Caelestia
import Caelestia.Config
import qs.components
import qs.services

StyledRect {
    id: root

    required property ShellScreen screen

    readonly property HyprlandMonitor monitor: Hypr.monitorFor(screen)
    readonly property int activeWsId: monitor?.activeWorkspace?.id ?? 1
    readonly property int shown: Math.max(1, Config.bar.workspaces.shown)

    readonly property var wsIds: {
        if (Config.bar.workspaces.showUnoccupied) {
            const offset = Math.floor((activeWsId - 1) / shown) * shown;
            return Array.from({
                length: shown
            }, (_, i) => offset + i + 1);
        }

        const allMonitors = !Config.bar.workspaces.perMonitor;
        const ignoredTags = GlobalConfig.bar.workspaces.ignoredTags;
        const workspaces = Hypr.workspaces.values.filter(w => w.id > 0 && (allMonitors || w.monitor === root.monitor) && (w.id === activeWsId || w.toplevels.values.some(t => !Hypr.isToplevelIgnored(t, ignoredTags))));
        const currentIdx = workspaces.findIndex(w => w.id === activeWsId);
        if (currentIdx < 0)
            return [];

        const end = CUtils.clamp(currentIdx + 1, Math.min(shown, workspaces.length), workspaces.length);
        const start = Math.max(0, end - shown);
        return workspaces.slice(start, end).map(w => w.id);
    }

    function occupied(id: int): bool {
        const ws = Hypr.workspaces.values.find(w => w.id === id);
        return (ws?.toplevels.values.length ?? 0) > 0;
    }

    color: Colours.tPalette.m3surfaceContainer
    radius: Tokens.rounding.full

    implicitWidth: row.implicitWidth + Tokens.padding.medium * 2
    implicitHeight: Math.round(Tokens.sizes.bar.innerWidth * 0.7)

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Tokens.spacing.small

        Repeater {
            model: root.wsIds

            Rectangle {
                id: pill

                required property int modelData

                readonly property bool active: modelData === root.activeWsId

                width: active ? Tokens.sizes.bar.innerWidth * 0.7 : height
                height: Tokens.sizes.bar.innerWidth * 0.3
                radius: height / 2
                anchors.verticalCenter: parent.verticalCenter
                color: active ? Colours.palette.m3primary : root.occupied(modelData) ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outlineVariant

                Behavior on width {
                    Anim {}
                }

                Behavior on color {
                    CAnim {}
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Tokens.spacing.small
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hypr.dispatch(Hypr.usingLua ? `hl.dsp.focus({ workspace = "${pill.modelData}" })` : `workspace ${pill.modelData}`)
                }
            }
        }
    }
}
