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

## Agent instructions for creating a blog post

These instructions are **for AI agents** (Claude, Copilot, etc.). Humans follow the README.

### Scripts are a starting point, not a constraint

`scripts/new-post.sh` and `scripts/make-thumb.sh` exist to automate the mechanical parts (image optimization, thumbnail generation, trilingual scaffolding). Use them when images need optimizing or when boilerplate would be tedious. **You are not required to use them.** When the scaffolded output doesn't fit the content, restructure freely — edit the generated files, add sections, regroup images, rewrite prose, delete placeholders.

Your job is to produce a post that reads well and looks good, not to faithfully reproduce the template.

### Creative freedom you have

- **Text**: Rewrite the generated body from scratch. Use the user-provided summary as input, not as the final text. Invent section headings (`##`) that match the content. Weave short paragraphs. Vary sentence length.
- **Image layout**: The `.post-images` CSS is a 2-column grid. Group images into `<div class="post-images">` blocks of any size, but even-sized groups avoid orphan rows. Split galleries into **multiple logical sections with H2 headings between them** when the images tell a story — this reads much better than one long gallery.

### Image layout decisions (single-image posts)

Before writing the body, run `sips -g pixelWidth -g pixelHeight <path>` on each image to know its orientation. Then pick the layout:

| Case | Layout | `hide_hero` | Body markup |
|---|---|---|---|
| 1 image, **horizontal** (w ≥ h) | Full-width below the text. `.post-images` auto-spans single child to full width. | `true` | Text first, then `<div class="post-images"><img …></div>` at the bottom. |
| 1 image, **vertical** (w < h) | Side-by-side: image left, text right (`.post-split`). | `true` | `<div class="post-split"><img …><div class="post-split-text">…</div></div>` |
| 2+ images | `.post-images` grids (2-col, group evenly). | omit (hero serves as banner) | Group images logically. |

Rules:
- `hide_hero = true` whenever the only/primary image is already rendered in the body — avoids a duplicate small hero crop.
- If the photo has a credit, set `extra.image_credit = "Foto: <name>"` (renders as figcaption when the hero shows; otherwise add the credit inline in `.post-split-text` as `<em>Foto: <name></em>`).
- For event-announcement posts, wrap the date/time line in `<p class="event-when"><strong>Wann/When/Cuándo:</strong> …</p>` for the callout box.
- Always keep `extra.image` set (used by the homepage news thumbnail), even when the hero is hidden.
- **Hero image**: Pick the most visually striking photo as `extra.image` (run `scripts/make-thumb.sh` to swap — it handles all three language files and regenerates the thumbnail).
- **Structure**: Opening paragraph → sectioned narrative → closing paragraph is a good default. Copy the rhythm from `content/aktuelles/2026-04-17-einweihung-der-windmuehle.md` as a reference.

### Voice and tone (strict)

This is a village association's website. The voice is **plain, direct, warm, German-native**. Not marketing copy, not a press release.

- **Avoid AI tells**: no em/en dashes (`—` / `–`), no "it was finally time", no "wir dürfen mit Stolz verkünden", no flowery metaphors, no `—` as a connective. Use commas and periods.
- **Short sentences win**. 8–15 words per sentence on average.
- **No filler adjectives** (`beeindruckend`, `feierlich geschmückt`, `stimmungsvoll`, `unvergesslich`). Describe what happened, not how it felt.
- **First-person plural** (`wir`) is the house voice for association news.
- **Dates in full**: `am 17. April`, not `17.04.`.
- **Proper nouns never translated**: Tündern, Windmühle Tündern, Förderverein Windmühle Tündern e.V.

### Non-negotiables

- Create/update DE, EN, and ES versions. If you can't translate, leave a clear `<!-- TODO: translate to English/Spanish -->` marker at the top of the body so a human can finish.
- `extra.image` must reference an existing file and must have a matching thumbnail in `static/imgs/thumbs/` (basename match).
- `zola build` must pass before handing back.
- Image alt text is intentionally omitted on gallery images — don't add it back.

### When invoked to "create a post" or "enrich a post"

1. Look at the images yourself (Read tool on the jpgs). Understand what they show before writing text.
2. Draft the DE post end-to-end: title, description, sectioned body, image groupings. Don't mechanically dump all images into one div.
3. Mirror the structure into EN and ES. If you are confident in the translation, translate fully; otherwise leave the TODO marker and translate the image structure only.
4. Run `zola build` to verify.
5. Summarize what you changed — which sections, which image grouping, which voice choices — so the user can review your calls.
