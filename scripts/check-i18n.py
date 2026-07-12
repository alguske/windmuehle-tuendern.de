#!/usr/bin/env python3
"""i18n parity check for the Windmühle Tündern site.

Verifies:
  1. config.toml [translations], [languages.en.translations], and
     [languages.es.translations] expose the same set of keys.
  2. Every content file under content/ has counterparts in en/ and es/
     (and vice versa), with matching filenames.

Exits non-zero on drift so it can gate CI.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "config.toml"
CONTENT = ROOT / "content"

# Sections recognized inside config.toml, in render order.
SECTIONS = [
    ("de", r"^\[translations\]\s*$"),
    ("en", r"^\[languages\.en\.translations\]\s*$"),
    ("es", r"^\[languages\.es\.translations\]\s*$"),
]
NEXT_SECTION = re.compile(r"^\[[^\]]+\]\s*$")
KEY = re.compile(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*=")


def parse_translation_keys() -> dict[str, set[str]]:
    text = CONFIG.read_text(encoding="utf-8").splitlines()
    result: dict[str, set[str]] = {lang: set() for lang, _ in SECTIONS}
    section_headers = {lang: re.compile(pat) for lang, pat in SECTIONS}

    current: str | None = None
    for line in text:
        stripped = line.strip()
        # Switch sections.
        for lang, header in section_headers.items():
            if header.match(stripped):
                current = lang
                break
        else:
            if current and NEXT_SECTION.match(stripped) and not any(
                h.match(stripped) for h in section_headers.values()
            ):
                current = None
        if current and "=" in line and not stripped.startswith("#"):
            m = KEY.match(stripped)
            if m:
                result[current].add(m.group(1))
    return result


def check_translation_parity() -> list[str]:
    keys = parse_translation_keys()
    errors: list[str] = []
    de, en, es = keys["de"], keys["en"], keys["es"]

    for label, missing in (
        ("EN missing keys present in DE", de - en),
        ("ES missing keys present in DE", de - es),
        ("DE missing keys present in EN", en - de),
        ("DE missing keys present in ES", es - de),
        ("EN missing keys present in ES", es - en),
        ("ES missing keys present in EN", en - es),
    ):
        if missing:
            errors.append(f"{label}: {sorted(missing)}")
    return errors


def list_content(lang: str) -> set[str]:
    """Relative paths of content files for a given language.

    DE lives at the root of content/. EN under content/en/. ES under content/es/.
    Returned paths are relative to the language root so they're directly comparable.
    """
    base = CONTENT if lang == "de" else CONTENT / lang
    if not base.is_dir():
        return set()
    out: set[str] = set()
    for path in base.rglob("*.md"):
        rel = path.relative_to(base)
        parts = rel.parts
        # Skip the other-language subtrees when scanning DE root.
        if lang == "de" and parts and parts[0] in {"en", "es"}:
            continue
        # Per-directory agent config, not translatable site content.
        if rel.name in {"AGENTS.md", "CLAUDE.md"}:
            continue
        out.add(str(rel))
    return out


def check_content_parity() -> list[str]:
    de = list_content("de")
    en = list_content("en")
    es = list_content("es")
    errors: list[str] = []
    for label, missing in (
        ("EN missing content files present in DE", de - en),
        ("ES missing content files present in DE", de - es),
        ("DE missing content files present in EN", en - de),
        ("DE missing content files present in ES", es - de),
    ):
        if missing:
            errors.append(f"{label}: {sorted(missing)}")
    return errors


def main() -> int:
    errors = check_translation_parity() + check_content_parity()
    if errors:
        print("i18n parity check FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("i18n parity OK: translation keys + content files in sync.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
