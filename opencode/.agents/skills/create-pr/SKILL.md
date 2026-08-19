---
name: create-pr
description: Opens a GitHub pull request for the current branch. Runs a full branch-vs-default-branch review (via code-review-gh, scope branch:<default>), ensures everything is committed (delegating to create-commit rather than duplicating commit logic), pushes the branch, checks for an existing PR and a PR template, and creates the PR via gh pr create with a convention-based title and a real bullet-point body summarizing the actual changes. Refuses to run on main/master.
---

# create-pr

## Propósito

Abrir um PR para o trabalho da branch atual, depois de uma revisão completa da branch,
com título e corpo que de fato descrevem o que mudou.

## Passo 0 — Recusar em main/master

Rodar `git branch --show-current`. Se for `main` ou `master`, parar: "create-pr não pode
rodar em main — faça checkout da branch de feature para a qual você quer abrir o PR."

## Passo 1 — Determinar a branch base

Tentar, nesta ordem: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`,
depois `git symbolic-ref refs/remotes/origin/HEAD` (removendo o prefixo
`refs/remotes/origin/`), caindo para `main` se ambos falharem. Chamar isso de `<base>`
(hoje é `main` neste repo).

## Passo 2 — Confirmar que há algo para abrir PR

Rodar `git diff <base>...HEAD` (ou `git log <base>..HEAD --oneline`). Se o diff e a lista
de commits estiverem vazios, parar: "Nenhum commit encontrado nesta branch vs `<base>` —
nada para abrir PR."

## Passo 3 — Revisão completa da branch

Invocar a skill `code-review-gh` com `args: "branch:<base>"` (ex: `branch:main`). Isso
pega qualquer coisa que tenha passado despercebida nas revisões commit a commit, já que
olha o diff acumulado inteiro, não só o último commit. Esperar ela resolver por completo
(aprovação/recusa, delegação ao Haiku se houver) antes de continuar.

Nota: correções aplicadas nesta etapa entram como edições simples na working tree — NÃO
são staged nem commitadas por `code-review-gh`. Isso é esperado; o Passo 4 trata disso.

## Passo 4 — Garantir que tudo está commitado

Rodar `git status --porcelain`. Se não estiver vazio (trabalho não commitado
pré-existente, ou correções recém-aplicadas no Passo 3), invocar a skill `create-commit`
(sem args — ela mesma deriva tipo/número do nome da branch). NÃO rodar `git add`/
`git commit` diretamente aqui — isso duplicaria lógica que já vive em create-commit.

Esperar que `create-commit` rode `code-review-gh` de novo internamente (escopo `staged`)
como parte do próprio fluxo dela — essa segunda passada é esperada e deve ser
rápida/limpa já que a revisão em nível de branch no Passo 3 já cobriu o mesmo terreno; se
ela trouxer de volta algo que o usuário recusou antes, isso é uma segunda chance
intencional, não um bug.

## Passo 5 — Dar push na branch

Checar se a branch tem upstream: `git rev-parse --abbrev-ref --symbolic-full-name @{u}`.
- Sem upstream: `git push -u origin <branch>`.
- Com upstream mas à frente: `git push`.
- Já atualizado: pular o push.

Antes de dar push, avisar ao usuário que essa é uma ação visível e compartilhada (a
branch fica visível para todo o time no GitHub) — isso é um passo normal de abrir um PR,
não algo que precise de confirmação extra além dos prompts de permissão do próprio
harness.

## Passo 6 — Checar se já existe PR

Rodar `gh pr list --head <branch> --json url,number,state` (ou `gh pr view --json
url,number,state`). Se já existir um PR aberto para esta branch: não criar duplicata.
Reportar a URL do PR existente, e perguntar ao usuário se ele quer atualizar título/corpo
em vez disso, ou deixar como está.

## Passo 7 — Checar template de PR

Procurar `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, ou
arquivos em `.github/PULL_REQUEST_TEMPLATE/`. (Nenhum existe hoje neste repo — essa
checagem é para o futuro, para quando um for adicionado.)
- Se encontrado: usar a estrutura de seções dele para o corpo, preenchendo cada seção com
  conteúdo real derivado do diff — nunca deixar placeholders de template sem preencher.
- Se não encontrado: usar o formato padrão em bullets abaixo.

## Passo 8 — Compor título e corpo

**Título**: `tipo: #numero_task descrição curta` — a mesma convenção do formato de
commit, derivada da mesma forma (regex no nome da branch
`^(feat|fix|chore)/([0-9]+)-(.+)$`, perguntando ao usuário diretamente se não bater,
exatamente como no Passo 1 do create-commit). Isso é escolhido deliberadamente em vez do
título padrão do `gh` para manter os PRs rastreáveis até a issue de relance na lista de
PRs do GitHub, consistente com a convenção de commit.

**Corpo** (quando não há template): bullet points resumindo as mudanças reais, escritos a
partir de `git diff <base>...HEAD` e do contexto da conversa — nunca um template genérico
com colchetes não preenchidos. Incluir `Closes #numero_task` como linha própria para que
o merge feche a issue automaticamente — mas só se `numero_task` foi derivado com
confiança do nome da branch; se foi fornecido manualmente pelo usuário e ele não tinha
certeza de que mapeia para uma issue fechável de verdade, perguntar antes de adicionar
essa linha.

## Passo 9 — Criar o PR

```bash
gh pr create --base <base> --title "<título>" --body "$(cat <<'EOF'
<corpo>
EOF
)"
```

Passar título/corpo diretamente — nunca depender dos prompts interativos do editor do
`gh`.

## Passo 10 — Reportar

Repassar a URL do PR que `gh pr create` retorna.

## Casos de borda

- **Branch atual é main/master**: recusar (Passo 0).
- **Nada para abrir PR (sem commits vs base)**: parar (Passo 2).
- **Já existe PR para esta branch**: reportar, não duplicar (Passo 6).
- **Branch já pushada e atualizada**: pular o push, seguir para checagem/criação de PR
  (Passo 5).
- **`gh` não autenticado**: checar via `gh auth status`; se não autenticado, avisar o
  usuário para rodar `gh auth login` primeiro e parar.
- **Nome da branch não bate com a convenção para o título**: perguntar diretamente ao
  usuário, igual ao create-commit — não adivinhar.
