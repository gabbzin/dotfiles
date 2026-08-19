---
name: create-commit
description: Creates a single git commit for the current changes, in the format "tipo: #numero_task descrição". Determines tipo (feat/fix/chore) and numero_task from the current branch name (e.g. feat/12-login-colaborador -> feat #12); asks the user directly if the branch name doesn't match that convention. Writes the descrição itself from the diff/conversation - never asks the user to write it. Runs the code-review-gh skill against staged/working changes first and only commits after that review settles. Never pushes. Refuses to run on main/master.
---

# create-commit

## Propósito

Produzir exatamente um commit bem formado para as mudanças atuais, depois de revisadas,
no formato:

```
tipo: #numero_task descrição
```

onde `tipo` é `feat`, `fix` ou `chore`.

## Passo 0 — Recusar em main/master

Rodar `git branch --show-current`. Se for `main` ou `master`, parar imediatamente:
"create-commit se recusa a rodar direto em main — crie uma branch primeiro, ex:
`git checkout -b feat/<numero-issue>-<slug>`." Não seguir adiante.

## Passo 0.5 — Confirmar que há algo para commitar

Rodar `git status --porcelain`. Se estiver vazio, parar: "Working tree limpa — nada para
commitar." (Sem sentido rodar revisão ou perguntar tipo/número para um no-op.)

## Passo 1 — Determinar tipo e numero_task pelo nome da branch

Comparar o nome da branch atual com `^(feat|fix|chore)/([0-9]+)-(.+)$`.

- Se bater: `tipo` = grupo 1, `numero_task` = grupo 2.
- Se NÃO bater (ex: `main`, `random-name`, prefixo errado, ou sem número): não adivinhar.
  Perguntar diretamente ao usuário, nesta mesma conversa (via `AskUserQuestion`, ou texto
  simples se indisponível), por: (a) o tipo do commit — feat, fix ou chore, e (b) o número
  da issue no GitHub. Mencionar que renomear a branch para seguir
  `tipo/numero-issue-slug` vai permitir que isso rode automaticamente da próxima vez.

## Passo 2 — Rodar a revisão ANTES de dar stage/commit

Invocar a skill `code-review-gh` com `args: "staged"`. Esperar ela resolver por completo
— incluindo qualquer loop de aprovação e delegação ao Haiku — antes de continuar. Não dar
stage nem commit enquanto essa skill ainda está rodando.

## Passo 3 — Tratar o resultado da revisão

- Se `code-review-gh` aplicou correções, esses arquivos agora estão modificados na working
  tree (ainda não staged/commitados) — o Passo 4 abaixo vai incorporá-los.
- Se o usuário recusou explicitamente algumas/todas as correções, ou disse "pular
  revisão"/"nada para corrigir": seguir mesmo assim. A revisão não encontrou nada que o
  usuário queira corrigir — decisão dele, não um bloqueio.
- Se `code-review-gh` não encontrou nenhum problema: seguir direto.

## Passo 4 — Dar stage nos arquivos relevantes

Este é o passo importante de re-stage: como `code-review-gh` pode ter aplicado correções
em arquivos que já tinham conteúdo staged (ou em arquivos não staged), é preciso re-dar
stage agora para que o commit inclua tudo que é pretendido:

- Para arquivos já rastreados: `git add -u` dá stage em modificações e remoções de
  arquivos que o git já rastreia — seguro rodar de forma ampla.
- Para arquivos genuinamente novos (não rastreados): revisar as entradas `??` de
  `git status --porcelain`. Só dar stage nos não rastreados que claramente fazem parte da
  mudança atual (criados como parte desta tarefa/conversa). Nunca usar `git add -A`/
  `git add .` cego — isso pode incluir arquivos avulsos ou temporários. Se não estiver
  claro se um arquivo pertence à mudança, listar e perguntar ao usuário.
- Nunca forçar stage em algo coberto por `.gitignore` (`git add -f`) — se um arquivo está
  ignorado, é por um motivo; não sobrepor isso silenciosamente.

## Passo 5 — Compor a mensagem de commit

- `tipo` e `numero_task` do Passo 1.
- `descrição`: escrever você mesmo, de forma concisa, no imperativo, baseado no diff
  staged real e no contexto da conversa — nunca pedir ao usuário para fornecer.
- Linha de assunto: `tipo: #numero_task descrição` (essa é a mensagem inteira para
  mudanças pequenas).
- Se a mudança for grande o suficiente para precisar de mais explicação, adicionar uma
  linha em branco depois do assunto e bullet points resumindo as mudanças principais — a
  linha de assunto ainda precisa seguir o formato exato.

## Passo 6 — Commitar

Usar heredoc para evitar problemas de quoting:

```bash
git commit -m "$(cat <<'EOF'
tipo: #numero_task descrição
EOF
)"
```

Sempre criar um commit NOVO — nunca `--amend`, nunca pular hooks (`--no-verify`/
`--no-gpg-sign`). Se um hook de pre-commit falhar, corrigir o problema de fato, re-dar
stage, e commitar de novo como uma nova tentativa.

## Passo 7 — Reportar, nunca dar push

Mostrar o resultado (ex: `git log -1 --stat`) e deixar explícito que o commit NÃO foi
pushado — push é uma ação separada e explícita que o usuário toma depois (via create-pr
ou manualmente).

## Casos de borda

- **Branch é main/master**: recusar (Passo 0).
- **Nada para commitar**: parar cedo (Passo 0.5), nem rodar a revisão.
- **Nome da branch não bate com a convenção**: perguntar diretamente ao usuário (Passo 1)
  — nunca adivinhar tipo ou número silenciosamente.
- **Revisão encontra problemas que o usuário recusa**: commit prossegue mesmo assim
  (Passo 3) — esta skill nunca bloqueia um commit só porque há achados não resolvidos.
- **Falha de pre-commit hook**: corrigir, re-dar stage, commitar de novo como nova
  tentativa — nunca pular o hook.
