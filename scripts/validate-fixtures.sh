#!/usr/bin/env bash
# Structural checks over tests/fixtures/*/docs/work/*/feature.md: kind/parent/
# children consistency, flow invariants (flow-dependent implement gate, atomic
# design+structure approval, flow log), plus the specific scenarios documented
# in tests/fixtures/README.md (targeted stale marking, child-folder creation
# and flagging, "not yet", resume from 05-plan.md). Exits non-zero on any
# failure.
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

# --- flow helpers ---------------------------------------------------------

# flow from feature.md; missing field or file = full.
flow_of() {
  local f="$1/feature.md" v=""
  [[ -f "$f" ]] && v="$(field "flow" "$(frontmatter "$f")")"
  echo "${v:-full}"
}

# status of an artifact, or "missing".
st() { [[ -f "$1" ]] && status_of "$1" || echo "missing"; }
approved_at_of() { field "approved_at" "$(frontmatter "$1")"; }

# First letter of the first non-empty line under "## Size verdict".
size_of() {
  awk '/^## Size verdict/{f=1; next} f && /^## /{exit} f && NF {print; exit}' "$1" \
    | sed 's/^[^A-Za-z]*//' | cut -c1
}

# Is grove-implement's flow-dependent gate open for this feature folder?
gate_open() {
  local d="$1" flow
  flow="$(flow_of "$d")"
  case "$flow" in
    full) [[ "$(st "$d/04-structure.md")" == "approved" ]] ;;
    standard) [[ "$(st "$d/03-design.md")" == "approved" && "$(st "$d/04-structure.md")" == "approved" ]] ;;
    small) [[ "$(st "$d/01-questions.md")" == "approved" && "$(size_of "$d/01-questions.md")" == "S" ]] ;;
    *) return 1 ;;
  esac
}

# Where grove-implement resumes: "<N> plan" (no section yet: plan just in
# time), "<N> resume" (partly ticked), "<N> drift-check" (written ahead,
# unstarted: legacy full plan), or "done".
next_slice() {
  local d="$1" plan="$1/05-plan.md" slices n sec
  if [[ -f "$d/04-structure.md" ]]; then
    slices="$(sed -n 's/^### Slice \([0-9]*\).*/\1/p' "$d/04-structure.md")"
  elif [[ -f "$plan" ]]; then
    slices="$(sed -n 's/^## Slice \([0-9]*\).*/\1/p' "$plan")"
  fi
  [[ -z "$slices" ]] && slices=1
  for n in $slices; do
    sec=""
    [[ -f "$plan" ]] && sec="$(awk -v n="$n" '$0 ~ "^## Slice "n"( |$)" {f=1; next} f && /^## /{exit} f' "$plan")"
    if [[ -z "$sec" ]]; then echo "$n plan"; return; fi
    if echo "$sec" | grep -q -- '- \[ \]'; then
      if echo "$sec" | grep -q -- '- \[x\]'; then echo "$n resume"; else echo "$n drift-check"; fi
      return
    fi
  done
  echo "done"
}

expect_eq() { # <label> <actual> <expected>
  [[ "$2" == "$3" ]] && ok "$1: $2" || err "$1: got '$2', expected '$3'"
}

