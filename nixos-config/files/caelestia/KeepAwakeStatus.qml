// DIVERGÊNCIA NixOS (arquivo novo, copiado para modules/bar/components/status/ no build).
// Ícone "manter acordado" (estilo caffeine do GNOME) nos status da barra. Clique alterna
// o RuntimeState.inhibitIdle do próprio Caelestia (o mesmo switch do painel de utilidades e
// do IPC `idleInhibitor`; o antigo singleton IdleInhibitor deixou de existir no upstream). Ligado = café cheio na cor de destaque; desligado = apagado.
import QtQuick
import Caelestia.State
import qs.components
import qs.services

MaterialIcon {
    required property color colour

    animate: true
    text: "coffee"
    fill: RuntimeState.inhibitIdle ? 1 : 0
    color: RuntimeState.inhibitIdle ? Colours.palette.m3primary : colour
    opacity: RuntimeState.inhibitIdle ? 1 : 0.5

    Behavior on opacity {
        Anim {
            type: Anim.StandardSmall
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: RuntimeState.inhibitIdle = !RuntimeState.inhibitIdle
    }
}
