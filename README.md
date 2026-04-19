# Windmühle Tündern Website

This is the official website project for a **non-profit association** dedicated to restoring and preserving the historic windmill in the village of **Tündern**, Germany.

The site is built to share the windmill's history, showcase its restoration progress, and inform visitors about how to support or get involved.

## Tech stack

- [Zola](https://www.getzola.org/) static site generator — build with `zola build`, preview with `zola serve`.
- Tera templates in `templates/`.
- Sass in `sass/main.scss`.
- Trilingual: German (default), English (`/en`), Spanish (`/es`). Every content change must cover all three languages — see [`.claude/CLAUDE.md`](./.claude/CLAUDE.md) for the rules.

## Scripts

All scripts live in `scripts/`. They are offline, idempotent, and depend only on macOS tools (`bash`, `sips`, `awk`, `sed`) — no network required. Bashunit tests live in `scripts/tests/` and run with `./scripts/lib/bashunit scripts/tests`.

### `scripts/new-post.sh` — scaffold a new Aktuelles post

Creates a blog post under `content/aktuelles/` (DE), `content/en/aktuelles/` (EN), and `content/es/aktuelles/` (ES). Optimizes source images into `static/imgs/<slug>/` and generates the homepage thumbnail.

```bash
./scripts/new-post.sh <slug> [options]

Options:
  -d, --dir <path>          Source image directory (default: local/imgs/)
  -t, --title <string>      Post title (default: slug humanized)
  -s, --summary <string>    Description for frontmatter (default: title)
  -D, --date <YYYY-MM-DD>   Post date (default: today)
```

Example:

```bash
./scripts/new-post.sh fluegel-montage \
  -t "Flügelmontage" \
  -s "Die neuen Flügel wurden montiert."
```

What it does:

1. Validates the slug (kebab-case) and date.
2. Reads all jpg/jpeg/png/heic files from the source directory.
3. Optimizes each image into `static/imgs/<slug>/<slug>-NN.jpg` at 1200px wide, JPEG quality 80.
4. Generates a 600px / quality 70 thumbnail into `static/imgs/thumbs/` whose filename matches `extra.image`.
5. Writes three markdown files with identical frontmatter. EN and ES get a `<!-- TODO: translate -->` marker above the body.

**Re-runs are safe.** If some language posts already exist, the script leaves them untouched and only creates the missing ones. When the DE post already exists, its title, description, filename date and `extra.image` are inherited by the new EN/ES stubs so all three stay aligned. Existing optimized images are reused, so the source directory isn't required on re-runs.

Filenames follow `YYYY-MM-DD-<slug>.md`. Zola derives `page.date` from the filename, so the post frontmatter has no `date` field.

### `scripts/make-thumb.sh` — swap the homepage thumbnail

Use this when you want the Aktuelles card on the homepage to display a different image from the post's gallery. It identifies the post from the image path, removes the old thumbnail, generates a new one, and rewrites `extra.image` across the DE, EN and ES posts.

```bash
./scripts/make-thumb.sh <image-path>
```

Accepted path forms (they all resolve to the same file on disk):

- `/imgs/<slug>/<slug>-NN.jpg`
- `static/imgs/<slug>/<slug>-NN.jpg`
- `imgs/<slug>/<slug>-NN.jpg`

Example:

```bash
./scripts/make-thumb.sh /imgs/einweihung-der-windmuehle/einweihung-der-windmuehle-06.jpg
```

### `scripts/mark-for-translation.sh` — reset content files

Overwrites every `.md` file in the given directory with the single line `to be translated`. Useful when preparing a fresh EN or ES tree for manual translation.

```bash
./scripts/mark-for-translation.sh content/en/aktuelles
```

## Recommended workflow for a new blog post

1. **Drop source images into `local/imgs/`**. File names don't matter; the script renames and orders them alphabetically. `local/` is gitignored.
2. **Run `new-post.sh` with at least a slug and a summary**:
   ```bash
   ./scripts/new-post.sh <slug> -s "Kurze Beschreibung für Listen und Teaser."
   ```
3. **Edit the DE post** in `content/aktuelles/YYYY-MM-DD-<slug>.md`. Add headings, group images into logical sections (see below), refine the body text.
4. **Translate the EN and ES stubs** in `content/en/aktuelles/` and `content/es/aktuelles/`. Remove the `<!-- TODO: translate -->` marker, translate title, description and body. Keep image paths untouched — they're shared across languages.
5. **Pick a different hero image if needed** by running `make-thumb.sh` on the image you prefer. Templates derive the homepage thumbnail from `extra.image`, so swapping means regenerating that single thumbnail.
6. **Clear `local/imgs/`** once the post is committed; the directory should stay empty between posts.
7. **Build and verify**:
   ```bash
   zola build
   zola serve
   ```
   Check `/`, `/aktuelles/`, `/en/aktuelles/`, `/es/aktuelles/` and the post page itself.
8. **Commit** with a conventional commit message, e.g. `feat: add <title> post`.

### Image layout tips

The `.post-images` CSS rule is a 2-column grid. Each `<div class="post-images">` renders as rows of two images.

- **Groups of 2 (or any even number)** lay out cleanly with no orphan rows.
- **Logical sections** with H2 headings between gallery blocks read far better than one long gallery.
- **Avoid odd-size groups** unless an orphan row is intentional. A standalone image can be placed as a plain `<img>` outside the grid.

See `content/aktuelles/2026-04-17-einweihung-der-windmuehle.md` for a structured example with four sections and three image pairs.

### When not to use `new-post.sh`

- **When you only want to swap the hero image**, use `make-thumb.sh`, don't recreate the post.
- **When translating an existing post**, edit the EN/ES files directly. The script scaffolds stubs, it does not translate.

## For AI agents

AI agents working on this repository should read [`.claude/CLAUDE.md`](./.claude/CLAUDE.md) for additional guidance on voice, tone, image layout and the degree of creative freedom expected when drafting or enriching blog posts. Agents may use these scripts but are not bound to their default output.

## Testing

```bash
./scripts/lib/bashunit scripts/tests
```

All bash scripts have bashunit coverage in `scripts/tests/`. Please add or update tests when changing script behavior.
