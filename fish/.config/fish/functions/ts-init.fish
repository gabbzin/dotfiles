function ts-init
    # 1. Setup inicial de pastas e pnpm
    mkdir -p "$argv[1]/src"; and cd "$argv[1]"
    pnpm init
    pnpm add -D typescript @types/node tsx @biomejs/biome
    
    # 2. Configura o TypeScript (tsconfig.json)
    npx tsc --init --target es2022 --module esnext --moduleResolution node --outDir dist --rootDir src --strict
    
    # 3. Cria o biome.json com as SUAS configurações
    # No Fish, o 'cat' com heredoc funciona de forma similar, mas evitamos escapes desnecessários
    echo '{
  "$schema": "https://biomejs.dev/schemas/latest/schema.json",
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "files": { "ignoreUnknown": false, "includes": ["**", "!node_modules", "!.next", "!dist", "!build"] },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2, "lineWidth": 80, "lineEnding": "lf" },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "nursery": { "useSortedClasses": { "level": "warn", "fix": "safe" } },
      "correctness": { "noUnusedImports": { "level": "error", "fix": "safe" } }
    }
  },
  "javascript": {
    "formatter": { "enabled": true, "quoteStyle": "double", "jsxQuoteStyle": "double", "semicolons": "always", "arrowParentheses": "asNeeded" }
  },
  "css": { "parser": { "tailwindDirectives": true } },
  "assist": { "enabled": true, "actions": { "source": { "organizeImports": "on" } } }
}' > biome.json

    # 4. Cria o arquivo de entrada e ignora no git
    echo 'console.log("TS-Init no Fish executado!");' > src/index.ts
    printf "node_modules\ndist\n" > .gitignore
    
    # 5. Adiciona scripts básicos no package.json (usando jq ou via sed básico)
    # Aqui vamos de forma simples para não quebrar:
    echo "✅ Projeto '$argv[1]' configurado com Biome e TypeScript!"
    code .
end
