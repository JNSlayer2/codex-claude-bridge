#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
BIN_DIR="$CODEX_HOME_DIR/bin"
SKILL_DIR="$CODEX_HOME_DIR/skills/codex-claude-bridge"
AGENTS_FILE="$CODEX_HOME_DIR/AGENTS.md"
LOCAL_BIN="${CODEX_CLAUDE_BRIDGE_LINK_DIR:-$HOME/.local/bin}"

mkdir -p "$BIN_DIR" "$CODEX_HOME_DIR/skills" "$CODEX_HOME_DIR/log" "$LOCAL_BIN"

install -m 0755 "$ROOT_DIR/bin/codex-claude-bridge" "$BIN_DIR/codex-claude-bridge"
rm -rf "$SKILL_DIR"
mkdir -p "$SKILL_DIR"
cp -R "$ROOT_DIR/skill/codex-claude-bridge/." "$SKILL_DIR/"
ln -sf "$BIN_DIR/codex-claude-bridge" "$LOCAL_BIN/codex-claude-bridge"

python3 - "$AGENTS_FILE" "$BIN_DIR/codex-claude-bridge" <<'PY'
from pathlib import Path
import sys

agents = Path(sys.argv[1])
bridge = sys.argv[2]
start = "<!-- codex-claude-bridge:start -->"
end = "<!-- codex-claude-bridge:end -->"
block = f"""{start}
## Codex Claude Bridge

When the user asks to call Claude, use Claude as a secondary brain, perform cross-validation, or review high-risk automated trading changes, Codex may call:

```bash
{bridge} ask "question"
{bridge} review --cwd /path/to/repo "review request"
{bridge} trade-review --cwd /path/to/repo "trading risk review request"
```

Triggers include: "ask Claude", "Claude副腦", "collaborate with Claude", "cross-check with Claude", "交叉驗證", "交易副審", "風控副審".

Use `doctor --json` to verify the bridge, `status --json` to inspect active bridge/Claude/reporting processes, and `last --result-only` to fetch the latest result. Codex remains the primary operator: Claude's response is advisory evidence, while Codex owns final edits, tests, decisions, and user-facing conclusions. For live trading, funds, orders, leverage, stop-loss, position sizing, secrets, or destructive operations, use `trade-review` and do not let Claude execute those actions directly.
{end}
"""
text = agents.read_text(encoding="utf-8") if agents.exists() else ""
if start in text and end in text:
    before = text.split(start, 1)[0].rstrip()
    after = text.split(end, 1)[1].lstrip()
    text = f"{before}\n\n{block}\n{after}".strip() + "\n"
else:
    text = (text.rstrip() + "\n\n" + block).strip() + "\n"
agents.parent.mkdir(parents=True, exist_ok=True)
agents.write_text(text, encoding="utf-8")
PY

cat <<EOF
Installed Codex Claude Bridge.

Bridge:
  $BIN_DIR/codex-claude-bridge

Skill:
  $SKILL_DIR

Optional PATH symlink:
  $LOCAL_BIN/codex-claude-bridge

Try:
  $BIN_DIR/codex-claude-bridge doctor --json

If your shell cannot find codex-claude-bridge, add this to PATH:
  export PATH="$LOCAL_BIN:\$PATH"
EOF
