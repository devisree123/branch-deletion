#!/bin/bash

# Path to your CSV file
CSV_FILE="branches.csv"

# Loop through each branch in the CSV (skip header)
tail -n +2 "$CSV_FILE" | while IFS=, read -r branch; do
    echo "Processing branch: $branch"

    # Checkout the branch
    git checkout "$branch" || { echo "Branch $branch not found"; continue; }

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

# Checkout back to main or default branch
git checkout main
