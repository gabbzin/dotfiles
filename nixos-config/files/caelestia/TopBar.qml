// DIVERGÊNCIA NixOS (arquivo novo, copiado para modules/bar/ no build).
// Barra horizontal no topo, usada na variante "glass" (ver services/UiVariant.qml).
// Logo, workspaces, título da janela, bandeja, ícones de status, relógio e power.
// Os popouts (rede, bluetooth, bateria, áudio, bandeja, janela ativa) descem da barra:
// checkPopout(x) é chamado pelo Interactions com a posição horizontal do ponteiro.
pragma ComponentBehavior: Bound

import "components"
import "components/status"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import Caelestia.Config
import Caelestia.I18n
import qs.components
import qs.services
import qs.utils
import "popouts" as BarPopouts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts
    required property bool fullscreen

    readonly property color statusColour: Colours.palette.m3secondary

    readonly property string windowTitle: {
        const title = Hypr.activeToplevel?.title;
        if (!title)
            return Tr.trCtx("Desktop", "shown when no window is focused");
        if (Config.bar.activeWindow.compact) {
            const parts = title.split(/\s+[\-–—]\s+/);
            if (parts.length > 1)
                return parts[parts.length - 1].trim();
        }
        return title;
    }

    // Sem modo compacto na bandeja do topo: nada a recolher.
    function closeTray(): void {
    }

    function openPopout(name: string, centerFn: var): void {
        popouts.currentName = name;
        popouts.currentCenter = Qt.binding(centerFn);
        popouts.hasCurrent = true;
    }

    // px = posição horizontal do ponteiro dentro da barra.
    function checkPopout(px: real): void {
        const mid = root.height / 2;

        // Título da janela (hover só se configurado; senão abre por clique)
        const tp = titleText.mapFromItem(root, px, mid);
        if (tp.x >= 0 && tp.x <= Math.min(titleText.implicitWidth, titleText.width)) {
            if (Config.bar.popouts.activeWindow && Config.bar.activeWindow.showOnHover)
                openPopout("activewindow", () => titleText.mapToItem(root, Math.min(titleText.implicitWidth, titleText.width) / 2, 0).x);
            return;
        }

        // Bandeja do sistema
        const trp = trayRow.mapFromItem(root, px, mid);
        const trayHit = trayRow.childAt(trp.x, trp.y);
        if (trayHit && Config.bar.popouts.tray) {
            for (let i = 0; i < trayRepeater.count; i++) {
                const it = trayRepeater.itemAt(i);
                if (it === trayHit) {
                    openPopout(`traymenu${i}`, () => it.mapToItem(root, it.width / 2, 0).x);
                    return;
                }
            }
        }

        // Ícones de status
        const sp = statusRow.mapFromItem(root, px, mid);
        const icon = statusRow.childAt(sp.x, sp.y);
        if (icon && icon.name && Config.bar.popouts.statusIcons) {
            openPopout(icon.name, () => icon.mapToItem(root, icon.width / 2, 0).x);
            return;
        }

        popouts.hasCurrent = false;
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Tokens.padding.large
        anchors.rightMargin: Tokens.padding.large
        spacing: Tokens.spacing.large

        OsIcon {
            Layout.alignment: Qt.AlignVCenter
        }

        TopWorkspaces {
            Layout.alignment: Qt.AlignVCenter
            screen: root.screen
        }

        StyledText {
            id: titleText

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.windowTitle
            color: Colours.palette.m3primary
            elide: Text.ElideRight
            animate: true

            // Sem hover configurado, o clique no título abre/fecha o popout da janela ativa.
            MouseArea {
                anchors.fill: parent
                enabled: !Config.bar.activeWindow.showOnHover
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.popouts.hasCurrent)
                        root.popouts.hasCurrent = false;
                    else
                        root.openPopout("activewindow", () => titleText.mapToItem(root, Math.min(titleText.implicitWidth, titleText.width) / 2, 0).x);
                }
            }
        }

        // Bandeja do sistema
        Row {
            id: trayRow

            Layout.alignment: Qt.AlignVCenter
            spacing: Tokens.spacing.small

            Repeater {
                id: trayRepeater

                model: ScriptModel {
                    values: SystemTray.items.values.filter(i => i.status !== Status.Passive && !GlobalConfig.bar.tray.hiddenIcons.includes(i.id))
                }

                TrayItem {}
            }
        }

        // Ícones de status (mesma lista configurável do Config.bar.statusIcons)
        RowLayout {
            id: statusRow

            Layout.alignment: Qt.AlignVCenter
            spacing: Tokens.spacing.medium

            Repeater {
                model: ScriptModel {
                    values: root.Config.bar.statusIcons.values.filter(e => e.enabled)
                }

                DelegateChooser {
                    role: "id"

                    DelegateChoice {
                        roleValue: "audio"
                        delegate: EntryWrapper {
                            MaterialIcon {
                                animate: true
                                text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                                color: root.statusColour
                                fontStyle: Tokens.font.icon.medium
                                fill: 1
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "microphone"
                        delegate: EntryWrapper {
                            name: "audio" // o microfone abre o popout de áudio

                            MaterialIcon {
                                animate: true
                                text: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
                                color: root.statusColour
                                fontStyle: Tokens.font.icon.medium
                                fill: 1
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "kbLayout"
                        delegate: EntryWrapper {
                            StyledText {
                                animate: true
                                text: Hypr.kbLayout
                                color: root.statusColour
                                font: Tokens.font.mono.medium
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "network"
                        delegate: EntryWrapper {
                            MaterialIcon {
                                animate: true
                                text: Nmcli.activeEthernet ? "cable" : Nmcli.active ? Icons.getNetworkIcon(Nmcli.active.strength ?? 0) : "wifi_off"
                                color: root.statusColour
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "bluetooth"
                        delegate: EntryWrapper {
                            MaterialIcon {
                                animate: true
                                text: {
                                    if (!Bluetooth.defaultAdapter?.enabled) // qmllint disable unresolved-type
                                        return "bluetooth_disabled";
                                    if (Bluetooth.devices.values.some(d => d.connected)) // qmllint disable unresolved-type
                                        return "bluetooth_connected";
                                    return "bluetooth";
                                }
                                color: root.statusColour
                            }
                        }
                    }
                    DelegateChoice {
                        roleValue: "battery"
                        delegate: EntryWrapper {
                            BatteryStatus {
                                colour: root.statusColour
                            }
                        }
                    }
                }
            }
        }

        // Relógio horizontal: "sex 31  22:41"
        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: (Config.bar.clock.showDate ? Time.format("ddd d") + "  " : "") + Time.hourStr + ":" + Time.minuteStr + (Config.bar.clock.showSeconds ? ":" + Time.format("ss") : "")
            color: Colours.palette.m3tertiary
            font: Tokens.font.body.builders.small.scale(1.1).build()
        }

        Power {
            Layout.alignment: Qt.AlignVCenter
            screenState: root.screenState
        }
    }

    // Envolve cada ícone de status com o nome do popout correspondente (igual ao StatusIcons.qml).
    component EntryWrapper: Item {
        required property var modelData
        default property Item item
        property string name: modelData.id.toLowerCase()

        Layout.alignment: Qt.AlignVCenter
        implicitWidth: item?.implicitWidth ?? 0
        implicitHeight: item?.implicitHeight ?? 0

        children: item
    }
}
