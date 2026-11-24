# Multiplexer e busca no terminal: tmux, fzf, zoxide, eza, bat.
{ pkgs, ... }:

{
  # Cheat sheet acessível dentro do tmux (F1) e fora (tmux-help)
  xdg.configFile."tmux/cheatsheet.txt".source = ../../files/tmux/cheatsheet.txt;

  programs.tmux = {
    enable = true;
    shortcut = "a"; # prefixo Ctrl+a
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    terminal = "tmux-256color";
    historyLimit = 50000;
    aggressiveResize = true;
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank # copia com wl-clipboard (wayland)
      resurrect # salva/restaura sessões (prefixo + Ctrl+s / Ctrl+r)
      continuum # autosave a cada 15 min
      tmux-which-key # menu interativo ao apertar o prefixo
    ];

  extraConfig = ''
      # Cores reais (true color) dentro do kitty
      set -as terminal-overrides ",*:Tc"

      # Splits no estilo visual, herdando o diretório atual
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Navegação entre panes estilo vim
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Recarregar a config
      bind r source-file ~/.tmux.conf \; display "Config recarregada"

      # Cheat sheet (F1 abre popup)
      bind F1 display-popup -w 90% -h 90% -E "less -K ~/.config/tmux/cheatsheet.txt"

      # Renumerar janelas ao fechar
      set -g renumber-windows on
      set -g set-clipboard on

      # Persistência de sessões (resurrect + continuum)
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-processes 'ssh "~btop->btop" "~lazygit->lazygit"'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'

      # Barra de status
      set -g status-position bottom
      set -g status-style 'bg=default,fg=#cdd6f4'
      set -g status-left '#[fg=#89b4fa,bold] #S #[fg=#6c7086]| '
      set -g status-right '#[fg=#6c7086]%d/%m %H:%M '
      set -g window-status-current-style 'fg=#a6e3a1,bold'
    '';
  };

  # Ctrl+R = histórico fuzzy, Ctrl+T = arquivos fuzzy (com fd)
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--border"
    ];
    fileWidget.command = "${pkgs.fd}/bin/fd --type f --hidden --exclude .git";
  };

  # z (e zi) para pular para pastas que você já visitou
  programs.zoxide.enable = true;

  # ls moderno com ícones + status git (aliases ll/la/tree automáticos)
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  # cat com syntax highlight
  programs.bat.enable = true;
}
