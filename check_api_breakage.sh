#!/bin/bash

# Script: check_api_breakage.sh

# Ensure the script is run from the root of the repository
if [ ! -d ".git" ]; then
  echo "This script must be run from the root of the repository."
  exit 1
fi

# Check if a base branch is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <base-branch>"
  exit 1
fi

BASE_BRANCH=$1

# Setup environment variables
OLD_API_DIR=$(mktemp -d)
NEW_API_DIR=$(mktemp -d)
REPORT_DIR=$(mktemp -d)
SDK_PATH=$(xcrun --show-sdk-path)

modules=$(swift package dump-package | jq -r '.products | map(select(.name == "Amplify" or .name == "CoreMLPredictionsPlugin")) | map(.name) | .[]')

# Ensure repository is up to date
git fetch origin

# Fetch and build the main branch
echo "Fetching API from base branch ($BASE_BRANCH)..."
git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH
swift build > /dev/null 2>&1 || { echo "Failed to build base branch ($BASE_BRANCH)"; exit 1; }
for module in $modules; do
    swift api-digester -sdk "$SDK_PATH" -dump-sdk -module "$module" -o "$OLD_API_DIR/${module}.json" -I .build/debug || { echo "Failed to dump SDK for base branch ($BASE_BRANCH)"; exit 1; }
done

# Fetch and build the current branch
echo "Fetching API from current branch..."
git checkout -
git pull origin "$(git rev-parse --abbrev-ref HEAD)"
swift build > /dev/null 2>&1 || { echo "Failed to build current branch"; exit 1; }
for module in $modules; do
    swift api-digester -sdk "$SDK_PATH" -dump-sdk -module "${module}" -o "$NEW_API_DIR/${module}.json" -I .build/debug || { echo "Failed to dump SDK for current branch"; exit 1; }
done

# Compare APIs for each module and capture the output
api_diff_output=""
for module in $modules; do
  swift api-digester -sdk "$SDK_PATH" -diagnose-sdk --input-paths "$OLD_API_DIR/${module}.json" --input-paths "$NEW_API_DIR/${module}.json" > "$REPORT_DIR/api-diff-report.txt" 2>&1
  module_diff_output=$(grep -v '^/\*' "$REPORT_DIR/api-diff-report.txt" | grep -v '^$' || true)
  if [ -n "$module_diff_output" ]; then
    api_diff_output="${api_diff_output}\n### Module: ${module}\n${module_diff_output}\n"
  fi
done

if [ -n "$api_diff_output" ];
  then
  echo "❌ Public API Breaking Change detected:"
  echo "$api_diff_output"
else
  echo "✅ No Public API Breaking Change detected"
fi
