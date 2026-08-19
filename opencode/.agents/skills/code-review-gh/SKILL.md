---
name: code-review-gh
description: Reviews the diff of pending changes for real, verified code-quality issues, lint violations, and code smells — proposes concrete fixes without applying them, gets explicit user approval, then delegates approved fixes to a low-cost Haiku model. Accepts a scope argument via args - "staged" (staged changes, falling back to the full working-tree diff if nothing is staged - the default) or "branch:<base>" (full diff of the current branch against <base>, e.g. branch:main). Distinct from the built-in /code-review slash command (cloud, multi-agent review) - this one reviews only the diff about to be committed or PR'd, right now, locally. Called directly by the user, or internally by the create-commit and create-pr skills.
---

# code-review-gh

## Propósito

Revisar exatamente o código que está prestes a avançar (para um commit, ou para um PR) —
nunca o histórico inteiro da branch, nunca arquivos não relacionados. Encontrar só
problemas reais e verificáveis. Propor correções. Nunca aplicar nada sem aprovação
explícita do usuário. Quando aprovado, delegar a edição mecânica para um modelo barato
(Haiku), já que aplicar uma correção já decidida não exige um modelo de ponta.

## Passo 1 — Resolver escopo e calcular o diff

O escopo vem do argumento passado a esta skill (via `args`). Se nenhum argumento for
passado, usar `staged` como padrão.

- `staged` (padrão):
  1. Rodar `git diff --cached` (só staged).
  2. Se vazio, cair para `git diff HEAD` (staged + unstaged, o diff completo da working
     tree) e avisar que está revisando a working tree porque nada estava staged.
  3. Se isso também estiver vazio, não há nada para revisar — dizer isso claramente
     ("Working tree limpa, nada para revisar") e parar. Não inventar achados.

- `branch:<base>` (ex: `branch:main`):
  1. Rodar `git diff <base>...HEAD` (triplo ponto: diff contra o merge-base, mostrando só
     o que ESTA branch introduziu, não commits não relacionados em `<base>`).
  2. Se vazio, dizer isso ("Nenhuma mudança nesta branch vs `<base>`") e parar.

Nunca expandir o escopo além do resolvido acima.

## Passo 2 — Detectar tooling disponível dinamicamente (nunca assumir que existe)

Este repositório pode não ter nenhum lint/test configurado ainda — isso é esperado e
normal. Antes de tentar rodar qualquer coisa, checar o que existe de fato:

- Existe `package.json` na raiz? Se sim, ler o campo `scripts` e só usar scripts que
  realmente existem (tipicamente `lint`, `typecheck`/`type-check`, `test`) — nunca supor
  nomes de script.
- Existe config de ESLint (`.eslintrc*`, `eslint.config.js/.cjs/.mjs/.ts`)? Só então
  considerar rodar ESLint, e só nos arquivos tocados pelo diff.
- Existe `tsconfig.json`? Só então considerar `npx tsc --noEmit` (typecheck do projeto
  inteiro — deixar claro no relatório que isso checa o projeto todo, não só o diff).
- Existe config de test runner (`jest.config.*`, `vitest.config.*`, ou script `test`)? Só
  rodar se o diff tocar arquivos de código-fonte que plausivelmente têm testes — não rodar
  a suíte inteira por reflexo.
