# Delphix
These add to the team's instructions in `/etc/claude-code/CLAUDE.md`, which cover the knowledge graph's location and mechanics.

## Knowledge graph or wiki
Two corpora back Delphix work: the team knowledge graph (`$KG_DIR`) and the personal wiki. If a page would help a teammate, it belongs in the knowledge graph, not the wiki; the wiki keeps Delphix knowledge that stays personal.

## Durable memory
The knowledge graph is the first durable destination, for Delphix knowledge worth sharing with the team. Write it with `/kg:ingest` and its siblings. Its marker carries a `kg` prefix and resolves against `$KG_DIR`:

```
**Durable:** kg [title](<bucket>/<page>.md)
```

## Branches and worktrees
- `dev-workflow:starting-a-development-branch` creates `projects/<slug>` branches with the right upstream.
- Hotfix branches keep their hotfix key (`HF-1610`), and so does their worktree slug: pass the key as the `EnterWorktree` name, giving `worktrees/HF-1610/{appliance-build,linux-pkg,linux-kernel}`.
- Never create a worktree in `/nas`.

## Jenkins tokens
Jenkins API tokens go in `~/.gitconfig.local`. When a skill says to run `git config --global` for one, or to write a separate file such as `~/.gitconfig-dlpx-jenkins` and include it, write to `~/.gitconfig.local` instead.
