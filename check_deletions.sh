#!/bin/bash

# Check for deletions in api-dump/Amplify.json between two branches
BASE_BRANCH=$1
HEAD_BRANCH=$2
FILE_PATH="api-dump/Amplify.json"

# Fetch the branches
git fetch origin $BASE_BRANCH
git fetch origin $HEAD_BRANCH

# Get the diff between the branches
diff=$(git diff origin/$BASE_BRANCH..origin/$HEAD_BRANCH -- $FILE_PATH)

# Check for deletions
if echo "$diff" | grep -q '^-'; then
    echo "Deletions detected in $FILE_PATH"
    exit 1
else
    echo "No deletions detected in $FILE_PATH"
fi
