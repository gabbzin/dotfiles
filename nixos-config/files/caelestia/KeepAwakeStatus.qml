// DIVERGÊNCIA NixOS (arquivo novo, copiado para modules/bar/components/status/ no build).
// Ícone "manter acordado" (estilo caffeine do GNOME) nos status da barra. Clique alterna
// o serviço IdleInhibitor do próprio Caelestia (o mesmo switch do painel de utilidades e
// do IPC `idleInhibitor`). Ligado = café cheio na cor de destaque; desligado = apagado.
import QtQuick
import qs.components
import qs.services

MaterialIcon {
    required property color colour

    animate: true
    text: "coffee"
    fill: IdleInhibitor.enabled ? 1 : 0
    color: IdleInhibitor.enabled ? Colours.palette.m3primary : colour
    opacity: IdleInhibitor.enabled ? 1 : 0.5

    Behavior on opacity {
        Anim {
            type: Anim.StandardSmall
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: IdleInhibitor.enabled = !IdleInhibitor.enabled
    }
}
