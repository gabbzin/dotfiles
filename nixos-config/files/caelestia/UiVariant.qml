// DIVERGÊNCIA NixOS (arquivo novo, copiado para services/ no build).
// Lê a variante de UI escolhida pelo script `ui-variant` (~/.local/state/caelestia/ui-variant).
// A barra fica no topo em TODAS as variantes (a variante só muda o visual: blur, opacidade...).
// Para voltar a ter a barra lateral numa variante, troque `topBar` por `name !== "default"`.
// Recarrega ao vivo quando o arquivo muda.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    property string name: "default"
    // Só vira true depois de ler (ou falhar em ler) o arquivo; evita montar a barra do layout errado no boot.
    property bool ready: false
    readonly property bool topBar: true

    FileView {
        path: `${Paths.state}/ui-variant`
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            root.name = text().trim() || "default";
            root.ready = true;
        }
        onLoadFailed: {
            root.name = "default";
            root.ready = true;
        }
    }
}
