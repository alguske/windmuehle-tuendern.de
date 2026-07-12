# data/ — build-time data

Routing note (kept thin on purpose; the canonical schema lives once in the root
`AGENTS.md`). `fuehrungen.toml` drives the Führungen page. Before editing, read:

- root `AGENTS.md` → "Führungen (guided tours) data"
- the `new-tour` playbook → `.agents/skills/new-tour/SKILL.md`

Two reflexes that catch most mistakes in this directory: never put names or other
identifiers in private slots, and you run `./scripts/validate-fuehrungen.py`
(Python 3.11+) plus `zola build` before committing.
