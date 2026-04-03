# Windmühle Tündern - Project Instructions

## Tech Stack

- **SSG**: [Zola](https://www.getzola.org/) — build with `zola build`, serve with `zola serve`
- **Templates**: Tera templating engine (`.html` files in `templates/`)
- **Styles**: Sass (`sass/main.scss`), compiled by Zola
- **Hosting**: Static site, deployed via GitHub Pages with CNAME `windmuehle-tuendern.de`

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
- Filename format: `YYYY-MM-slug.md`
- Use `template = "blog-post.html"` in frontmatter
- Frontmatter requires: `title`, `date`, `description`, `template`, `[extra] image`
- Images go in `static/imgs/` and are referenced with absolute paths (`/imgs/...`)
- Posts use `<div class="post-images">` for image galleries
- Post images: optimize to 1200px width, 80% JPEG quality via `sips -s format jpeg -s formatOptions 80 --resampleWidth 1200`
- Thumbnails: generate at 600px width, 70% JPEG quality into `static/imgs/thumbs/` via `sips -s format jpeg -s formatOptions 70 --resampleWidth 600`
- Every post with `[extra] image` must have a matching thumbnail in `static/imgs/thumbs/<filename>.jpg`

## Conventions

- Use conventional commits (no AI/Claude mentions in commit messages)
- `zola build` must pass cleanly before committing
- Keep translation keys in `config.toml` in the same order across all 3 language sections
