# Neovim completo (LazyVim + colorscheme Caelestia que segue o wallpaper).
# Deps de build/busca do Telescope/Treesitter versionadas em packages.nix.
{ ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile."nvim" = {
    source = ../../files/nvim;
    recursive = true;
  };
}
