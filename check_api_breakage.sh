#!/bin/bash

# Script: check_api_breakage.sh

# Ensure the script is run from the root of the repository
if [ ! -d ".git" ]; then
  echo "This script must be run from the root of the repository."
  exit 1
fi

# Setup environment variables
OLD_API_DIR=$(mktemp -d)
NEW_API_DIR=$(mktemp -d)
REPORT_DIR=$(mktemp -d)
SDK_PATH=$(xcrun --show-sdk-path)

# Ensure repository is up to date
git fetch origin

# Fetch and build the main branch
echo "Fetching API from main branch..."
git checkout main
git pull origin main
swift build > /dev/null 2>&1 || { echo "Failed to build main branch"; exit 1; }
swift api-digester -sdk "$SDK_PATH" -dump-sdk -module "Amplify" -o "$OLD_API_DIR/old.json" -I .build/debug || { echo "Failed to dump SDK for main branch"; exit 1; }

# Fetch and build the current branch
echo "Fetching API from current branch..."
git checkout -
git pull origin "$(git rev-parse --abbrev-ref HEAD)"
swift build > /dev/null 2>&1 || { echo "Failed to build current branch"; exit 1; }
swift api-digester -sdk "$SDK_PATH" -dump-sdk -module "Amplify" -o "$NEW_API_DIR/new.json" -I .build/debug || { echo "Failed to dump SDK for current branch"; exit 1; }

# Compare the APIs
echo "Comparing APIs..."
swift api-digester -sdk "$SDK_PATH" -diagnose-sdk --input-paths "$OLD_API_DIR/old.json" --input-paths "$NEW_API_DIR/new.json" > api-diff-report.txt 2>&1

# Capture the output for commenting
api_diff_output=$(cat api-diff-report.txt)

# Capture the SHA-1 checksum of the file
checksum=$(shasum api-diff-report.txt | awk '{ print $1 }')
if ! echo "$checksum" | grep -q afd2a1b542b33273920d65821deddc653063c700
  then
  echo "❌ Public API Breaking Change detected:"
  echo "$api_diff_output"
else
  echo "✅ No Public API Breaking Change detected"
fi
