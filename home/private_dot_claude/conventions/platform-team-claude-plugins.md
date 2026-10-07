# platform-team-claude-plugins conventions

## PRs land without review: set auto-merge

Changes go through a pull request, but nobody needs to review them. Once the PR
is open, run `gh pr merge <N> --auto --squash`. The repo has no required checks,
so it usually merges immediately. Bump the plugin's version in both
`plugin.json` and `.claude-plugin/marketplace.json` (repo CLAUDE.md), and run
`claude plugin validate plugins/<name>` first.
