#!/usr/bin/env bash
# Lints the skills/ and commands/ trees. Exits non-zero on any failure.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
commands_dir="$repo_root/commands"
fail=0

name_regex='^[a-z0-9]+(-[a-z0-9]+)*$'
allowed_fields='name description license compatibility metadata disable-model-invocation'
# Skills that must end with the inline approval step (grove-approve is the
# standalone form of the same procedure).
gated_skills='grove-start grove-questions grove-research grove-design grove-structure grove-approve'

# Skills that must offer the end-of-phase handoff to a new grove session.
handoff_skills='grove-start grove-questions grove-research grove-design grove-structure grove-implement'

err() { echo "FAIL: $1"; fail=1; }

for skill_dir in "$skills_dir"/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_md="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    err "$skill_name: missing SKILL.md"
    continue
  fi

  if ! [[ "$skill_name" =~ $name_regex ]]; then
    err "$skill_name: folder name violates $name_regex"
  fi

  # Extract frontmatter block between the first two '---' lines.
  frontmatter="$(awk '/^---$/{c++; next} c==1' "$skill_md")"

  fm_name="$(echo "$frontmatter" | sed -n 's/^name: *//p' | head -1)"
  if [[ "$fm_name" != "$skill_name" ]]; then
    err "$skill_name: frontmatter name '$fm_name' != folder name"
  fi
  if ! [[ "$fm_name" =~ $name_regex ]]; then
    err "$skill_name: frontmatter name '$fm_name' violates $name_regex"
  fi

  description="$(echo "$frontmatter" | sed -n 's/^description: *//p' | head -1)"
  desc_len=${#description}
  if (( desc_len < 1 || desc_len > 1024 )); then
    err "$skill_name: description length $desc_len not in 1..1024"
  fi

  # Only allowed frontmatter field keys (top-level, excludes nested/indented lines).
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    key="${line%%:*}"
    [[ "$line" == "$key"* && "$key" != "$line" ]] || continue
    key="$(echo "$key" | xargs)"
    if [[ "$skill_name" != "grove-approve" && "$key" == "disable-model-invocation" ]]; then
      err "$skill_name: 'disable-model-invocation' only allowed on grove-approve"
    fi
    if ! echo " $allowed_fields " | grep -q " $key "; then
      err "$skill_name: disallowed frontmatter field '$key'"
    fi
  done <<< "$frontmatter"

  # gated skills end with the inline approval step from shared/approve.md.
  if echo " $gated_skills " | grep -q " $skill_name "; then
    if ! grep -q 'references/approve.md' "$skill_md" || ! grep -q 'Approve now? (yes / not yet)' "$skill_md"; then
      err "$skill_name: gated skill lacks the inline approval step (references/approve.md + \"Approve now? (yes / not yet)\")"
    fi
  fi

  # phase skills offer the end-of-phase handoff from shared/next-session.md.
  if echo " $handoff_skills " | grep -q " $skill_name "; then
    if ! grep -q 'references/next-session.md' "$skill_md"; then
      err "$skill_name: phase skill lacks the new-session handoff (references/next-session.md)"
    fi
  fi

  # matching command wrapper
  if [[ ! -f "$commands_dir/$skill_name.md" ]]; then
    err "$skill_name: no matching commands/$skill_name.md wrapper"
  fi

  # no mention of third-party skills
  if grep -qEi 'grill-with-docs|improve-codebase-architecture|mattpocock' "$skill_md"; then
    err "$skill_name: mentions a third-party skill"
  fi
done

# references/ copies in sync with shared/, per shared/MANIFEST.
while read -r file skills; do
  [[ -z "$file" || "$file" == \#* ]] && continue
  [[ -f "$repo_root/shared/$file" ]] || { err "shared/MANIFEST lists missing shared/$file"; continue; }
  if [[ "$skills" == "*" ]]; then
    skills="$(cd "$skills_dir" && ls -d */ | tr -d /)"
  fi
  for skill in $skills; do
    [[ -d "$skills_dir/$skill" ]] || { err "shared/MANIFEST lists unknown skill '$skill'"; continue; }
    if ! diff -q "$repo_root/shared/$file" "$skills_dir/$skill/references/$file" >/dev/null 2>&1; then
      err "$skill: references/$file out of sync with shared/$file (run scripts/sync-shared.sh)"
    fi
  done
done < "$repo_root/shared/MANIFEST"

# No Plannotator anywhere: reviewing means reading the rendered artifact.
if hits="$(grep -rli 'plannotator' "$skills_dir" "$commands_dir" "$repo_root/shared" "$repo_root/README.md" "$repo_root/docs" 2>/dev/null)" && [[ -n "$hits" ]]; then
  err "mentions Plannotator: $(echo $hits)"
fi

# grove-plan was removed; nothing may point at it.
if hits="$(grep -rl 'grove-plan' "$skills_dir" "$commands_dir" "$repo_root/shared" 2>/dev/null)" && [[ -n "$hits" ]]; then
  err "references the removed grove-plan skill: $(echo $hits)"
fi

if ! bash "$repo_root/scripts/validate-fixtures.sh"; then
  fail=1
fi

if (( fail == 0 )); then
  echo "OK: all skills validated"
fi
exit $fail