# --- flow invariants over every fixture feature ----------------------------
for feature_dir in "$fixtures_dir"/*/docs/work/*/; do
  d="${feature_dir%/}"
  name="$(basename "$(dirname "$(dirname "$(dirname "$d")")")")/$(basename "$d")"
  fm_file="$d/feature.md"
  [[ -f "$fm_file" ]] || continue
  raw_flow="$(field "flow" "$(frontmatter "$fm_file")")"
  flow="$(flow_of "$d")"
  kind="$(field "kind" "$(frontmatter "$fm_file")")"

  case "$raw_flow" in
    ""|full|standard|small|auto) ;;
    *) err "$name: flow '$raw_flow' not in {full, standard, small, auto}" ;;
  esac
  [[ "$flow" == "auto" && "$kind" != "feature" ]] && err "$name: an auto flow must be kind feature, got '$kind'"
  if [[ "$flow" == "auto" ]]; then
    for af in 03-design.md 04-structure.md 05-plan.md 06-implementation.md; do
      [[ -f "$d/$af" ]] && err "$name: auto flow must not have $af"
    done
  fi
  [[ "$kind" == "epic" && "$flow" != "full" ]] && err "$name: an epic must be flow full, got '$flow'"
  if [[ -n "$raw_flow" ]] && ! grep -q '^## Flow log' "$fm_file"; then
    err "$name: flow is set but feature.md has no ## Flow log"
  fi
  if [[ "$flow" == "small" && ( -f "$d/03-design.md" || -f "$d/04-structure.md" ) ]]; then
    err "$name: small flow must not have 03-design.md / 04-structure.md"
  fi

  # Implementation may only have started with the flow's gate open (or forced).
  if [[ -f "$d/05-plan.md" || -f "$d/06-implementation.md" ]]; then
    forced="$(field "forced" "$(frontmatter "$d/05-plan.md" 2>/dev/null)")"
    if gate_open "$d" || [[ -n "$forced" && "$forced" != "[]" ]]; then
      ok "$name: implementation started with the $flow-flow gate open"
    else
      err "$name: implementation started but the $flow-flow gate is closed"
    fi
  fi

  # standard flow: design and structure are approved together, never design alone.
  if [[ "$flow" == "standard" ]]; then
    ds="$(st "$d/03-design.md")"; ss="$(st "$d/04-structure.md")"
    if [[ "$ss" == "approved" && "$ds" != "approved" ]]; then
      err "$name: structure approved without the design (standard flow)"
    fi
    if [[ "$ds" == "approved" && ( ! -f "$d/04-structure.md" || -z "$(approved_at_of "$d/04-structure.md")" ) ]]; then
      err "$name: design approved alone (standard flow approves design+structure atomically)"
    fi
  fi
done

# --- flows: one feature per flow, plus legacy and gate-closed cases --------
fl="$fixtures_dir/flows/docs/work"
if [[ -d "$fl" ]]; then
  # Flow resolution (missing flow = full).
  expect_eq "legacy-feature flow (no flow field)" "$(flow_of "$fl/2026-09-20-legacy-feature")" "full"

  # Flow-dependent gates: open cases.
  for s in 2026-10-01-full-feature 2026-10-01-standard-feature 2026-10-01-small-feature 2026-09-20-legacy-feature; do
    gate_open "$fl/$s" && ok "$s: implement gate open ($(flow_of "$fl/$s"))" \
      || err "$s: implement gate should be open ($(flow_of "$fl/$s"))"
  done
  # ...and closed cases.
  for s in 2026-10-02-not-yet 2026-10-03-small-size-m 2026-10-03-full-structure-draft; do
    gate_open "$fl/$s" && err "$s: implement gate should be closed ($(flow_of "$fl/$s"))" \
      || ok "$s: implement gate closed ($(flow_of "$fl/$s"))"
  done
  # standard flow does not need questions/research approved (soft gates).
  expect_eq "standard-feature 01-questions.md (left draft at start)" "$(st "$fl/2026-10-01-standard-feature/01-questions.md")" "draft"

  # Atomic combined approval: both approved, same day, one unit.
  sf="$fl/2026-10-01-standard-feature"
  expect_eq "standard-feature design+structure approved_at match" \
    "$(approved_at_of "$sf/03-design.md")" "$(approved_at_of "$sf/04-structure.md")"
  # full flow: separate approvals.
  ff="$fl/2026-10-01-full-feature"
  [[ "$(approved_at_of "$ff/03-design.md")" != "$(approved_at_of "$ff/04-structure.md")" ]] \
    && ok "full-feature: design and structure approved separately" \
    || err "full-feature: design and structure should carry separate approvals"

  # "not yet" leaves both draft with no approved_at.
  ny="$fl/2026-10-02-not-yet"
  for f in 03-design.md 04-structure.md; do
    expect_eq "not-yet $f status" "$(st "$ny/$f")" "draft"
    expect_eq "not-yet $f approved_at" "$(approved_at_of "$ny/$f")" ""
  done

  # Resume from 05-plan.md.
  expect_eq "standard-feature resumes at" "$(next_slice "$sf")" "1 plan"
  expect_eq "full-feature resumes at" "$(next_slice "$ff")" "2 resume"
  expect_eq "legacy-feature resumes at" "$(next_slice "$fl/2026-09-20-legacy-feature")" "2 drift-check"
  expect_eq "small-feature resumes at" "$(next_slice "$fl/2026-10-01-small-feature")" "done"
  # Just-in-time: full-feature has no section for slice 3 yet.
  grep -q '^## Slice 3' "$ff/05-plan.md" \
    && err "full-feature: slice 3 should not be planned ahead" \
    || ok "full-feature: slice 3 not planned ahead (just in time)"
