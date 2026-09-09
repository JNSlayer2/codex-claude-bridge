> [!NOTE]
> **定位（2026-09-09）：這是單向的 Codex→Claude 副審通道，不是多模型協作框架。**
>
> 它做的事在 TATWO OS 裡已經一般化了：OS 把 codex／claude／grok 當同一層可替換的執行介面，
> 派工、工作副本、驗收都在 OS 這一層，方向也不只單向。
> 協作主線請看 **TATWO OS 2.0 公開版**：https://github.com/tatwo214/TATWO-ULTRAWORK-beta
>
> **那為什麼還留著？** 因為 OS 的派工需要 App 開著（走 App 持有的 socket），
> 而這支是純命令列工具，在 headless 的 Codex session、`codex exec`、排程裡仍然可用。
> 上游正在讓 OS 長出同樣的 headless 入口（三家引擎、同一份稽核格式）；
> 接上之後這個倉庫會封存，屆時會在這裡再標一次。
>
> 使用量供參：本機稽核紀錄 802 次呼叫、95% 成功（2026-04～09），仍在使用中。
>
> ---
>
> **Scope (2026-09-09): this is a one-way Codex→Claude review channel, not a multi-model
> collaboration framework.** TATWO OS generalises the same idea — codex/claude/grok as one
> interchangeable engine layer, with dispatch, worktrees and acceptance handled above them.
> See https://github.com/tatwo214/TATWO-ULTRAWORK-beta
>
> **Why it is still here:** OS dispatch needs the App running (it goes through a socket the App
> owns). This tool is pure CLI and still works in headless Codex sessions, `codex exec`, and cron.
> Upstream is growing an equivalent headless entry point for the OS; this repository will be
> archived once that lands, and the note here will be updated at that time.

# Codex Claude Bridge

Codex Claude Bridge lets Codex call Claude as a secondary verifier, reviewer, or risk critic while keeping Codex as the primary operator.

It avoids Claude's interactive terminal UI and always calls Claude through non-interactive `claude -p --output-format json`.

## What It Installs

- `codex-claude-bridge` command
- A Codex skill named `codex-claude-bridge`
- A small `AGENTS.md` rule block that tells Codex when to call Claude

## Requirements

- Codex CLI or Codex App
- Claude Code CLI authenticated on the same machine
- Python 3
- Bash

Optional:

- Report-compatible CLI for report logging, configured through environment variables

## One-Line Install For Codex Users

If you already have access to this repository, paste this into Codex App or Codex CLI:

```text
Clone this repository into a temporary directory, run ./install.sh from the repository root, then run codex-claude-bridge doctor --json and summarize the result.
```

Or run the same install directly from a shell, replacing the placeholder with the Git clone URL shown by GitHub:

```bash
repo_url="<repository-git-url>" && tmpdir="$(mktemp -d)" && git clone "$repo_url" "$tmpdir/codex-claude-bridge" && cd "$tmpdir/codex-claude-bridge" && ./install.sh && "${CODEX_HOME:-$HOME/.codex}/bin/codex-claude-bridge" doctor --json
```

## Install

Clone this repository, then run:

```bash
./install.sh
```

Run a health check:

```bash
codex-claude-bridge doctor --json
```

If your shell cannot find the command, either call it directly from your Codex home:

```bash
$HOME/.codex/bin/codex-claude-bridge doctor --json
```

or add the installer-created local bin path to `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Ask Claude for a bounded second opinion:

```bash
codex-claude-bridge ask "Check this plan for missing risks."
```

Ask for a code review:

```bash
codex-claude-bridge review --cwd /path/to/repo "Review the current diff."
```

Ask for a high-risk trading-system review:

```bash
codex-claude-bridge trade-review --cwd /path/to/repo "Review risk controls and failure modes."
```

Check status:

```bash
codex-claude-bridge status --json
```

Read the latest result:

```bash
codex-claude-bridge last --result-only
```

## Model Routing

By default, `--model auto --effort auto` chooses a model and reasoning effort based on the task:

- Small consults may use Haiku.
- Code reviews may use Sonnet.
- Trading risk, high-risk architecture, or deep delegation may use Opus with max effort.

High-risk `trade-review` runs may take several minutes. If a caller passes a very short `--timeout-sec`, the bridge raises it to a safer local floor of 900 seconds by default. Override that floor with:

```bash
export CODEX_CLAUDE_BRIDGE_TRADE_REVIEW_MIN_TIMEOUT_SEC=1200
```

You can override this:

```bash
codex-claude-bridge ask --model sonnet --effort high "Question"
```

## Logging

Local JSONL logs are written to:

```text
$CODEX_HOME/log/claude-bridge.jsonl
```

or, when `CODEX_HOME` is unset:

```text
$HOME/.codex/log/claude-bridge.jsonl
```

Report logging is opt-in. Set both:

```bash
export CODEX_CLAUDE_BRIDGE_REPORT_CMD=/path/to/report-command
export CODEX_CLAUDE_BRIDGE_REPORT_REPO=/path/to/report-repo
```

## Safety Boundary

This project reduces accidental local data leakage by:

- Avoiding interactive Claude terminal mode
- Keeping Codex as final decision maker
- Logging only bounded prompt previews and Claude results
- Treating Claude output as advisory evidence
- Disallowing file edits in review mode
- Using timeouts for Claude and optional report logging

It does not make any machine, model, or repository impossible to reverse engineer or compromise. Do not place API keys, trading credentials, private data, or production secrets in prompts, logs, documentation, or repository files.

## Uninstall

```bash
./uninstall.sh
```

Local logs are intentionally left in place.
