# Windmühle Tündern - Project Instructions

## Tech Stack

- **SSG**: [Zola](https://www.getzola.org/) — build with `zola build`, serve with `zola serve`
- **Templates**: Tera templating engine (`.html` files in `templates/`)
- **Styles**: Sass (`sass/main.scss`), compiled by Zola
- **Hosting**: Static site, deployed via GitHub Pages with CNAME `windmuehle-tuendern.de`

## Local Development

Start the local preview server from the repository root with:

```bash
./start-local.sh
```

The script runs `zola serve` and forwards any extra arguments to Zola, for example `./start-local.sh --port 1112` if the default port is busy. Keep it running while previewing changes. Zola normally serves the site at `http://127.0.0.1:1111`; if the command prints a different URL, use that URL.

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

- Never leave a language behind — if one language is updated, all three must match.
- Preserve HTML tags, markdown formatting, and structure identically across languages.
- Dates and proper nouns must stay consistent (e.g., "Tündern" is never translated).
- When unsure about a translation, flag it for human review.

## Blog Posts

- Live in `content/aktuelles/` (de), `content/en/aktuelles/` (en), `content/es/aktuelles/` (es)
- Filename format: `YYYY-MM-DD-slug.md` — Zola derives `page.date` from the filename, so no `date` field in frontmatter
- Use `template = "blog-post.html"` in frontmatter
- Frontmatter requires: `title`, `description`, `template`, `[extra] image`
- Images go in `static/imgs/` and are referenced with absolute paths (`/imgs/...`)
- Posts use `<div class="post-images">` for image galleries
- Post images: optimize to 1200px width, 80% JPEG quality via `sips -s format jpeg -s formatOptions 80 --resampleWidth 1200`
- Thumbnails: generate at 600px width, 70% JPEG quality into `static/imgs/thumbs/` via `sips -s format jpeg -s formatOptions 70 --resampleWidth 600`
- Every post with `[extra] image` must have a matching thumbnail in `static/imgs/thumbs/<filename>.jpg`

## Führungen (guided tours) data

- Source of truth: `data/fuehrungen.toml`. One `[[slots]]` table per tour. No DB yet.
- Schema (validated by `scripts/validate-fuehrungen.py`):
  - `date` ISO `YYYY-MM-DD`, time zone Europe/Berlin
  - `time` `HH:MM` 24h
  - `duration_min` integer, defaults to 60
  - `kind` `"public"` or `"private"`
  - `status` `"free"`, `"booked"` or `"cancelled"`; private slots cannot be `"free"`
  - `guide` optional string, first name(s) of the tour guide
- Private slots are rendered opaque on the page. Never include family names or other identifiers in the data file.
- Phone numbers on the contact card are base64-encoded server-side and revealed only on click. When adding or changing a phone number, update the `data-display`, `data-tel` and `data-wa` attributes in `templates/fuehrungen.html` using Tera's `base64_encode` filter.
- JSON-LD `Event` schema emits only for upcoming public, non-cancelled slots.
- Always run `scripts/validate-fuehrungen.py` after editing the data file. Always run `zola build` before committing.

## Conventions

- Use conventional commits (no AI/Claude mentions in commit messages)
- `zola build` must pass cleanly before committing
- Keep translation keys in `config.toml` in the same order across all 3 language sections

## Creating or enriching a blog post

Full instructions live in the `new-post` skill (voice and tone, single-image layout decisions, trilingual workflow). Load that skill before writing a post instead of reconstructing the rules here.

Hard rules that always apply:
- Cover all three languages (DE + EN + ES). If you cannot translate, leave a `<!-- TODO: translate -->` marker for a human.
- Keep `extra.image` set with a matching thumbnail in `static/imgs/thumbs/<basename>.jpg`.
- Run `zola build` before handing back.
- No em/en dashes in prose. Plain, warm, German-native voice. First-person plural (`wir`).
