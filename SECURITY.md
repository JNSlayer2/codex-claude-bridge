# Security Notes

Codex Claude Bridge is a small shell-based integration layer. It is not a security sandbox.

## Boundaries

- Codex remains the primary operator.
- Claude is invoked as a secondary reviewer through non-interactive `claude -p`.
- Review mode denies Claude file-edit tools.
- Trading, funds, orders, leverage, production secrets, and destructive operations should be treated as high-risk.

## Secrets

Do not commit or paste:

- API keys
- OAuth tokens
- Trading credentials
- Private keys
- Local absolute paths containing private project names
- Personal logs or report output

## Reporting Issues

For private deployments, report issues through your normal repository issue tracker or security contact.

## No Absolute Protection Claim

This project cannot guarantee that a local machine, model output, shell command, or repository is impossible to inspect or reverse engineer. Use normal secret-management, least-privilege, and review practices.
