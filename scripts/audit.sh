#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail=0

echo "== file list =="
find . -path './.git' -prune -o -maxdepth 4 -type f -print | sort

echo "== local/private pattern scan =="
patterns=(
  '/''Users/'
  '/''Volumes/'
  'gho_''[A-Za-z0-9_]+'
  'github_pat_''[A-Za-z0-9_]+'
  'sk-''[A-Za-z0-9_-]{20,}'
  'ANTHROPIC''_API_KEY'
  'OPENAI''_API_KEY'
  'BEGIN OPENSSH ''PRIVATE KEY'
  'BEGIN RSA ''PRIVATE KEY'
  'jnslayer2''@gmail.com'
  'lay''er2'
)

for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!/.git/**' --glob '!scripts/audit.sh' --pcre2 "$pattern" . >/tmp/codex-claude-bridge-audit-hit 2>/dev/null; then
    echo "FOUND: $pattern"
    cat /tmp/codex-claude-bridge-audit-hit
    fail=1
  fi
done
rm -f /tmp/codex-claude-bridge-audit-hit

echo "== apple metadata scan =="
if find . -path './.git' -prune -o \( -name '.DS_Store' -o -name '._*' -o -name '.__*' \) -print | grep .; then
  fail=1
fi

echo "== shell syntax =="
bash -n bin/codex-claude-bridge
bash -n install.sh
bash -n uninstall.sh
bash -n scripts/audit.sh

if [ "$fail" -ne 0 ]; then
  echo "Audit failed."
  exit 1
fi

echo "Audit passed."
