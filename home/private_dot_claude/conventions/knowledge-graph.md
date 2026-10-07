# knowledge-graph conventions

## Push straight to main; no pull requests

Changes to delphix/knowledge-graph, including schema, site and script
changes as well as ingests, are pushed directly to `main`. Don't open a PR.
Work on a `projects/<slug>` branch in a worktree if it helps. Rebase onto
`origin/main` and re-run the checks, then `git push origin HEAD:main`.

Before pushing, run what CI runs: `python3 scripts/gen-index.py --root . --check`,
`python3 scripts/escl-lint.py --root .`,
`python3 -m unittest discover -s scripts/tests`,
`hugo --minify --panicOnWarning` into a scratch directory, then
`scripts/check-site.py` against that output. When the change affects how the
site looks, get the user to approve a local preview first.

## Preview with hugo server --renderToMemory

`hugo.toml` mounts the repo root as content. A plain `hugo server` writes
`public/`, sees its own output as a change, and rebuilds and live-reloads every
few seconds, so mermaid diagrams flicker between rendered and raw. Always pass
`--renderToMemory`.
