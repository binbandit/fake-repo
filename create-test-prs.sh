#!/bin/bash

# Script to create random test pull requests using GitHub CLI
# Creates a random subset of PRs from unmerged branches

echo "Creating random test pull requests for git wrapper testing..."
echo "=============================================="

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if we're authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI"
    echo "Please run: gh auth login"
    exit 1
fi

# Function to ensure a label exists
ensure_label_exists() {
    local label_name=$1
    local label_color=${2:-"0366d6"}  # Default to GitHub blue
    local label_description=${3:-""}
    
    # Check if label exists
    if ! gh label list --json name | jq -r '.[].name' | grep -q "^${label_name}$"; then
        echo "Creating label '$label_name'..."
        gh label create "$label_name" --color "$label_color" --description "$label_description" || echo "  Label may already exist"
    fi
}

# Function to create a PR with error handling
create_pr() {
    local source_branch=$1
    local target_branch=$2
    local title=$3
    local body=$4
    local labels=$5  # Optional comma-separated labels

    echo "Creating PR: $source_branch → $target_branch"

    # Check if branches exist locally
    if ! git show-ref --verify --quiet "refs/heads/$source_branch"; then
        echo "  ⚠️  Warning: Source branch '$source_branch' not found locally"
        return 1
    fi

    # Push the source branch to ensure it's on remote
    echo "  Pushing $source_branch to remote..."
    git push -u origin "$source_branch" 2>/dev/null || echo "  Branch may already exist on remote"

    # Create the PR
    if [ -n "$labels" ]; then
        gh pr create \
            --head "$source_branch" \
            --base "$target_branch" \
            --title "$title" \
            --body "$body" \
            --label "$labels" 2>/dev/null || echo "  ⚠️  PR may already exist or failed to create"
    else
        gh pr create \
            --head "$source_branch" \
            --base "$target_branch" \
            --title "$title" \
            --body "$body" 2>/dev/null || echo "  ⚠️  PR may already exist or failed to create"
    fi

    echo "  ✓ Done"
    echo ""
}

# Ensure the stacked label exists
ensure_label_exists "stacked" "6f42c1" "Pull request that is stacked on another feature branch"

# Ask user about stacked PRs
echo -n "Do you want to include stacked PRs (feature branches targeting other feature branches)? [y/N]: "
read -r include_stacked
echo ""

# Define all possible PRs as arrays
# Format: source_branch|target_branch|title|body|labels
declare -a POSSIBLE_PRS=()

# Add stacked PRs if user wants them
if [[ "$include_stacked" =~ ^[Yy]$ ]]; then
    POSSIBLE_PRS+=(
        "feature/user-auth-api|feature/user-auth|feat: Add API endpoints for user authentication|This PR adds REST API endpoints for the user authentication feature.

## Changes
- Added login endpoint
- Added logout endpoint
- Added token validation

**Stacked on:** feature/user-auth|stacked"

    "feature/database-models|feature/database|feat: Add database models for MongoDB|This PR adds Mongoose models for our MongoDB database.

## Changes
- User model
- Session model
- Product model

**Stacked on:** feature/database|stacked"

    "feature/api-v2-routes|feature/api-v2|feat: Implement v2 API routes|This PR implements the new routes for API v2.

## Changes
- Updated route structure
- Added versioning middleware
- New response format

**Stacked on:** feature/api-v2|stacked"
    )
fi

# Add PRs targeting main branch (always included)
POSSIBLE_PRS+=(
    "feature/user-auth|main|feat: Implement user authentication system|This PR implements a complete user authentication system.

## Features
- User registration
- User login/logout
- Session management
- Password hashing

## Related PRs
- feature/user-auth-api (stacked on this branch)"

    "feature/refactor-old|main|refactor: Clean up legacy code|This PR refactors old code for better maintainability.

## Changes
- Removed deprecated functions
- Updated coding style
- Improved error handling"

    "bugfix/memory-leak|main|fix: Resolve memory leak in database connections|This PR fixes a critical memory leak in the database connection pool.

## Problem
- Connections were not being properly released
- Memory usage grew over time

## Solution
- Added proper connection cleanup
- Implemented connection timeout"

    "feature/experimental|main|feat: Experimental WebSocket support|This PR adds experimental WebSocket support for real-time features.

## ⚠️ Experimental
This is still in development and not ready for production.

## Features
- WebSocket server setup
- Client connection handling
- Basic message broadcasting"

    "feature/api-v2|main|feat: API Version 2.0|Major update to our API with breaking changes.

## Breaking Changes
- New response format
- Updated authentication flow
- Deprecated v1 endpoints

## Includes
- Merge from release/v2.0
- feature/api-v2-routes (stacked PR pending)"

    "feature/long-running|main|feat: Long-running background jobs|This PR implements support for long-running background jobs.

## Features
- Job queue implementation
- Worker processes
- Job status tracking
- Retry mechanism"

    "release/v2.0|main|chore: Release v2.0|Release version 2.0 with API improvements and bug fixes.

## Changelog
### Added
- New API v2 endpoints
- WebSocket support (experimental)
- Background job processing

### Fixed
- Memory leak in database connections
- Authentication edge cases

### Changed
- Updated API response format
- Improved error messages"

    "feature/database|main|feat: Complete database integration|This PR completes the database integration that was partially merged.

## Additional Changes Since Partial Merge
- Added migration scripts
- Implemented connection pooling
- Added database models (via feature/database-models)
- Performance optimizations

## Note
This branch was partially merged earlier but continued development."
)

# Ask if user wants to create all PRs
echo -n "Do you want to create ALL possible pull requests? [y/N]: "
read -r create_all
echo ""

# Shuffle the array to randomize order
shuffled=()
indices=( $(shuf -i 0-$((${#POSSIBLE_PRS[@]} - 1))) )

for i in "${indices[@]}"; do
    shuffled+=("${POSSIBLE_PRS[$i]}")
done

# Determine how many PRs to create
total_prs=${#shuffled[@]}
if [[ "$create_all" =~ ^[Yy]$ ]]; then
    num_to_create=$total_prs
    echo "Creating ALL $total_prs possible PRs..."
else
    num_to_create=$((RANDOM % total_prs + 1))
    echo "Randomly selecting $num_to_create out of $total_prs possible PRs..."
fi
echo ""

# Create the PRs
created_count=0
for ((i=0; i<num_to_create; i++)); do
    IFS='|' read -r source_branch target_branch title body labels <<< "${shuffled[$i]}"

    # Skip if the branch doesn't exist or is already merged
    if ! git show-ref --verify --quiet "refs/heads/$source_branch"; then
        echo "Skipping $source_branch (doesn't exist locally)"
        continue
    fi

    # Check if branch is already merged into its target
    if git merge-base --is-ancestor "$source_branch" "$target_branch" 2>/dev/null; then
        echo "Skipping $source_branch (already merged into $target_branch)"
        continue
    fi

    create_pr "$source_branch" "$target_branch" "$title" "$body" "$labels"
    ((created_count++))
done

echo "=============================================="
echo "Created $created_count pull requests!"
echo ""
echo "View all PRs with: gh pr list"
echo "View PR details with: gh pr view <number>"