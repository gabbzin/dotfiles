# Kitty = seu (Cherry Midnight + Caskaydia Cove NF). Espelho do flake antigo.
# TODO Etapa 3: trocar shell hardcoded por path nix e importar current-theme.conf.
{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      # Nome exato da família no fc-list (sem espaço em "CaskaydiaCove").
      name = "CaskaydiaCove NF";
    };

    settings = {
      font_size = "12.5";
      shell = "${pkgs.fish}/bin/fish";
      initial_window_width = "75c";
      initial_window_height = "25c";
      allow_remote_control = "socket-only";
      draw_minimal_borders = "yes";
      hide_window_decorations = "titlebar-only";
    };

    extraConfig = ''
      # Cherry Midnight

      foreground #bdc3df
      background #101017

      selection_foreground #101017
      selection_background #bdc3df

      cursor #bdc3df
      cursor_text_color #101017

      url_color #85b6ff

      tab_bar_background #101017

      active_tab_foreground #bdc3df
      active_tab_background #33333f

      inactive_tab_foreground #dedeff
      inactive_tab_background #101017

      color0  #33333f
      color1  #ff568e
      color2  #64de83
      color3  #efff73
      color4  #73a9ff
      color5  #946ff7
      color6  #62c6da
      color7  #dedeff

      color8  #43435a
      color9  #ff69a2
      color10 #73de8a
      color11 #f3ff85
      color12 #85b6ff
      color13 #a481f7
      color14 #71c2d9
      color15 #ebebff

      map ctrl+backspace send_text all \x17
    '';
  };
}
