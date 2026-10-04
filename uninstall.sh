#!/usr/bin/env bash
# Removes symlinks created by install.sh. Only removes a target if it is a
# symlink pointing back into this repo — never touches real files.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

remove_if_ours() {
  local dst="$1"
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$repo_root"/* ]]; then
    rm "$dst"
    echo "removed: $dst"
  fi
}

for dir in "$HOME/.claude/skills" "$HOME/.config/opencode/skills"; do
  [[ -d "$dir" ]] || continue
  for skill_dir in "$repo_root"/skills/*/; do
    name="$(basename "$skill_dir")"
    remove_if_ours "$dir/$name"
  done
done

if [[ -d "$HOME/.config/opencode/commands" ]]; then
  for cmd in "$repo_root"/commands/*.md; do
    name="$(basename "$cmd")"
    remove_if_ours "$HOME/.config/opencode/commands/$name"
  done
fi

echo "Done. Per-repo grove.config.json, docs/adr/, CONTEXT.md, and artifacts are left untouched."
