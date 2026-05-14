---
description: Audit translation parity across DE / EN / ES for the Windmühle Tündern site. Checks config.toml translation keys, content page counterparts, and nav item parity. Use when the user says "i18n sync", "check translations", "translation parity", "are translations in sync", "translation audit", or invokes /i18n-sync. Auto-trigger after any change to config.toml `[translations]` blocks or any new file under content/.
argument-hint: "(no arguments needed)"
---

# i18n Sync Check

The site is trilingual: German (default), English (`/en`), Spanish (`/es`). Every translation key, content page and nav item must exist in all three.

## Checks

### 1. config.toml translation keys

Compare the keys present in:
- `[translations]` (German, default)
- `[languages.en.translations]`
- `[languages.es.translations]`

Report any key that exists in one section but is missing in another. Verify the keys appear in the same order across all three sections (project convention from CLAUDE.md).

### 2. Content page parity

For every `.md` file in `content/` that is not under `content/en/` or `content/es/`:
- Confirm a counterpart exists at `content/en/<same-path>`
- Confirm a counterpart exists at `content/es/<same-path>`

Report any missing files.

### 3. Nav items

Compare entries under `[extra.nav.de]`, `[extra.nav.en]`, `[extra.nav.es]`. Verify identical item count and matching link structure (DE: `/<slug>/`, EN: `/en/<slug>/`, ES: `/es/<slug>/`).

### 4. Footer links

Footer links live in `templates/partials/footer.html` in three `{% if lang == ... %}` branches. Verify each branch lists the same set of pages.

## Output format

Single summary at the end:
- `OK` if everything is in sync.
- Bulleted list of issues otherwise, grouped by check.
