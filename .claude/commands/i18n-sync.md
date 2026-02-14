# i18n Sync Check

Check that all translations and content pages are in sync across the three languages (DE, EN, ES).

## Checks to perform

### 1. config.toml translation keys
- Compare keys under `[translations]`, `[languages.en.translations]`, and `[languages.es.translations]`
- Report any keys that exist in one language section but not the others
- Verify keys appear in the same order across all sections

### 2. Content page parity
- List all `.md` files in `content/` (excluding `content/en/` and `content/es/`)
- Verify each has a counterpart in `content/en/` and `content/es/`
- Report any missing counterparts

### 3. Nav items
- Compare `[extra.nav.de]`, `[extra.nav.en]`, `[extra.nav.es]`
- Verify same number of items and matching link structure

Report results as a summary with any issues found.

$ARGUMENTS
