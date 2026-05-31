#!/usr/bin/env bash
set -Eeuo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
AGENTS_FILE="$CODEX_HOME_DIR/AGENTS.md"
LOCAL_BIN="${CODEX_CLAUDE_BRIDGE_LINK_DIR:-$HOME/.local/bin}"

rm -f "$CODEX_HOME_DIR/bin/codex-claude-bridge"
rm -f "$LOCAL_BIN/codex-claude-bridge"
rm -rf "$CODEX_HOME_DIR/skills/codex-claude-bridge"

if [ -f "$AGENTS_FILE" ]; then
  python3 - "$AGENTS_FILE" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
start = "<!-- codex-claude-bridge:start -->"
end = "<!-- codex-claude-bridge:end -->"
text = path.read_text(encoding="utf-8")
if start in text and end in text:
    before = text.split(start, 1)[0].rstrip()
    after = text.split(end, 1)[1].lstrip()
    path.write_text((before + "\n\n" + after).strip() + "\n", encoding="utf-8")
PY
fi

echo "Removed Codex Claude Bridge files. Local logs are left in place."