fi

# --- auto flow: plan content gates -----------------------------------------

# Print one line per failed plan content gate for an auto feature folder
# (see shared/approve.md, plan unit). Limits mirror grove.config.json
# (maxOneWayDecisions 8, maxSlices 8), hardcoded here.
plan_gate_failures() {
  local d="$1" max_dec=8 max_sl=8 f key req v1 v2 plan="$1/03-plan.md" based
  for f in 01-outcome.md 02-research.md 03-plan.md; do
    if [[ ! -f "$d/$f" ]]; then echo "$f: missing"; continue; fi
    req="feature phase status version created updated approved_at based_on forced"
    [[ "$f" == "02-research.md" ]] && req="$req repo_heads"
    for key in $req; do
      frontmatter "$d/$f" | grep -q "^$key:" || echo "$f: frontmatter key '$key' missing"
    done
    if [[ -n "$(awk '/^## Open questions/{f=1; next} f && /^## /{exit} f && NF' "$d/$f")" ]]; then
      echo "$f: non-empty Open questions"
    fi
    if grep -Eq 'TODO|TBD' "$d/$f"; then echo "$f: contains TODO/TBD"; fi
  done
  [[ -f "$d/01-outcome.md" && -f "$plan" ]] || return 0
  for key in "## Summary" "## What the human sees and does" "## Non-goals" "## How I'll know it works"; do
    grep -qF "$key" "$d/01-outcome.md" || echo "01-outcome.md: missing section '$key'"
  done
  awk -v maxd="$max_dec" -v maxs="$max_sl" '
    function flush_dec() {
      if (!indec) return
      if (opts < 2) print "03-plan.md: " dname " has fewer than 2 options"
      if (!pick) print "03-plan.md: " dname " has no Pick"
      if (dis && hp == "") print "03-plan.md: " dname " has Agents disagree but no Human pick"
      if (dis && hp != "" && pick && hp != pk) print "03-plan.md: " dname " Pick differs from Human pick"
      indec = 0
    }
    function flush_sl() {
      if (!insl) return
      if (!ver) print "03-plan.md: " sname " has no Verification"
      if (sname ~ /Slice 1\./ && !thin) print "03-plan.md: slice 1 has no Thin end-to-end line"
      insl = 0
    }
    /^### D[0-9]+\./ { flush_dec(); flush_sl(); indec=1; ndec++; dname=$2; opts=0; pick=0; dis=0; hp=""; pk=""; next }
    /^### Slice [0-9]+\./ { flush_dec(); flush_sl(); insl=1; nsl++; sname="Slice " $3; ver=0; thin=0; next }
    /^## / { flush_dec(); flush_sl() }
    indec && /^- / { opts++ }
    indec && /^\*\*Pick:\*\*/ { pick=1; pk=$0; sub(/^\*\*Pick:\*\* */, "", pk) }
    indec && /^\*\*Agents disagree:\*\*/ { dis=1 }
    indec && /^\*\*Human pick:\*\*/ { hp=$0; sub(/^\*\*Human pick:\*\* */, "", hp) }
    insl && /^\*\*Verification\./ { ver=1 }
    insl && /^\*\*Thin end-to-end:\*\*/ { thin=1 }
    END {
      flush_dec(); flush_sl()
      if (ndec > maxd) print "03-plan.md: " ndec " decisions exceeds " maxd
      if (nsl > maxs) print "03-plan.md: " nsl " slices exceeds " maxs
      if (nsl < 1) print "03-plan.md: no slices"
    }
  ' "$plan"
  v1="$(field "version" "$(frontmatter "$d/01-outcome.md")")"
  v2="$(field "version" "$(frontmatter "$d/02-research.md")")"
  based="$(list_field "based_on" "$plan")"
  echo "$based" | grep -qx "01-outcome.md@$v1" || echo "03-plan.md: based_on lacks 01-outcome.md@$v1"
  echo "$based" | grep -qx "02-research.md@$v2" || echo "03-plan.md: based_on lacks 02-research.md@$v2"
}

