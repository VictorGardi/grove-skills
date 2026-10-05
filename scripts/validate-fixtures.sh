#!/usr/bin/env bash
# Structural checks over tests/fixtures/*/docs/work/*/feature.md: kind/parent/
# children consistency, plus the specific epic scenarios documented in
# tests/fixtures/README.md (targeted stale marking, child-folder creation and
# flagging on re-approval). Exits non-zero on any failure.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixtures_dir="$repo_root/tests/fixtures"
fail=0

err() { echo "FAIL: $1"; fail=1; }
ok() { echo "ok: $1"; }

frontmatter() { awk '/^---$/{c++; next} c==1' "$1"; }
field() { echo "$2" | sed -n "s/^$1: *//p" | head -1 | tr -d '"'; }
status_of() { field "status" "$(frontmatter "$1")"; }

# YAML list under a top-level key, e.g. children:\n  - a\n  - b
list_field() {
  local key="$1" file="$2"
  frontmatter "$file" | awk -v key="$key" '
    $0 ~ "^"key":" { inlist=1; next }
    inlist && /^[a-zA-Z_]+:/ { inlist=0 }
    inlist && /^[[:space:]]*-/ { gsub(/^[[:space:]]*-[[:space:]]*/, ""); print }
  '
}

for work_dir in "$fixtures_dir"/*/docs/work; do
  [[ -d "$work_dir" ]] || continue
  fixture_name="$(basename "$(dirname "$(dirname "$work_dir")")")"

  for feature_dir in "$work_dir"/*/; do
    slug="$(basename "$feature_dir")"
    fm_file="$feature_dir/feature.md"
    if [[ ! -f "$fm_file" ]]; then
      err "$fixture_name/$slug: missing feature.md"
      continue
    fi
    fm="$(frontmatter "$fm_file")"
    kind="$(field "kind" "$fm")"
    parent="$(field "parent" "$fm")"

    if [[ "$kind" != "feature" && "$kind" != "epic" ]]; then
      err "$fixture_name/$slug: kind '$kind' not in {feature, epic}"
    fi

    if [[ -n "$parent" ]]; then
      if [[ "$kind" != "feature" ]]; then
        err "$fixture_name/$slug: has parent '$parent' but kind is '$kind' (only features may have a parent)"
      fi
      parent_fm_file="$work_dir/$parent/feature.md"
      if [[ ! -f "$parent_fm_file" ]]; then
        err "$fixture_name/$slug: parent '$parent' has no feature.md"
      else
        parent_kind="$(field "kind" "$(frontmatter "$parent_fm_file")")"
        if [[ "$parent_kind" != "epic" ]]; then
          err "$fixture_name/$slug: parent '$parent' is kind '$parent_kind', not epic"
        fi
      fi
    fi

    if [[ "$kind" == "epic" ]]; then
      children="$(list_field "children" "$fm_file")"
      seen_orders=""
      for child in $children; do
        child_fm_file="$work_dir/$child/feature.md"
        if [[ ! -f "$child_fm_file" ]]; then
          err "$fixture_name/$slug: listed child '$child' has no feature.md"
          continue
        fi
        child_fm="$(frontmatter "$child_fm_file")"
        child_parent="$(field "parent" "$child_fm")"
        if [[ "$child_parent" != "$slug" ]]; then
          err "$fixture_name/$slug: child '$child' has parent '$child_parent', expected '$slug'"
        fi
        order="$(field "order" "$child_fm")"
        if [[ " $seen_orders " == *" $order "* ]]; then
          err "$fixture_name/$slug: duplicate order '$order' among children"
        fi
        seen_orders="$seen_orders $order"
      done
    fi
  done
done

# --- epic-demo: targeted stale marking ---
demo="$fixtures_dir/epic-demo/docs/work"
if [[ -d "$demo" ]]; then
  s="$(status_of "$demo/retry-epic-child-1/03-design.md")"
  [[ "$s" == "approved" ]] && ok "retry-epic-child-1/03-design.md stayed approved (out of scope of the E-D2 revision)" \
    || err "retry-epic-child-1/03-design.md status is '$s', expected 'approved' (targeted stale marking must not touch it)"

  s="$(status_of "$demo/retry-epic-child-2/03-design.md")"
  [[ "$s" == "stale" ]] && ok "retry-epic-child-2/03-design.md is stale (E-D2 revision, in its scope)" \
    || err "retry-epic-child-2/03-design.md status is '$s', expected 'stale'"

  [[ -f "$demo/retry-epic-child-3/feature.md" && ! -f "$demo/retry-epic-child-3/01-questions.md" ]] && \
    ok "retry-epic-child-3 is still in the backlog (no 01-questions.md)" \
    || err "retry-epic-child-3 should have only feature.md (backlog)"
fi

# --- epic-approve: child-folder creation + flagging on re-approval ---
appr="$fixtures_dir/epic-approve/docs/work"
if [[ -d "$appr" ]]; then
  children="$(list_field "children" "$appr/launch-epic/feature.md")"
  for must_exist in launch-epic-child-a launch-epic-child-c launch-epic-child-d; do
    [[ -f "$appr/$must_exist/feature.md" ]] && ok "$must_exist folder exists" \
      || err "$must_exist folder missing"
    echo "$children" | grep -qx "$must_exist" && ok "$must_exist is in launch-epic's current children:" \
      || err "$must_exist missing from launch-epic's children: list"
  done

  [[ -f "$appr/launch-epic-child-b/feature.md" ]] && ok "launch-epic-child-b folder kept (not deleted)" \
    || err "launch-epic-child-b folder should still exist (flagged, never deleted)"
  [[ -f "$appr/launch-epic-child-b/FLAGGED.md" ]] && ok "launch-epic-child-b carries a flag" \
    || err "launch-epic-child-b should carry a FLAGGED.md marker"
  echo "$children" | grep -qx "launch-epic-child-b" && \
    err "launch-epic-child-b should NOT be in launch-epic's current children: list" || \
    ok "launch-epic-child-b correctly absent from the current children: list"
fi

if (( fail == 0 )); then
  echo "OK: all fixtures validated"
fi
exit $fail
