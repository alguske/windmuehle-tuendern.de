---
description: Scaffold a new blog post for the Windmühle Tündern site in DE / EN / ES under content/aktuelles/. Optimizes images and generates a homepage thumbnail. Use when the user says "new post", "new blog post", "add an Aktuelles post", "create a post", "neuer Blogpost", or invokes /new-post.
argument-hint: "<slug> [-t title] [-s summary] [-D YYYY-MM-DD] [-d local/imgs/]"
---

# Create a new blog post

Scaffold a new post under `content/aktuelles/` (DE), `content/en/aktuelles/` (EN) and `content/es/aktuelles/` (ES). Uses `scripts/new-post.sh` for image optimization and file generation.

## Inputs to ask for if not provided

- Slug (kebab-case)
- Title (defaults to humanized slug)
- Summary / description (used in frontmatter and as fallback body)
- Date (defaults to today)
- Source image directory (defaults to `local/imgs/`)

## Steps

1. Drop source images into `local/imgs/` (gitignored) if not already there.
2. Run the scaffold script:
   ```bash
   ./scripts/new-post.sh <slug> -t "Title" -s "Description." -D YYYY-MM-DD
   ```
3. Edit the DE post in `content/aktuelles/YYYY-MM-DD-<slug>.md`. Add H2 section headings, group images in `<div class="post-images">` blocks of even size.
4. Translate the EN and ES stubs. Remove the `<!-- TODO: translate -->` marker. Keep image paths identical across languages.
5. Optional: `./scripts/make-thumb.sh <image-path>` to swap the hero image.
6. Run `zola build` to verify.
7. Commit with a conventional message (`feat: add <title> post`).

## Conventions

- Filenames follow `YYYY-MM-DD-<slug>.md`. Zola derives `page.date` from the filename, so frontmatter has no `date` field.
- Every post must have a matching thumbnail in `static/imgs/thumbs/<filename>.jpg`. The script generates it.
- Voice and tone rules live in `.claude/CLAUDE.md`. Read that file before drafting body text.

## When NOT to use this skill

- To swap only the hero image of an existing post, use `scripts/make-thumb.sh` instead.
- To translate an existing post, edit the EN / ES files directly; this skill scaffolds stubs only.
