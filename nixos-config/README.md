# nixos-config — fonte NixOS dentro do dotfiles
# Etapa 1: modularização sem mudança de comportamento.

## Estrutura
- `flake.nix` fino (inputs + host)
- `hosts/nixos/default.nix` (hardware gerado + sistema + home)
- `modules/system/core.nix` (espelho do antigo configuration.nix)
- `home/gab/{default,caelestia,fish,kitty,packages}.nix` (espelho do bloco home-manager antigo)

## Usar sem mexer em /etc/nixos
```bash
sudo nixos-rebuild dry-run --flake ~/dotfiles/nixos-config#nixos
sudo nixos-rebuild switch --flake ~/dotfiles/nixos-config#nixos
```
Hardware fica em `hosts/nixos/hardware-configuration.nix` (copiado do gerado).
Atualizar após troca de disco/kernel com:
```bash
sudo nixos-generate-config --show-hardware-config > ~/dotfiles/nixos-config/hosts/nixos/hardware-configuration.nix
```

## Virar /etc/nixos em symlink (opcional, após validar dry-run)
```bash
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -s ~/dotfiles/nixos-config /etc/nixos
# hardware-configuration.nix continua em /etc/nixos.bak/hardware-configuration.nix
# copiar de volta se necessário: sudo cp /etc/nixos.bak/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
# OBS: hoje hosts/nixos importa por caminho absoluto /etc/nixos/hardware-configuration.nix,
# então o symlink ainda não é obrigatório.
```

## Etapa 2 (próxima)
- Declarar `~/.config/hypr/` a partir do Caelestia
- `hypr-vars.lua`: terminal=kitty, launcher=SUPER+D only
- `hypr-user.lua`: SUPER+Return, SUPER+Q, ALT+F4, Print, XF86
