import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
    id: root
    spacing: Theme.spacingS

    // Toplevel ativo — reativo, null quando nenhum window focado
    readonly property var activeToplevel: Hyprland.activeToplevel

    // class/appId — tenta wayland.appId primeiro, fallback para lastIpcObject.class
    readonly property string wmClass: {
        if (!activeToplevel) return "";
        if (activeToplevel.wayland && activeToplevel.wayland.appId) return activeToplevel.wayland.appId;
        if (activeToplevel.lastIpcObject && activeToplevel.lastIpcObject.class) return activeToplevel.lastIpcObject.class;
        return "";
    }

    readonly property string wmTitle: activeToplevel ? (activeToplevel.title || "") : ""

    // Usa mapeamento centralizado — ícone e label amigável
    readonly property string appIcon: AppMappings.iconFor(wmClass)
    readonly property string appLabel: AppMappings.labelFor(wmClass, wmTitle)

    // Visibilidade — se não há janela, mostra placeholder discreto
    readonly property bool hasWindow: activeToplevel !== null && wmClass !== ""

    // Ícone (Nerd Font)
    Text {
        id: iconText
        visible: root.hasWindow
        text: root.appIcon
        color: Theme.subtext1
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        Layout.alignment: Qt.AlignVCenter
    }

    // Label — truncado para não estourar a barra
    Text {
        id: labelText
        text: root.hasWindow ? root.appLabel : "—"
        color: root.hasWindow ? Theme.text : Theme.muted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        elide: Text.ElideRight
        // limite para não empurrar CENTER; ajuste fino futuro em Theme
        Layout.maximumWidth: 260
        Layout.alignment: Qt.AlignVCenter
    }
}
