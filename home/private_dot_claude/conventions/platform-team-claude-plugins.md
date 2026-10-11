# platform-team-claude-plugins conventions

## PRs land without review: set auto-merge

Changes go through a pull request, but nobody needs to review them. Once the PR
is open, run `gh pr merge <N> --auto --squash`. The repo has no required checks,
so it usually merges immediately. Bump the plugin's version in both
`plugin.json` and `.claude-plugin/marketplace.json` (repo CLAUDE.md), and run
`claude plugin validate plugins/<name>` first.

## Leave `plugins/headless/` alone

We don't use or maintain the plugins under `plugins/headless/` (e.g. the
bugfix-pipeline silo). Don't edit them, bump them, or run their `check-*.sh`
scripts, even when a change elsewhere (retiring a skill they reference, say)
would otherwise touch them. Mention any remaining headless references instead.