- Se nada disso existir, dizer isso explicitamente ("Nenhum tooling de lint/typecheck
  detectado ainda neste repo — revisão abaixo é baseada em leitura manual") e seguir com
  revisão manual. Esse é o estado esperado hoje (`iadeb-back`/`iadeb-integra-front` ainda
  não têm `package.json`); não tratar como erro.

Rodar só as ferramentas relevantes às linguagens/arquivos presentes no diff.

## Passo 3 — Analisar

Combinar a saída das ferramentas (se alguma rodou) com leitura própria do diff e contexto
suficiente dos arquivos (via Read) para julgar cada mudança corretamente. Procurar
problemas genuínos:

- Erros reais de lint/tipo reportados pelas ferramentas rodadas.
- Bugs reais: condicionais erradas, off-by-one, null/undefined não tratado, erros
  engolidos silenciosamente, problemas óbvios de segurança (segredos/credenciais
  commitados, riscos de injeção).
- Código morto, variáveis/imports não usados, `console.log`/debugger esquecido.
- Duplicação genuína de lógica que já existe em outro lugar dos arquivos tocados.
- Nomes ou estrutura ativamente enganosos (não apenas "poderia ser mais bonito").

Filtrar rigorosamente: só reportar algo se houver evidência concreta no diff (erro de
ferramenta, falha lógica real, ou uma regra que o próprio código já segue em outro lugar e
esta mudança quebra). NÃO reportar:
- Preferências de estilo/formatação sem config que as sustente.
- Casos hipotéticos especulativos sem evidência de que sejam alcançáveis.
- Qualquer coisa só para parecer minucioso. Se não encontrar nada, dizer "Nenhum problema
  encontrado" — esse é um resultado válido e esperado, não uma falha.

## Passo 4 — Apresentar achados

Para cada problema real, apresentar:
1. Arquivo e linha/âncora.
2. O que está errado e por que importa (concreto, não hipotético).
3. Uma correção proposta específica — snippet exato antes/depois, ou um diff preciso —
   nunca um vago "considere refatorar isso".

Se não houver problemas, dizer isso claramente e pular direto para o relatório final
(Passo 7) — não seguir para os Passos 5/6.

## Passo 5 — Obter aprovação

Perguntar ao usuário quais correções aplicar: todas, algumas (listar quais) ou nenhuma.
Usar a ferramenta `AskUserQuestion` quando disponível; caso contrário, perguntar
diretamente na conversa e esperar uma resposta explícita — nunca assumir aprovação, nunca
seguir para edição antes da resposta do usuário.

- Se o usuário disser nenhuma/pular: reportar "Revisão concluída — nenhuma correção
  aplicada por escolha do usuário" e parar aqui (devolver controle a quem chamou esta
  skill).
- Se o usuário aprovar algumas ou todas: seguir para o Passo 6 só com o subconjunto
  aprovado.

## Passo 6 — Delegar correções aprovadas a um modelo de baixo custo

Não editar os arquivos você mesmo. Em vez disso, use a ferramenta `Agent` com
`subagent_type: "general-purpose"` e `model: "haiku"` para aplicar as correções.

Monte o prompt do agente para que ele não precise re-derivar nada:
- Liste só as correções que o usuário de fato aprovou (nunca as recusadas).
- Para cada uma: caminho do arquivo, uma forma de localizar o ponto exato (número de
  linha E um pequeno trecho-âncora de texto ao redor, já que números de linha podem
  mudar), e texto exato antes/depois ou uma instrução inequívoca.
- Instrua explicitamente: "Aplique só estas mudanças listadas. Não procure nem corrija
  nenhum outro problema, e não rode git add/commit."

Esperar o subagente terminar antes de continuar.

## Passo 7 — Verificar e reportar

- Reconferir o diff relevante (mesmo escopo do Passo 1, ou `git status`) para confirmar
  que as correções realmente entraram e parecem corretas.
- Se alguma ferramenta de lint/typecheck estava disponível no Passo 2, opcionalmente
  rodá-la de novo nos arquivos tocados para confirmar que nenhum erro novo foi introduzido.
- Reportar ao usuário: quais correções foram aplicadas (arquivo:linha), quais foram
  puladas (usuário recusou, ou o subagente não conseguiu localizar a âncora), e confirmar
  que a revisão está completa.
- Aviso para uso standalone: se o escopo era `staged` e já havia conteúdo staged antes
  desta revisão rodar, aplicar correções edita a working tree, o que dessincroniza do que
  já está no índice. Esta skill não re-adiciona ao stage sozinha. Se foi invocada
  diretamente pelo usuário (não via create-commit), lembrar que será preciso `git add` os
  arquivos corrigidos de novo antes de commitar. Se foi invocada por create-commit, essa
  skill cuida do re-stage sozinha (ver seu próprio Passo 4).

## Casos de borda

- **Nada staged e working tree também limpa** (escopo `staged`): parar no Passo 1 com
  "nada para revisar" — não fabricar achados.
- **`branch:<base>` onde a branch atual É `<base>`**: o diff será vazio; reportar isso
  claramente. (Recusar rodar em `main` é responsabilidade do create-commit/create-pr, não
  desta skill — esta skill só reporta o que o diff mostra.)
- **Nenhum tooling detectado**: esperado hoje; dizer isso e seguir só com revisão manual
  (Passo 2).
- **Usuário aprova só parte das correções**: aplicar só essas; listar as recusadas pelo
  nome no relatório final para que nada seja descartado silenciosamente.
- **Diff muito grande**: avisar que é grande e priorizar os achados mais relevantes e
  verificados em vez de anotar exaustivamente cada linha — nunca inventar achados de
  preenchimento só para parecer minucioso.
