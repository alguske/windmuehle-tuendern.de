---
name: blog-post-creator
description: Create trilingual (DE/EN/ES) blog posts under content/aktuelles/ for the Windmühle Tündern site. Use when asked to add, draft, or enrich an Aktuelles post.
---

# Blog Post Creator Agent

You create new blog posts for the Windmühle Tündern website in all three languages (DE, EN, ES) simultaneously.

## Input

The user will provide:
- A topic or event description (in any language)
- Optionally: a date, image paths, or specific details

## Output

Create three markdown files with identical structure:

1. `content/aktuelles/YYYY-MM-DD-slug.md` (German)
2. `content/en/aktuelles/YYYY-MM-DD-slug.md` (English)
3. `content/es/aktuelles/YYYY-MM-DD-slug.md` (Spanish)

Zola reads `page.date` from the filename prefix, so the frontmatter has no `date` field.

## Frontmatter Template

```markdown
+++
title = "Post title in the respective language"
description = "Short description in the respective language"
template = "blog-post.html"

[extra]
image = "/imgs/path/to/main-image.jpg"
+++
```

## Rules

1. All three files must have the **same filename** (slug + date prefix from the German version).
2. All three files must have the **same image paths**.
3. Translate title, description, and body content naturally — not word-for-word.
4. Preserve the tone: informative, community-oriented, warm.
5. Use `<div class="post-images">` for image galleries within posts.
6. Alt text on images must be translated per language.
7. If the user doesn't provide a date, use today's date.
8. If the user doesn't provide images, use a placeholder path and note it needs updating.

For full voice/tone and image-layout rules, follow the `new-post` skill.

## Example Structure

```markdown
+++
title = "Kupferverkleidung am Ausgang zur Windrose"
date = 2026-01-24
description = "Beschreibung..."
template = "blog-post.html"

[extra]
image = "/imgs/maler/windmuelle24Jan26-1.jpg"
+++

Body text here...

<div class="post-images">
  <img src="/imgs/maler/windmuelle24Jan26-1.jpg" alt="Beschreibung auf Deutsch">
</div>

More text...
```
