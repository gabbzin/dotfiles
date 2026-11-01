# nixos-config — NixOS + Hyprland + Caelestia (flake)

## Estrutura
- `flake.nix` fino (inputs + host); `flake.lock` trava as versões validadas
- `hosts/nixos/default.nix` (hardware + sistema + home-manager)
- `hosts/nixos/hardware-configuration.nix` (gerado; fica no repo, não há mais `/etc/nixos`)
- `modules/system/{core,hardware,qylock}.nix` (sistema)
- `home/gab/*.nix` (home-manager: caelestia, hyprland, fish, kitty, nvim, editores, pacotes)
- `files/hypr/` (config Lua do Hyprland: base Caelestia + `variants/`)
- `files/caelestia/` (patch e QML do shell: barra no topo, ver abaixo)

## Aplicar
```bash
up                      # alias do fish: sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config
sudo nixos-rebuild dry-run --flake ~/dotfiles/nixos-config#nixos
```
**Sempre com `--flake ~/dotfiles/nixos-config`.** Não existe mais `/etc/nixos`: um
`nixos-rebuild` sem `--flake` agora falha de propósito. (Já aconteceu de ele construir
uma geração a partir da cópia antiga e "perder" Hyprland, aliases e wallpaper.)

Hardware: atualizar após troca de disco/kernel com
```bash
sudo nixos-generate-config --show-hardware-config > ~/dotfiles/nixos-config/hosts/nixos/hardware-configuration.nix
```

## Atualizar versões (com cuidado)
`update` (fish) atualiza só o nixpkgs; `update all` atualiza todos os inputs. Depois:
1. `sudo nixos-rebuild build --flake ~/dotfiles/nixos-config#nixos` (compila sem ativar)
2. `up` e **reiniciar para testar** (Wi-Fi, shell, wallpaper) mantendo a geração anterior
3. só então apagar as gerações antigas

Se o `topbar.patch` não aplicar depois de atualizar o `caelestia-shell`, o build falha
avisando: regerar o patch contra o fonte novo (ver abaixo).

## Variantes de UI (sem rebuild)
```bash
ui-variant default|glass|toggle|status   # visual: blur, opacidade, bordas, transparência do shell
ui-primary all|<monitor>|toggle|status   # monitor principal (o outro vira auxiliar, só apps)
```
- Estado em `~/.local/state/caelestia/ui-variant` e `~/.config/caelestia/monitors/<monitor>/shell.json`.
- Variantes do Hyprland em `files/hypr/variants/<nome>.lua`; do shell em `home/gab/caelestia.nix`.
- A tampa do notebook move a barra para o monitor externo (e volta ao abrir).
- Atalhos: `SUPER+U` alterna o monitor principal, `SUPER+SHIFT+F` maximiza/desflutua,
  `SUPER+SHIFT+U` tira do grupo.

## Barra no topo (patch no Caelestia)
O shell só tem barra lateral; a barra horizontal vem de `files/caelestia/`:
`topbar.patch` (BarWrapper, ContentWindow, Interactions, Regions, Panels, Exclusions,
ClipWrapper) + `TopBar.qml`, `TopWorkspaces.qml`, `UiVariant.qml`. Valem para todas as
variantes (`UiVariant.topBar`).

Regerar o patch contra um `caelestia-shell` novo: copiar o fonte do input para uma pasta
temporária, reaplicar as edições, e `diff -u --label a/<f> --label b/<f> orig/<f> new/<f>`
arquivo a arquivo. Testar sem rebuild rodando uma cópia do shell com
`quickshell -p <pasta>` (parar o serviço `caelestia` antes e religar depois).

## Limpar gerações antigas (só depois de validar a atual)
```bash
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
sudo nix-collect-garbage
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```