# Print one line per failed run content gate for an auto feature folder
# (see shared/approve.md, run unit). The Plan commit sha comparison needs git
# and is not checkable in a fixture.
run_gate_failures() {
  local d="$1" run="$1/04-run.md" plan="$1/03-plan.md" key n sec pv based
  if [[ ! -f "$run" ]]; then echo "04-run.md: missing"; return 0; fi
  for key in feature phase status version created updated approved_at based_on forced; do
    frontmatter "$run" | grep -q "^$key:" || echo "04-run.md: frontmatter key '$key' missing"
  done
  if [[ -n "$(awk '/^## Open questions/{f=1; next} f && /^## /{exit} f && NF' "$run")" ]]; then
    echo "04-run.md: non-empty Open questions"
  fi
  if grep -Eq 'TODO|TBD' "$run"; then echo "04-run.md: contains TODO/TBD"; fi
  if [[ -f "$plan" ]]; then
    for n in $(sed -n 's/^### Slice \([0-9][0-9]*\)\..*/\1/p' "$plan"); do
      sec="$(awk -v n="$n" '$0 ~ "^## Slice "n"( |$)" {f=1; next} f && /^## /{exit} f' "$run")"
      if [[ -z "$sec" ]]; then echo "04-run.md: no '## Slice $n' section"; continue; fi
      echo "$sec" | grep -q '^Status: done *$' || echo "04-run.md: Slice $n is not Status: done"
      echo "$sec" | grep -Eq '^Commit: *[^ ]' || echo "04-run.md: Slice $n has no Commit line"
    done
    pv="$(field "version" "$(frontmatter "$plan")")"
    based="$(list_field "based_on" "$run")"
    echo "$based" | grep -qx "03-plan.md@$pv" || echo "04-run.md: based_on lacks 03-plan.md@$pv"
  fi
  # Any slice not done (including slices not in the plan) fails.
  if grep -E '^Status: ' "$run" | grep -qvE '^Status: done *$'; then
    echo "04-run.md: a slice is halted or in progress"
  fi
  grep -q '^## Final summary' "$run" || echo "04-run.md: no Final summary"
  grep -q '^### PR description' "$run" || echo "04-run.md: no PR description"
}

