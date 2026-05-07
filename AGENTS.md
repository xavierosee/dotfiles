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
