#!/usr/bin/env bash
# Copies shared/contract.md and shared/gates.md into every skill's
# references/ folder, and shared/config.schema.json into grove-setup's.
# shared/ is the single source of truth; the copies exist because installed
# skills are symlinked standalone into ~/.claude/skills/ and cannot read
# back into this repo's shared/ folder.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"

for skill_dir in "$skills_dir"/*/; do
  skill_name="$(basename "$skill_dir")"
  mkdir -p "$skill_dir/references"
  cp "$repo_root/shared/contract.md" "$skill_dir/references/contract.md"
  cp "$repo_root/shared/gates.md" "$skill_dir/references/gates.md"
  echo "synced -> $skill_name/references/{contract.md,gates.md}"
done

cp "$repo_root/shared/config.schema.json" "$skills_dir/grove-setup/references/config.schema.json"
echo "synced -> grove-setup/references/config.schema.json"
