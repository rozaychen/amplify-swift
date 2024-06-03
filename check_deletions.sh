#!/bin/bash

# Check for deletions in api-dump/Amplify.json between two branches
BASE_BRANCH=$1
HEAD_BRANCH=$2
FILE_PATH="api-dump/Amplify.json"

# Fetch the branches
echo "Fetching branches..."
git fetch origin $BASE_BRANCH
git fetch origin $HEAD_BRANCH

# Get the diff between the branches
echo "Getting diff between $BASE_BRANCH and $HEAD_BRANCH for $FILE_PATH..."
diff=$(git diff origin/$BASE_BRANCH..origin/$HEAD_BRANCH -- $FILE_PATH)

# Print the diff for debugging
echo "Diff output:"
echo "$diff"

# Check for deletions
deletions=$(echo "$diff" | grep '^-' | grep -v '^---' | grep -v '^+++')
if [ -n "$deletions" ]; then
    echo "Deletions found:"
    echo "$deletions"
    exit 1
else
    echo "No deletions found."
    exit 0
fi

