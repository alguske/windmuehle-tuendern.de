# Windmühle Tündern Website

Official site of the non-profit association restoring the historic windmill in Tündern, Germany.

## Tech stack

- [Zola](https://www.getzola.org/) static site generator. Build: `zola build`. Preview: `zola serve`.
- Tera templates in `templates/`, Sass in `sass/main.scss`.
- Trilingual: German (default), English (`/en`), Spanish (`/es`). Every content change must cover all three. See [`.claude/CLAUDE.md`](./.claude/CLAUDE.md).

## Scripts

All scripts live in `scripts/`, are offline and idempotent. Bashunit tests in `scripts/tests/`.

| Script | Purpose |
|---|---|
| `new-post.sh <slug> [opts]` | Scaffold an Aktuelles post in DE / EN / ES, optimize images, generate thumbnail |
| `make-thumb.sh <image-path>` | Swap a post's hero image and regenerate its thumbnail across all three languages |
| `new-tour.sh --date ... --time ... --kind ...` | Append a guided tour entry to `data/fuehrungen.toml` |
| `validate-fuehrungen.py` | Lint `data/fuehrungen.toml` shape and field values |
| `mark-for-translation.sh <dir>` | Reset every `.md` in a directory to `to be translated` |

### `new-post.sh` options

```
-d, --dir <path>          Source image directory (default: local/imgs/)
-t, --title <string>      Post title (default: slug humanized)
-s, --summary <string>    Description (default: title)
-D, --date <YYYY-MM-DD>   Post date (default: today)
```

Filenames follow `YYYY-MM-DD-<slug>.md`. Zola derives `page.date` from the filename, so frontmatter has no `date` field.

## Blog post workflow

1. Drop source images into `local/imgs/` (gitignored).
2. `./scripts/new-post.sh <slug> -s "Kurze Beschreibung."`
3. Edit the DE post in `content/aktuelles/YYYY-MM-DD-<slug>.md`. Add headings, group images in `<div class="post-images">` blocks of even size.
4. Translate the EN and ES stubs in `content/en/aktuelles/` and `content/es/aktuelles/`. Remove the `<!-- TODO: translate -->` marker.
5. Optional: `./scripts/make-thumb.sh <image-path>` to swap the hero.
6. `zola build && zola serve`, verify all locales.
7. Commit with a conventional message.

See `content/aktuelles/2026-04-17-einweihung-der-windmuehle.md` for a structured example.

## Führungen (guided tours)

The page at `/fuehrungen/` lists upcoming tours. Data lives in `data/fuehrungen.toml`. Edit and run `zola build`.

Slot fields:

| Field | Required | Notes |
|---|---|---|
| `date` | yes | `YYYY-MM-DD`, Europe/Berlin |
| `time` | yes | 24h `HH:MM` |
| `duration_min` | no | integer, defaults to `60` |
| `kind` | yes | `"public"` or `"private"` |
| `status` | yes | `"free"`, `"booked"` or `"cancelled"`. Private cannot be `"free"` |
| `guide` | no | first name(s), e.g. `"Dirk"` or `"Falk & Philipp"` |

```toml
[[slots]]
date = "2026-06-14"
time = "14:00"
kind = "public"
status = "free"
guide = "Dirk"
```

Notes:
- Past tours auto-move into a collapsible archive grouped by year.
- Private slots show only `kind`, `time` and `guide`. Never include family or group names in the data file.
- JSON-LD `Event` schema is emitted only for upcoming public, non-cancelled slots.
- Phone numbers on the contact card are base64-encoded and revealed on click. See `static/js/contact-reveal.js`.
- Run `./scripts/validate-fuehrungen.py` after editing.

## Testing

```bash
./scripts/lib/bashunit scripts/tests
```

Add or update tests when changing script behavior.

## For AI agents

Read [`.claude/CLAUDE.md`](./.claude/CLAUDE.md) for voice, tone, image layout rules and the creative freedom expected when drafting or enriching content.
