#!/usr/bin/env bash
# Copies each shared/ file into the references/ folder of the skills listed
# for it in shared/MANIFEST. shared/ is the single source of truth; the
# copies exist because installed skills are symlinked standalone into
# ~/.claude/skills/ and cannot read back into this repo's shared/ folder.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
# Reference skills document a tool, not a workflow phase, so they get no shared/ copies.
reference_skills='grove'

while read -r file skills; do
  [[ -z "$file" || "$file" == \#* ]] && continue
  if [[ "$skills" == "*" ]]; then
    skills="$(cd "$skills_dir" && ls -d */ | tr -d / | grep -vxF -f <(echo "$reference_skills" | tr ' ' '\n'))"
  fi
  for skill in $skills; do
    mkdir -p "$skills_dir/$skill/references"
    cp "$repo_root/shared/$file" "$skills_dir/$skill/references/$file"
    echo "synced -> $skill/references/$file"
  done
done < "$repo_root/shared/MANIFEST"
