pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // ── Cores (Catppuccin Mocha - hyprland/modules/colors.lua) ──
    readonly property color bg: "#1e1e2e"
    readonly property color bgAlt: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay1: "#7f849c"
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#bac2de"
    readonly property color subtext0: "#a6adc8"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"
    readonly property color mauve: "#cba6f7"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color red: "#f38ba8"
    readonly property color peach: "#fab387"
    readonly property color teal: "#94e2d5"

    // semânticas — barBg translúcido para blur do Hyprland (decoration.blur.enabled)
    readonly property color barBg: "#1e1e2eF2"   // 95% opaco — blur visível
    readonly property color barFg: text
    readonly property color barBorder: surface0
    readonly property color accent: blue
    readonly property color accentHover: "#89b4faCC"
    readonly property color accentActive: mauve
    readonly property color muted: overlay0
    readonly property color hoverOverlay: "#31324488" // overlay sutil para hover states

    // ── Tipografia ──
    readonly property string fontFamily: "CaskaydiaCove Nerd Font"
    readonly property string fontFamilyMono: "CaskaydiaCove Nerd Font Mono"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 14

    // ── Barra ──
    readonly property int barHeight: 32
    readonly property int barSpacing: 12
    readonly property int barPaddingH: 12
    readonly property int barPaddingV: 4
    readonly property int barRadius: 0
    readonly property int barBorderWidth: 1

    // ── Espaçamento geral ──
    readonly property int spacingXS: 4
    readonly property int spacingS: 8
    readonly property int spacingM: 12
    readonly property int spacingL: 16
    readonly property int spacingXL: 24

    // ── Bordas / radius ──
    readonly property int radiusS: 6
    readonly property int radiusM: 10
    readonly property int radiusL: 14
    readonly property int radiusRound: 999

    // ── Animação ──
    readonly property int animFast: 120
    readonly property int animNormal: 200
    readonly property int animSlow: 300

    // ── Clock formato ──
    readonly property string clockFormat: "ddd, dd MMM • hh:mm"

    // ── Workspaces ──
    readonly property int wsIndicatorSize: 8
    readonly property int wsIndicatorSpacing: 8
    readonly property int wsActiveWidth: 24
}
