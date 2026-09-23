# Não interferir em sessões do VS Code Remote
if set -q VSCODE_IPC_HOOK_CLI
    exit
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# --- GERAL ---
set -g fish_greeting ""

# --- ALIASES DE CONFIGURAÇÃO ---
alias configfish="nano ~/.config/fish/config.fish"
alias configterm="gnome-control-center keyboard shortcuts" # Abre atalhos do sistema
alias configkitty="nano ~/.config/kitty/kitty.conf"

# --- DOCKER ALIASES ---
alias docker-start="echo 'Iniciando o docker chefe 🐋'; sudo systemctl start docker"
alias docker-stop="echo 'Parando o docker 🐋'; sudo systemctl stop docker"
alias docker-status="systemctl status docker"
alias docker-restart="echo 'Reiniciando o docker... 🐋'; sudo systemctl restart docker"

alias docker-ps-no-port="docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.Status}}\t{{.Names}}'"

# --- Brinquedos ---
alias hollywood="docker run --rm -it hacker-hollywood"
alias genact="docker run --rm -it hacker-genact"

# --- Aliases SSHD ---
alias start-sshd="echo 'Iniciando o sshd meu nobre😶‍'; sudo systemctl start sshd"
alias stop-sshd="echo 'Encerrando o sshd meu nobre😶‍'; sudo systemctl stop sshd"

# --- Git & GitHub ---
alias gdash="echo 'Abrindo seu dashboard!'; gh dash"

# Garantir PATH básico do sistema (Fedora)
if not contains /usr/bin $PATH
    set -gx PATH /usr/local/bin /usr/bin /bin /usr/sbin /sbin
end

# Pnpm

set -Ux PNPM_HOME "$HOME/.local/share/pnpm"
fish_add_path "$PNPM_HOME"

# Flutter
if test -d $HOME/flutter/bin
    fish_add_path $HOME/flutter/bin
end

# Android Studio

set -Ux ANDROID_HOME $HOME/Android/Sdk
fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
fish_add_path $ANDROID_HOME/platform-tools

# Mise
set -gx PATH "/home/gab/.local/bin" $PATH
~/.local/bin/mise activate fish | source

# Rover (Graphql)
set -gx PATH "/home/gab/.rover/bin" $PATH
