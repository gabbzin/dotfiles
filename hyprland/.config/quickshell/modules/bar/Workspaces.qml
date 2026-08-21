import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
    id: root
    spacing: Theme.wsIndicatorSpacing

    // Quantidade de workspaces visíveis — facilmente configurável
    // Futuro: mapear para ícones custom via Theme ou AppMappings
    readonly property int workspaceCount: 5

    Repeater {
        model: root.workspaceCount

        delegate: Item {
            id: wsDelegate
            // id do workspace (1-indexed)
            readonly property int wsId: index + 1
            // lookup reativo — atualiza quando Hyprland.workspaces muda
            readonly property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)
            readonly property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
            readonly property bool isOccupied: ws !== undefined && ws !== null

            // container clicável
            implicitWidth: indicator.width
            implicitHeight: indicator.height

            Rectangle {
                id: indicator
                anchors.centerIn: parent
                // ativo = pill larga, ocupado = bolinha média, vazio = bolinha pequena/muted
                width: wsDelegate.isActive ? Theme.wsActiveWidth : Theme.wsIndicatorSize
                height: Theme.wsIndicatorSize
                radius: Theme.radiusRound
                color: {
                    if (wsDelegate.isActive) return Theme.accentActive;
                    if (wsDelegate.isOccupied) return Theme.accent;
                    return Theme.surface1;
                }
                border.width: wsDelegate.isActive ? 0 : 0
                // animação suave ao trocar
                Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                opacity: wsDelegate.isOccupied || wsDelegate.isActive ? 1.0 : 0.6
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                anchors.margins: -4 // área de clique maior que o indicador
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: Hyprland.dispatch("workspace " + wsDelegate.wsId)
            }
            // hover: brilho sutil
            states: State {
                when: wsMouse.containsMouse && !wsDelegate.isActive
                PropertyChanges { target: indicator; opacity: 0.85; scale: 1.15 }
            }
            transitions: Transition {
                NumberAnimation { properties: "opacity,scale"; duration: Theme.animFast; easing.type: Easing.OutCubic }
            }
        }
    }
}
