# Contributing

## AI assistant configuration

This repo defines its AI agents, skills, and instructions **once** under
`.agents/`, in plain Markdown. Each tool reads that single source through
symlinks. No build step, no tooling to install.

### Source of truth

| Path | Holds |
|---|---|
| `.agents/AGENTS.md` | project instructions (tech stack, trilingual rules, conventions) |
| `.agents/skills/<name>/SKILL.md` | invokable skills (new-post, new-tour, build-check, i18n-sync) |
| `.agents/agents/<name>.md` | subagents (blog-post-creator, i18n-checker, seo-auditor) |

Edit the files under `.agents/`. That is the only place to change.

### How each tool sees it (symlinks)

| Symlink | Target | Read by |
|---|---|---|
| `AGENTS.md` | `.agents/AGENTS.md` | Codex |
| `CLAUDE.md` | `.agents/AGENTS.md` | Claude Code |
| `.claude/skills/<name>` | `../../.agents/skills/<name>` | Claude Code |
| `.claude/agents/<name>.md` | `../../.agents/agents/<name>.md` | Claude Code |

All symlinks are committed. Cloning on macOS or Linux resolves them with no
extra step. Codex reads only the root `AGENTS.md`; it does not need a `.codex/`
directory.

### Adding a skill or agent

Create the Markdown file under `.agents/skills/<name>/SKILL.md` or
`.agents/agents/<name>.md`, then add the matching symlink under `.claude/`:

```bash
ln -s "../../.agents/skills/<name>" ".claude/skills/<name>"
ln -s "../../.agents/agents/<name>.md" ".claude/agents/<name>.md"
git add .agents .claude
```

## Site contributions

See the [README](./README.md) for the build, blog post, and Führungen
workflows. `zola build` must pass before committing. Use
[conventional commits](https://www.conventionalcommits.org/).
