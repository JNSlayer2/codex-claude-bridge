---
name: codex-claude-bridge
description: Use when Codex should call Claude as a secondary verifier, reviewer, critic, or trading-system risk checker. Trigger when the user says ask Claude, Claude副腦, collaborate with Claude, cross-check with Claude, 交叉驗證, or when high-risk automated trading code needs independent review.
---

# Codex Claude Bridge

Use `codex-claude-bridge` when Claude should assist but Codex must remain the primary operator.

## Commands

- Quick second opinion: `codex-claude-bridge ask "question"`
- Code review: `codex-claude-bridge review --cwd /path/to/repo "review request"`
- Trading-system risk review: `codex-claude-bridge trade-review --cwd /path/to/repo "risk review request"`
- Health check: `codex-claude-bridge doctor --json`
- State: `codex-claude-bridge status --json`
- Latest result: `codex-claude-bridge last --result-only`

## Modes

- `consult`: no Claude tools, best for short second opinions.
- `review`: read/search/git/test-oriented tools, no file edits.
- `delegate`: higher-power Claude run; use only when the user asks for deep delegation or the task clearly needs it.

Leave `--model auto --effort auto` unless there is a strong reason to force a model. Auto routing may use Opus/max effort for trading, risk, architecture, or complex verification.

Use `--timeout-sec N` for bounded runs. `0` disables the Claude timeout. High-risk `trade-review` runs are allowed to raise too-short values to the local floor (`CODEX_CLAUDE_BRIDGE_TRADE_REVIEW_MIN_TIMEOUT_SEC`, default 900) because Opus/max repository reviews often exceed 240 seconds. Optional Report logging writes are bounded separately by `--report-timeout-sec N`.

## Operating Rules

- Codex owns final decisions, edits, tests, and user-facing conclusions.
- Treat Claude output as evidence, not authority.
- For trading, live execution, keys, funds, orders, leverage, and risk controls, prefer `trade-review` and do not let Claude place trades or perform destructive actions.
- Important runs are logged to `$CODEX_HOME/log/claude-bridge.jsonl` or `$HOME/.codex/log/claude-bridge.jsonl`.
- Report logging is opt-in through `CODEX_CLAUDE_BRIDGE_REPORT_CMD` and `CODEX_CLAUDE_BRIDGE_REPORT_REPO`.