af="$fixtures_dir/flows/docs/work/2026-10-04-auto-feature"
if [[ -d "$af" ]]; then
  expect_eq "auto-feature flow" "$(flow_of "$af")" "auto"
  out="$(plan_gate_failures "$af")"
  [[ -z "$out" ]] && ok "auto-feature passes the plan content gates" \
    || err "auto-feature fails plan gates: $out"
  for f in 01-outcome.md 02-research.md 03-plan.md; do
    expect_eq "auto-feature $f status" "$(st "$af/$f")" "approved"
  done
  expect_eq "auto-feature approved_at (research = outcome)" "$(approved_at_of "$af/02-research.md")" "$(approved_at_of "$af/01-outcome.md")"
  expect_eq "auto-feature approved_at (plan = outcome)" "$(approved_at_of "$af/03-plan.md")" "$(approved_at_of "$af/01-outcome.md")"

  tmp="$(mktemp -d "${TMPDIR:-/tmp}/grove-fixtures.XXXXXX")" || { err "mktemp failed; cannot run plan-gate mutation tests"; tmp=""; }
  [[ -n "$tmp" ]] && trap 'rm -rf "$tmp"' EXIT
  mutate_check() { # <label> <sed-or-shell mutation as function name>
    [[ -n "$tmp" ]] || return 0
    rm -rf "$tmp/m"; cp -R "$af" "$tmp/m"
    "$2" "$tmp/m/03-plan.md"
    if [[ -n "$(plan_gate_failures "$tmp/m")" ]]; then ok "plan gates refuse: $1"
    else err "plan gates did not refuse: $1"; fi
  }
  mut_pick() { # drop D1's Pick (first Pick line)
    awk '!d && /^\*\*Pick:\*\*/ {d=1; next} {print}' "$1" > "$1.new" && mv "$1.new" "$1"; }
  mut_thin() { grep -v '^\*\*Thin end-to-end:\*\*' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_oq() { printf '\nWhich theme is the default?\n' >> "$1"; }
  mut_hp() { grep -v '^\*\*Human pick:\*\*' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_based() { sed 's/01-outcome.md@1/01-outcome.md@0/' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mutate_check "D1 without Pick" mut_pick
  mutate_check "slice 1 without Thin end-to-end" mut_thin
  mutate_check "text under Open questions" mut_oq
  mutate_check "agents-disagree decision without Human pick" mut_hp
  mutate_check "stale based_on" mut_based

  # run unit: 04-run.md content gates (on a copy, mutating 04-run.md).
  out="$(run_gate_failures "$af")"
  [[ -z "$out" ]] && ok "auto-feature passes the run content gates" \
    || err "auto-feature fails run gates: $out"
  expect_eq "auto-feature 04-run.md status (finished run, not yet approved)" "$(st "$af/04-run.md")" "draft"
  run_mutate_check() { # <label> <mutation function>
    [[ -n "$tmp" ]] || return 0
    rm -rf "$tmp/m"; cp -R "$af" "$tmp/m"
    "$2" "$tmp/m/04-run.md"
    if [[ -n "$(run_gate_failures "$tmp/m")" ]]; then ok "run gates refuse: $1"
    else err "run gates did not refuse: $1"; fi
  }
  mut_halted() { awk '!d && /^Status: done/{print "Status: halted"; d=1; next} {print}' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_noslice() { awk '/^## Slice 2/{skip=1; next} skip && /^## /{skip=0} !skip' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_nosummary() { awk '/^## Final summary/{skip=1; next} skip && /^## /{skip=0} !skip' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_run_oq() { printf '\nShould this ship behind a flag?\n' >> "$1"; }
  mut_run_based() { sed 's/03-plan.md@1/03-plan.md@0/' "$1" > "$1.new"; mv "$1.new" "$1"; }
  run_mutate_check "a slice Status: halted" mut_halted
  run_mutate_check "missing ## Slice N section" mut_noslice
  run_mutate_check "no ## Final summary" mut_nosummary
  mut_nopr() { grep -v '^### PR description' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_nocommit() { awk '!d && /^Commit:/{d=1; next} {print}' "$1" > "$1.new"; mv "$1.new" "$1"; }
  mut_marker() { printf '\nTO""DO later\n' | sed 's/""//' >> "$1"; }
  run_mutate_check "no ### PR description" mut_nopr
  run_mutate_check "a slice without a Commit line" mut_nocommit
  run_mutate_check "a placeholder marker" mut_marker
  run_mutate_check "text under Open questions" mut_run_oq
  run_mutate_check "stale based_on" mut_run_based
fi

if (( fail == 0 )); then
  echo "OK: all fixtures validated"
fi
exit $fail
