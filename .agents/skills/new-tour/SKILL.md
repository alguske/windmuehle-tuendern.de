---
description: Add, update or cancel a guided tour entry in data/fuehrungen.toml for the Windmühle Tündern Führungen page. Use when the user says "new tour", "add a tour", "cancel tour", "update tour", "schedule a Mühlenführung", "neue Führung", "Führung absagen", or invokes /new-tour. Auto-trigger when the user describes a booking by date and family / group name.
argument-hint: "[date HH:MM kind guide]"
---

# Add or update a guided tour

The Führungen page (`/fuehrungen/`) reads from `data/fuehrungen.toml` at build time. Edit that file to add, update or cancel a tour. No content files need to change.

## Inputs to ask for if not provided

| Field | Required | Notes |
|---|---|---|
| `date` | yes | `YYYY-MM-DD`, Europe/Berlin |
| `time` | yes | `HH:MM` 24h |
| `duration_min` | no | integer, defaults to `60` |
| `kind` | yes | `"public"` (anyone), `"private"` (closed group), or `"event"` (non-tour event, see below) |
| `status` | yes | `"free"`, `"booked"` or `"cancelled"`. Private cannot be `"free"` |
| `guide` | no | first name(s), e.g. `"Dirk"` or `"Falk & Philipp"` (tours only) |

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

## Events (kind = "event")

Non-tour events (a concert, a talk) live in the same file so they show on the same calendar, but render differently: a title and optional venue instead of a guide, and no duration. Extra fields:

| Field | Required | Notes |
|---|---|---|
| `title` | yes | event name, e.g. `"Benefizkonzert Frauenchor Tündern"` |
| `location` | no | venue when it is not the mill, e.g. `"St. Christophorus-Kirche in Tündern"` |
| `free_entry` | no | bool; `true` shows an "Eintritt frei" badge |

`status` is `"free"` (happening) or `"cancelled"`. Events are **not** supported by `new-tour.sh` (public/private only), so add them by editing `data/fuehrungen.toml` directly:

```toml
[[slots]]
date = "2026-08-29"
time = "17:00"
kind = "event"
status = "free"
title = "Benefizkonzert Frauenchor Tündern"
location = "St. Christophorus-Kirche in Tündern"
free_entry = true
link = "/aktuelles/benefizkonzert-frauenchor/"   # optional "Mehr erfahren" link
```

Upcoming, non-cancelled events also emit JSON-LD, using `title` and `location`.

## Conventions (strict)

- Private slot details (family name, group name, host, occasion) MUST NEVER appear in the data file or anywhere on the site. The page renders only `kind`, `time` and `guide` for private slots.
- Past tours auto-move into a collapsible archive grouped by year. No manual cleanup.
- The JSON-LD `Event` schema is emitted only for upcoming `public`, non-cancelled slots. Adding a public slot enables it automatically.
- Phone numbers and meeting point are static in `templates/fuehrungen.html`. Do not touch them from this skill.

## Fast path: pure bash script

For straightforward adds, use the script directly (no AI involvement):

```bash
./scripts/new-tour.sh --date 2026-08-09 --time 15:00 --kind public --guide Dirk
```

Flags: `--date`, `--time`, `--kind`, optional `--status`, `--duration`, `--guide`. The script validates inputs, defaults `status` to `free` for public / `booked` for private, and appends a new `[[slots]]` table to `data/fuehrungen.toml`. Run `./scripts/validate-fuehrungen.py` and `zola build` after.

Use the manual edit path below when you need to update an existing slot (status change, reschedule, guide swap) since the script only appends.

## Common operations

- **Add a slot**: append a new `[[slots]]` table.
- **Cancel a slot**: change its `status` to `"cancelled"`. Do not delete the entry.
- **Reschedule**: edit `date` and / or `time` in place.
- **Re-assign guide**: edit the `guide` field.

## After editing

1. `./scripts/validate-fuehrungen.py` and fix any reported issues.
2. `zola build` and confirm clean exit.
3. Commit with a conventional message:
   - Add: `content: add tour YYYY-MM-DD <guide or family>`
   - Cancel: `content: cancel tour YYYY-MM-DD <guide or family>`
   - Update: `content: update tour YYYY-MM-DD`

## Example

Public, free, 90 minutes, Dirk:

```toml
[[slots]]
date = "2026-08-09"
time = "15:00"
duration_min = 90
kind = "public"
status = "free"
guide = "Dirk"
```
