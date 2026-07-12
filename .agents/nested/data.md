# data/ — build-time data

Scope note for agents working in this directory. Full schema: the "Führungen"
section of the root `AGENTS.md`; workflow in the `new-tour` playbook
(`.agents/skills/new-tour/SKILL.md`).

`fuehrungen.toml` is the source of truth for the Führungen page (one `[[slots]]`
table per entry). `restoration.toml` and `nav.toml` feed the homepage and nav.

- Slot `kind`: `public`, `private`, or `event` (non-tour, e.g. a concert).
- Private slots must never contain family names, group names, or any
  identifier. The page renders only `kind`, `time`, and `guide` for them.
- Events use `title` (required) plus optional `location` / `free_entry`; they
  are added by editing this file directly (`new-tour.sh` handles tours only).
- Cancel by setting `status = "cancelled"`, never by deleting the entry.

Before committing any change here: `./scripts/validate-fuehrungen.py`
(needs Python 3.11+), then `zola build`.
