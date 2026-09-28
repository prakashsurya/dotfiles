# dlpx-qa-gate conventions

## Review threads: the author resolves them

Every review conversation must be resolved before a PR lands, and **the author
resolves them** — do not wait for the reviewer to click resolve. Once a comment
has been answered or the fix is pushed, resolve the thread. Reviewers here
routinely leave a thread open after approving; that is not a signal they want
anything more.

Resolve with the GraphQL mutation (there is no `gh pr` subcommand for it):

```bash
gh api graphql -f query='{repository(owner:"delphix",name:"dlpx-qa-gate"){
  pullRequest(number:NNNN){reviewThreads(first:50){nodes{id isResolved path}}}}}' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[]
        | select(.isResolved==false) | "\(.id) \(.path)"'

gh api graphql -f query='mutation{resolveReviewThread(input:{threadId:"PRRT_..."}){
  thread{isResolved}}}'
```

## Landing a PR

`develop` requires branches to be **up to date** before merging, so an approved,
green PR still shows `mergeStateStatus: BEHIND` whenever develop moves. The two
required contexts are `General GitHub PrePush Jira Checks` and `General GitHub
PrePush Style Checks`, and they take **~13 minutes** — long enough that develop
can move again while they run and put the PR right back to `BEHIND`.

Don't update-then-merge as two separate steps. Chain
`gh pr update-branch` → poll the head SHA's combined status → `gh pr merge` in
one script, and re-verify every gate immediately before merging (approved,
mergeable, zero unresolved threads, head SHA unchanged since the checks ran).
That closes the race to seconds instead of minutes.

Merge method is **squash** (rebase merges are disabled; remote branch
auto-deletes). Pass the message explicitly — after an update-branch the PR has
more than one commit, so GitHub's default squash body degrades to a bullet list:

```bash
gh pr merge NNNN --squash \
  --subject "<TICKET> <subject> (#NNNN)" \
  --body "$(git log -1 --format=%b <original-commit>)"
```

Landed commits look like `<TICKET> <subject> (#NNNN)` with the body carrying the
rationale, a `PR URL:` line, and any `Co-Authored-By:` trailers.

## Pre-submission review

`.claude/CLAUDE.md` requires the `qa-gate-code-review` skill before raising or
updating a PR. Running its `pre-commit` step inside a worktree triggers web
wrapper generation against the shared env; the `General GitHub PrePush Style
Checks` context covers the same black/isort/flake8/copyright set, so prefer that
as the evidence rather than re-running locally.

Watch `.claude/CLAUDE.md` for semantic conflicts on rebase — it is edited often
enough that git auto-merges two unrelated rewrites cleanly while leaving the
advice self-contradictory. Diff both sides of that file by hand.
