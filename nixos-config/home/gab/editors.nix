# Zed + VSCode com SUAS configs (eram defaults até aqui: nada deployado).
# Symlinks REAIS via activation (o xdg.configFile materializa out-of-store
# no store = read-only = EROFS no save). Edições pela UI caem direto no
# repo versionado — commita quando quiser travar.
# Estado (workspaceStorage, themes gerados) fica fora.
{ lib, ... }:

let
  files = "/home/gab/dotfiles/nixos-config/files";
  links = [
    # Zed (themes/caelestia.json gerado pelo scheme continua intocado)
    { dest = "zed/settings.json"; src = "${files}/zed/settings.json"; }
    { dest = "zed/keymap.json"; src = "${files}/zed/keymap.json"; }
    # VSCode Default (mcp sem segredos)
    { dest = "Code/User/settings.json"; src = "${files}/vscode/settings.json"; }
    { dest = "Code/User/keybindings.json"; src = "${files}/vscode/keybindings.json"; }
    { dest = "Code/User/mcp.json"; src = "${files}/vscode/mcp.json"; }
    # VSCode 4 perfis (configs + state de registro)
    { dest = "Code/User/profiles/18d82f/settings.json"; src = "${files}/vscode/profiles/18d82f/settings.json"; }
    { dest = "Code/User/profiles/18d82f/keybindings.json"; src = "${files}/vscode/profiles/18d82f/keybindings.json"; }
    { dest = "Code/User/profiles/18d82f/mcp.json"; src = "${files}/vscode/profiles/18d82f/mcp.json"; }
    { dest = "Code/User/profiles/18d82f/globalStorage/state.vscdb"; src = "${files}/vscode/profiles/18d82f/globalStorage/state.vscdb"; }
    { dest = "Code/User/profiles/332785d1/settings.json"; src = "${files}/vscode/profiles/332785d1/settings.json"; }
    { dest = "Code/User/profiles/332785d1/mcp.json"; src = "${files}/vscode/profiles/332785d1/mcp.json"; }
    { dest = "Code/User/profiles/332785d1/globalStorage/state.vscdb"; src = "${files}/vscode/profiles/332785d1/globalStorage/state.vscdb"; }
    { dest = "Code/User/profiles/4ba6ade9/settings.json"; src = "${files}/vscode/profiles/4ba6ade9/settings.json"; }
    { dest = "Code/User/profiles/4ba6ade9/keybindings.json"; src = "${files}/vscode/profiles/4ba6ade9/keybindings.json"; }
    { dest = "Code/User/profiles/4ba6ade9/globalStorage/state.vscdb"; src = "${files}/vscode/profiles/4ba6ade9/globalStorage/state.vscdb"; }
    { dest = "Code/User/profiles/5232c4b4/settings.json"; src = "${files}/vscode/profiles/5232c4b4/settings.json"; }
    { dest = "Code/User/profiles/5232c4b4/keybindings.json"; src = "${files}/vscode/profiles/5232c4b4/keybindings.json"; }
    { dest = "Code/User/profiles/5232c4b4/mcp.json"; src = "${files}/vscode/profiles/5232c4b4/mcp.json"; }
    { dest = "Code/User/profiles/5232c4b4/globalStorage/state.vscdb"; src = "${files}/vscode/profiles/5232c4b4/globalStorage/state.vscdb"; }
  ];
in
{
  home.activation.editorsOutOfStore = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    builtins.concatStringsSep "\n" (
      map (l: ''
        $DRY_RUN_CMD mkdir -p "$HOME/.config/$(dirname ${l.dest})"
        $DRY_RUN_CMD ln -sfn ${l.src} "$HOME/.config/${l.dest}"
      '') links
    )
  );
}
