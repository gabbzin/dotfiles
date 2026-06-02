function work
    # 1. Configurações
    set GITHUB_DIR "$HOME/GitHub"
    set USE_DOCKER false
    set PROJECT_NAME ""

    # 2. Processar argumentos
    for arg in $argv
        if test "$arg" = "-d"
            set USE_DOCKER true
        else
            set PROJECT_NAME "$arg"
        end
    end

    echo "🚀 A iniciar Modo Dev no Fedora..."

    # 3. Lógica do Docker
    if test "$USE_DOCKER" = "true"
        echo "🐳 A verificar serviço Docker..."
        if not systemctl is-active --quiet docker
            sudo systemctl start docker
            echo "✅ Docker iniciado."
        else
            echo "✅ Docker já estava em execução."
        end
    end

    # 4. Abrir Aplicações em segundo plano
    # O redirecionamento > /dev/null 2>&1 impede spam no terminal
    
    # Spotify
    if type -q spotify
        spotify > /dev/null 2>&1 &
    else if flatpak list | grep -q Spotify
        flatpak run com.spotify.Client > /dev/null 2>&1 &
    end

    # Chrome
    google-chrome > /dev/null 2>&1 &

    # 5. VS Code e Seleção de Pasta
    if test -z "$PROJECT_NAME"
        echo "📂 Seleciona o projeto:"
        # Usa o fzf para escolher
        set SELECTED_DIR (find "$GITHUB_DIR" -maxdepth 1 -type d | fzf)
        if test -n "$SELECTED_DIR"
            code "$SELECTED_DIR"
        end
    else
        set TARGET "$GITHUB_DIR/$PROJECT_NAME"
        if test -d "$TARGET"
            code "$TARGET"
        else
            echo "❌ Pasta '$PROJECT_NAME' não encontrada."
            # Fallback para o fzf caso te enganes no nome
            set SELECTED_DIR (find "$GITHUB_DIR" -maxdepth 1 -type d | fzf)
            if test -n "$SELECTED_DIR"
                code "$SELECTED_DIR"
            end
        end
    end
end
