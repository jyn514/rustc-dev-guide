#!/usr/bin/env bash

set -euo pipefail

: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY must be set}"
: "${GH_TOKEN:?GH_TOKEN must be set}"

issue_numbers=$(gh issue list \
  --repo "$GITHUB_REPOSITORY" \
  --state open \
  --label scheduled-linkcheck-failure \
  --limit 100 \
  --json number,title \
  --jq '.[] | select(.title == "[automation] Dead links found") | .number')

if [[ -z "$issue_numbers" ]]; then
  echo "No scheduled linkcheck failure issue is open."
  exit 0
fi

while read -r issue_number; do
  gh issue close "$issue_number" \
    --repo "$GITHUB_REPOSITORY" \
    --comment "The scheduled link check is succeeding again."
done <<< "$issue_numbers"
