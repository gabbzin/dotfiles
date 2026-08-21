pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // class (lowercase) → [ícone Nerd Font, label amigável]
    // class vem de HyprlandToplevel.wmClass / appId
    readonly property var mappings: ({
        "code": ["󰨞", "VS Code"],
        "code-url-handler": ["󰨞", "VS Code"],
        "firefox": ["󰈹", "Firefox"],
        "brave-browser": ["󰈹", "Brave"],
        "google-chrome": ["󰈹", "Chrome"],
        "spotify": ["󰓇", "Spotify"],
        "discord": ["󰙯", "Discord"],
        "vesktop": ["󰙯", "Discord"],
        "kitty": ["󰆍", "Kitty"],
        "ghostty": ["󰆍", "Ghostty"],
        "wezterm": ["󰆍", "WezTerm"],
        "foot": ["󰆍", "Foot"],
        "thunar": ["󰉋", "Thunar"],
        "nautilus": ["󰉋", "Files"],
        "org.gnome.nautilus": ["󰉋", "Files"],
        "nvim": ["", "Neovim"],
        "postman": ["󰚌", "Postman"],
        "obsidian": ["󱓧", "Obsidian"],
        "dbeaver": ["", "DBeaver"],
        "pycharm": ["󱃖", "PyCharm"],
        "jetbrains-pycharm": ["󱃖", "PyCharm"],
        "steam": ["", "Steam"],
        "lutris": ["", "Lutris"],
        "mpv": ["󰕼", "MPV"],
        "vlc": ["󰕼", "VLC"],
        "zathura": ["", "Zathura"]
    })

    readonly property string defaultIcon: "󰣆"
    readonly property string defaultLabel: ""

    function iconFor(wmClass: string): string {
        if (!wmClass) return defaultIcon;
        const key = wmClass.toLowerCase();
        const entry = mappings[key];
        if (entry) return entry[0];
        // fallback: tenta sem sufixo de domínio
        const shortKey = key.split(".").pop();
        const shortEntry = mappings[shortKey];
        if (shortEntry) return shortEntry[0];
        return defaultIcon;
    }

    function labelFor(wmClass: string, fallbackTitle: string): string {
        if (!wmClass) return fallbackTitle || defaultLabel;
        const key = wmClass.toLowerCase();
        const entry = mappings[key];
        if (entry) return entry[1];
        const shortKey = key.split(".").pop();
        const shortEntry = mappings[shortKey];
        if (shortEntry) return shortEntry[1];
        // usa título como fallback (truncado fora daqui)
        return fallbackTitle || wmClass;
    }
}
