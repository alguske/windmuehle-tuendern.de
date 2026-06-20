# Windmühle Tündern - Project Instructions

## Tech Stack

- **SSG**: [Zola](https://www.getzola.org/). Build `zola build`, serve `zola serve`.
- **Templates**: Tera (`.html` files in `templates/`)
- **Styles**: Sass (`sass/main.scss`), compiled by Zola
- **Hosting**: static GitHub Pages, CNAME `windmuehle-tuendern.de`
- **Local preview**: `./start-local.sh` (wraps `zola serve`, default `http://127.0.0.1:1111`)

## Trilingual Architecture

The site supports three languages: **German (de, default)**, **English (en)**, **Spanish (es)**.

Every content or translation change **must** cover all 3 languages.

### Where translations live

| Location | DE | EN | ES |
|---|---|---|---|
| config.toml keys | `[translations]` | `[languages.en.translations]` | `[languages.es.translations]` |
| Nav items | `[extra.nav.de]` | `[extra.nav.en]` | `[extra.nav.es]` |
| Content pages | `content/` | `content/en/` | `content/es/` |
| Templates | `{% if lang == "de" %}` / `{% elif lang == "en" %}` / `{% else %}` blocks |

### Translation rules

- Never leave a language behind. If one language is updated, all three must match.
- Preserve HTML tags, markdown formatting, and structure identically across languages.
- Dates and proper nouns must stay consistent ("Tündern" is never translated).
- When unsure about a translation, flag it for human review.

## Blog Posts

- Live in `content/aktuelles/` (de), `content/en/aktuelles/` (en), `content/es/aktuelles/` (es)
- Filename `YYYY-MM-DD-slug.md`. Zola derives `page.date` from it, so no `date` field in frontmatter.
- Frontmatter: `title`, `description`, `template = "blog-post.html"`, `[extra] image`
- Images in `static/imgs/`, referenced absolute (`/imgs/...`). Galleries use `<div class="post-images">`.
- Optimize post images to 1200px / 80% JPEG; thumbnails to 600px / 70% into `static/imgs/thumbs/<basename>.jpg`. Every `[extra] image` needs a matching thumbnail.
- Full writing guide (voice, image layout, trilingual workflow): `.agents/skills/new-post/SKILL.md` (Claude: the `new-post` skill).
- Hard rules: cover DE+EN+ES (leave `<!-- TODO: translate -->` if you cannot). No em/en dashes in prose. Plain, warm, German-native voice, first-person plural (`wir`).

## Führungen (guided tours) data

- Source of truth: `data/fuehrungen.toml`. One `[[slots]]` table per tour. No DB yet.
- Schema (validated by `scripts/validate-fuehrungen.py`):
  - `date` ISO `YYYY-MM-DD`, Europe/Berlin
  - `time` `HH:MM` 24h
  - `duration_min` integer, defaults to 60
  - `kind` `"public"` or `"private"`
  - `status` `"free"`, `"booked"` or `"cancelled"`; private slots cannot be `"free"`
  - `guide` optional string, first name(s) of the tour guide
- Private slots render opaque. Never include family names or other identifiers in the data file.
- Phone numbers on the contact card are base64-encoded server-side, revealed on click. When changing one, update `data-display`, `data-tel`, `data-wa` in `templates/fuehrungen.html` via Tera's `base64_encode` filter.
- JSON-LD `Event` schema emits only for upcoming public, non-cancelled slots.
- After editing, run `scripts/validate-fuehrungen.py`. Run `zola build` before committing.

## Conventions

- Conventional commits (no AI/Claude mentions)
- `zola build` must pass before committing
- Keep translation keys in `config.toml` in the same order across all 3 language sections
