# content/ — pages and blog posts

Scope note for agents working in this directory. Full rules: the "Trilingual
Architecture" and "Blog Posts" sections of the root `AGENTS.md`; step-by-step in
the `new-post` playbook (`.agents/skills/new-post/SKILL.md`).

- Trilingual, always. Every change covers DE (`content/`), EN (`content/en/`),
  ES (`content/es/`). Never leave a language behind; keep structure and markup
  identical across all three. Leave `<!-- TODO: translate -->` if you cannot.
- Blog posts: `content/aktuelles/YYYY-MM-DD-slug.md`. No `date` field (Zola
  derives it from the filename). Frontmatter needs `title`, `description`,
  `template = "blog-post.html"`, `[extra] image`, and a matching thumbnail in
  `static/imgs/thumbs/<basename>.jpg`.
- `[taxonomies] tags` are per-language: DE `Veranstaltung`, EN `Event`,
  ES `Evento`. Translate the tag, do not copy the German.
- Voice: plain, warm, German-native, first-person plural (`wir`). No em/en
  dashes. Proper nouns (Tündern, Windmühle Tündern) are never translated.
- After changes: run the `i18n-sync` audit, then `zola build`.
