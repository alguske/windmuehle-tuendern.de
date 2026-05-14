# Add or update a guided tour

Add, update or cancel a guided tour entry in `data/fuehrungen.toml`. The Führungen page (`/fuehrungen/`) reads from this file at build time.

## Inputs to ask for if not provided

- Date (`YYYY-MM-DD`, Europe/Berlin time zone)
- Time (`HH:MM`, 24h)
- Duration in minutes (defaults to 60)
- Kind: `public` (anyone can attend) or `private` (closed group, opaque on page)
- Status: `free`, `booked` or `cancelled`. Private slots cannot be `free`.
- Guide first name(s), e.g. `Dirk` or `Falk & Philipp`

## Where to edit

`data/fuehrungen.toml`. One `[[slots]]` table per tour. No content files need to change.

## Slot template

```toml
[[slots]]
date = "YYYY-MM-DD"
time = "HH:MM"
duration_min = 60
kind = "public"     # "public" or "private"
status = "free"     # "free", "booked", "cancelled"
guide = "Firstname"
```

## Conventions

- Private slot details (family name, group, host) MUST NEVER appear in the data file or anywhere on the site. Only `kind`, `time` and `guide` are rendered for private slots.
- Past tours auto-move into a collapsible archive grouped by year. No manual cleanup needed.
- The JSON-LD `Event` schema is emitted only for upcoming `public`, non-cancelled slots.
- Phone numbers and meeting point are static in `templates/fuehrungen.html`; do not touch them here.

## After editing

1. Run `./scripts/validate-fuehrungen.py` and fix any reported issues.
2. Run `zola build` and confirm it exits cleanly.
3. Commit with a conventional message, e.g. `content: add tour 2026-06-21 Stappel`. For a cancellation: `content: cancel tour 2026-07-12 Stappel`.

## Examples

Add a public free slot:

```toml
[[slots]]
date = "2026-08-09"
time = "15:00"
kind = "public"
status = "free"
guide = "Dirk"
```

Cancel an existing tour: change its `status` to `"cancelled"`.

Re-assign the guide for a booked tour: change its `guide` field.

$ARGUMENTS
