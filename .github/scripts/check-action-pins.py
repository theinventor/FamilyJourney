#!/usr/bin/env python3
"""Fail when a workflow or composite action uses a mutable remote ref.

Remote actions and reusable workflows must be pinned to a full 40-character
commit SHA. Local ./ actions are allowed. docker:// images must use an
immutable digest. The check is local and uses no secrets.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

SHA40 = re.compile(r"^[0-9a-fA-F]{40}$")
DIGEST = re.compile(r"@(sha256:[0-9a-fA-F]{64}|sha512:[0-9a-fA-F]{128})$")
USES_LINE = re.compile(r"^\s*(?:-\s+)?uses:\s*(.*?)\s*$")
BLOCK_INDICATOR = re.compile(r"^[|>][+-]?$")
BLOCK_KEY_LINE = re.compile(r"^(\s*(?:-\s+)?)[^:#\s][^:]*:\s*[|>][+-]?\s*(#.*)?$")
SKIP_DIRS = {".git", "node_modules", "vendor", "tmp", "log"}


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def key_column(line: str) -> int:
    column = 0
    while column < len(line) and line[column] == " ":
        column += 1
    if line[column : column + 2] == "- ":
        column += 2
        while column < len(line) and line[column] == " ":
            column += 1
    return column


def content_column(line: str) -> int:
    column = 0
    while column < len(line) and line[column] == " ":
        column += 1
    return column


def parse_scalar(raw: str) -> str:
    text = raw.strip()
    if not text:
        return ""
    if text[0] in {"'", '"'}:
        quote = text[0]
        end = text.find(quote, 1)
        body = text[1:] if end == -1 else text[1:end]
        return body.strip()
    comment = text.find(" #")
    if comment != -1:
        text = text[:comment]
    return text.strip()


def is_block_indicator(raw: str) -> bool:
    return BLOCK_INDICATOR.fullmatch(parse_scalar(raw)) is not None


def read_block(lines: list[str], start: int, key_col: int) -> str:
    chunks: list[str] = []
    index = start + 1
    while index < len(lines):
        line = lines[index]
        if line.strip() and content_column(line) <= key_col:
            break
        chunks.append(line.strip())
        index += 1
    return " ".join(chunk for chunk in chunks if chunk).strip()


def evaluate(value: str) -> str | None:
    if value.startswith("./"):
        return None
    if value.startswith("docker://"):
        image = value[len("docker://") :]
        if DIGEST.search(image) is None:
            return "docker:// image is not pinned to an immutable digest"
        return None
    if "@" not in value or "/" not in value.split("@", 1)[0]:
        return "remote action ref is not a full commit SHA"
    ref = value.rsplit("@", 1)[1]
    if SHA40.fullmatch(ref) is None:
        return "mutable remote ref (branch, tag, or short SHA)"
    return None


def scan_text(relative_path: str, text: str) -> list[str]:
    lines = text.splitlines()
    errors: list[str] = []
    block_key_col: int | None = None
    index = 0
    while index < len(lines):
        line = lines[index]
        if block_key_col is not None:
            if not line.strip() or content_column(line) > block_key_col:
                index += 1
                continue
            block_key_col = None

        stripped = line.lstrip()
        if not stripped or stripped.startswith("#"):
            index += 1
            continue

        match = USES_LINE.match(line)
        if match:
            key_col = key_column(line)
            raw = match.group(1)
            if is_block_indicator(raw):
                value = read_block(lines, index, key_col)
                block_key_col = key_col
            elif parse_scalar(raw) == "":
                value = read_block(lines, index, key_col)
            else:
                value = parse_scalar(raw)
            problem = evaluate(value)
            if problem:
                errors.append(f"{relative_path}:{index + 1}: {problem}: {value}")
            index += 1
            continue

        if BLOCK_KEY_LINE.match(line):
            block_key_col = key_column(line)
        index += 1
    return errors


def iter_targets(root: Path) -> list[Path]:
    targets: list[Path] = []
    workflows = root / ".github" / "workflows"
    if workflows.is_dir():
        targets.extend(sorted(workflows.rglob("*.yml")))
        targets.extend(sorted(workflows.rglob("*.yaml")))
    for path in sorted(root.rglob("action.y*ml")):
        if not path.is_file():
            continue
        if path.name not in {"action.yml", "action.yaml"}:
            continue
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        targets.append(path)
    return targets


def check_root(root: Path) -> list[str]:
    errors: list[str] = []
    targets = iter_targets(root)
    if not targets:
        return [f"{root}: no workflow files found under .github/workflows"]
    for path in targets:
        relative = path.relative_to(root).as_posix()
        errors.extend(scan_text(relative, path.read_text(encoding="utf-8")))
    return errors


def main(argv: list[str]) -> int:
    root = Path(argv[1]).resolve() if len(argv) > 1 else repo_root()
    errors = check_root(root)
    if errors:
        print("Unpinned GitHub Actions references:", file=sys.stderr)
        for error in errors:
            print(f"  {error}", file=sys.stderr)
        return 1
    checked = len(iter_targets(root))
    print(f"Action references are pinned ({checked} workflow/action file(s) checked).")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
