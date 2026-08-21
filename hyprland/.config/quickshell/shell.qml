import Quickshell
import QtQuick

ShellRoot {
    id: root

    // Fase 5 polish: Variants para multi-monitor será reintroduzido corretamente
    // Por enquanto, barra única no primary monitor (estável para validação)
    // TODO: Variants { model: Quickshell.screens; Bar { screen: modelData } } + required property var modelData em Bar
    Loader {
        active: true
        source: "modules/bar/Bar.qml"
    }
}
