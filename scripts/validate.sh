#!/usr/bin/env bash
# Lints the skills/ and commands/ trees. Exits non-zero on any failure.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
commands_dir="$repo_root/commands"
fail=0

name_regex='^[a-z0-9]+(-[a-z0-9]+)*$'
allowed_fields='name description license compatibility metadata disable-model-invocation'

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

  # references/ in sync with shared/.
  for f in contract.md gates.md; do
    if ! diff -q "$repo_root/shared/$f" "$skill_dir/references/$f" >/dev/null 2>&1; then
      err "$skill_name: references/$f out of sync with shared/$f (run scripts/sync-shared.sh)"
    fi
  done
  if [[ "$skill_name" == "grove-setup" ]]; then
    if ! diff -q "$repo_root/shared/config.schema.json" "$skill_dir/references/config.schema.json" >/dev/null 2>&1; then
      err "$skill_name: references/config.schema.json out of sync with shared/config.schema.json (run scripts/sync-shared.sh)"
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

if ! bash "$repo_root/scripts/validate-fixtures.sh"; then
  fail=1
fi

if (( fail == 0 )); then
  echo "OK: all skills validated"
fi
exit $fail
