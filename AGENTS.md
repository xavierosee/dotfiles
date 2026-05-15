# Coding conventions for AI agents

These apply to all agents working in this repository.

## Git workflow

**Never commit directly to `main`.** Always create a branch, push it, and open a PR — no exceptions, even for trivial changes.

**Keep PR descriptions current.** Any time a new commit is pushed to a PR branch, update the PR body to reflect the current state of the changes.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) for every commit: `type(scope): description`

Common types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`

Examples:
- `feat(waybar): add startup delay drop-in`
- `fix(bin): handle missing abrt-cli gracefully`
- `chore(claude): expand settings.json allowlist`
- `docs(claude): add agentic coding conventions`

<!-- vault:start:pointer -->
**Knowledge vault — read this for conventions, patterns, runbooks:**

```
vault: ../code-vault
vault-absolute: /home/xavierosee/workspaces/perso/code-vault
```

The vault's own `AGENTS.md` lists every available note with one-line summaries. Read it first.

<!-- vault:end:pointer -->

<!-- vault:start:index -->
**Vault note index** (one-line summaries — read the linked file for the full note):

- `_meta/changelog.md` — Notable changes to vault structure or content.
- `_meta/frontmatter-spec.md` — YAML frontmatter every vault note must carry; consumed by make reindex.
- `_meta/smoke-tests.md` — Manual checklist run before declaring Phase B done and after any bootstrap.sh or Makefile change.
- `_meta/tagging.md` — How to tag vault notes consistently — singular, lowercase, kebab-case.
- `bootstrap/bootstrap-prompt.md` — Paste-into-agent prompt that drives bootstrap.sh interactively in a target repo.
- `bootstrap/existing-repo.md` — Add vault-derived config to a repo that already has CLAUDE.md / AGENTS.md / etc.
- `bootstrap/new-repo.md` — Step-by-step: scaffold a fresh repo with vault-derived agent config.
- `conventions/branch-naming.md` — Never commit to main; branch slugs are feat/fix/chore/docs/<kebab-case>; one concern per branch.
- `conventions/git-conventional-commits.md` — Use type(scope) prefix; lowercase subject, no period; allowed types listed; max 100 chars header.
- `conventions/pr-rules.md` — PR diff under 400 lines; title is conventional commit; reference issue; all CI green; keep description current.
- `modes/debug.md` — Root-cause investigation, no symptom-patching, minimum-viable fix only.
- `modes/implement.md` — Write code against an approved plan; small commits; tests with code.
- `modes/learn.md` — Capture knowledge into the vault as a new note with frontmatter.
- `modes/plan.md` — Read-only exploration; produce a written plan; no edits.
- `modes/refactor.md` — Preserve behavior, restructure code; never combine with behavior changes.
- `modes/review.md` — Read the diff, surface issues with file:line refs, no edits.
- `patterns/machine-state-tracking.md` — Track per-machine quirks, deferred work, and known bugs in a dedicated CLAUDE.md section so agents don't re-derive them every session.
- `patterns/npm-canonical-makefile-wrapper.md` — npm scripts are the cross-platform interface; Makefile is a thin convenience alias for Linux/macOS only.
- `runbooks/piasmin-ssh.md` — Always run Claude Code locally not on the Pi; SSH for changes; scp/rsync or SSH heredoc for file edits.
- `runbooks/piasmin-vault-sync.md` — rsync the local code-vault to Piasmin so the Pi-resident Claude Code instance reads the same content.
- `runbooks/stow-new-package.md` — Mirror $HOME structure under the new package directory; run make stow; special-case if package isn't a command.
- `tools/claude-code.md` — Claude Code reads CLAUDE.md per repo; bootstrap writes pointer + mode-switch instruction; native plan mode complements vault modes.
- `tools/copilot.md` — Copilot reads .github/copilot-instructions.md; bootstrap inlines vault conventions because Copilot can't read external files at runtime.
- `tools/crush.md` — Crush reads AGENTS.md per repo; bootstrap merges vault pointer + conventions + modes sections, preserving hand edits.
- `tools/cursor.md` — Cursor reads .cursor/rules/*.mdc; bootstrap writes from-vault.mdc with proper mdc frontmatter, inlined conventions, and modes.
- `tools/opencode.md` — OpenCode reads AGENTS.md like Crush; bootstrap writes opencode-prefixed sections that coexist with Crush sections.
<!-- vault:end:index -->

