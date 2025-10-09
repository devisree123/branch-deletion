#!/bin/bash

CSV_FILE="branches.csv"

# Loop through each branch in the CSV (skip header)
tail -n +2 "$CSV_FILE" | while IFS=, read -r branch; do
    branch=$(echo "$branch" | tr -d '\r' | xargs)  # Trim whitespace and carriage returns
    if [ -z "$branch" ]; then
        echo "Skipping empty line"
        continue
    fi

    echo "Processing branch: $branch"

    # Try to checkout local or remote branch
    git checkout "$branch" 2>/dev/null || git checkout -b "$branch" "origin/$branch" 2>/dev/null || {
        echo "Branch $branch not found locally or remotely"
        continue
    }

    # Create a tag before deletion
    tag_name="backup-${branch//\//-}-$(date +%Y%m%d)"
    git tag "$tag_name"
    git push origin "$tag_name"
    echo "Tag $tag_name created and pushed."

    # Delete branch locally
    git branch -D "$branch"
    echo "Deleted local branch: $branch"

    # Delete branch remotely
    git push origin --delete "$branch"
    echo "Deleted remote branch: $branch"
done

# Checkout back to main
git checkout main
