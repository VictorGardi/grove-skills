#!/usr/bin/env bash
# Symlinks skills/* into ~/.claude/skills/ (read by both Claude Code and
# OpenCode) and commands/*.md into ~/.config/opencode/commands/.
#
# Idempotent: re-running just re-verifies/re-links. Refuses to clobber any
# existing non-symlink file or directory at a target path.
#
# --target opencode-only : symlink skills into ~/.config/opencode/skills/
#                           instead of ~/.claude/skills/.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_mode="claude"

for arg in "$@"; do
  case "$arg" in
    --target)
      shift_next=1
      ;;
    opencode-only)
      target_mode="opencode"
      ;;
    --target=opencode-only)
      target_mode="opencode"
      ;;
  esac
done

if [[ "$target_mode" == "opencode" ]]; then
  skills_target="$HOME/.config/opencode/skills"
else
  skills_target="$HOME/.claude/skills"
fi
commands_target="$HOME/.config/opencode/commands"

mkdir -p "$skills_target" "$commands_target"

link_one() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      echo "ok (already linked): $dst"
    else
      echo "REFUSING: $dst is a symlink to something else ($(readlink "$dst")); remove it manually"
      return 1
    fi
  elif [[ -e "$dst" ]]; then
    echo "REFUSING: $dst exists and is not a symlink; remove or move it manually"
    return 1
  else
    ln -s "$src" "$dst"
    echo "linked: $dst -> $src"
  fi
}

status=0
for skill_dir in "$repo_root"/skills/*/; do
  name="$(basename "$skill_dir")"
  link_one "${skill_dir%/}" "$skills_target/$name" || status=1
done

for cmd in "$repo_root"/commands/*.md; do
  name="$(basename "$cmd")"
  link_one "$cmd" "$commands_target/$name" || status=1
done

echo
echo "Skills linked into: $skills_target"
echo "Commands linked into: $commands_target"
if [[ "$target_mode" == "opencode" ]]; then
  echo "(opencode-only mode: Claude Code will not see these skills)"
fi
exit $status
