#!/bin/bash
# Release Workflow for gaupefam R package
# Usage: ./scripts/release_workflow.sh
# 
# This script automates the release process:
# 1. Validates you're on main branch with no uncommitted changes
# 2. Prompts for new version number (semantic versioning: X.Y.Z)
# 3. Updates DESCRIPTION file and creates git tag
# 4. Pushes changes and triggers CI/CD for Docker builds
# 5. Bumps to next development version (X.Y.Z.9000)

set -e  # Exit on error

echo "======================================"
echo "  Gaupefam Release Workflow"
echo "======================================"
echo ""

# Check if on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "ERROR: You must be on the main branch to release."
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "ERROR: You have uncommitted changes."
    echo "Please commit or stash them before releasing."
    exit 1
fi

# Pull latest changes
echo "Pulling latest changes from origin/main..."
git pull origin main

# Get current version from DESCRIPTION
CURRENT_VERSION=$(grep "^Version:" DESCRIPTION | sed 's/Version: //')
echo ""
echo "Current version in DESCRIPTION: $CURRENT_VERSION"
echo ""

# Ask for new version
read -p "Enter new release version (e.g., 1.0.0): " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    echo "ERROR: Version cannot be empty."
    exit 1
fi

# Validate semantic versioning format
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Version must be in format X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

echo ""
echo "======================================"
echo "  Release Plan"
echo "======================================"
echo "Current version: $CURRENT_VERSION"
echo "New version:     $NEW_VERSION"
echo "Git tag:         v$NEW_VERSION"
echo ""

read -p "Continue with this release? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Release cancelled."
    exit 0
fi

echo ""
echo "Step 1: Updating DESCRIPTION version to $NEW_VERSION..."
sed -i "s/^Version: .*/Version: $NEW_VERSION/" DESCRIPTION
echo "DESCRIPTION updated"
echo ""

echo "Step 2: Committing version bump..."
git add DESCRIPTION
git commit -m "Bump version to $NEW_VERSION"
echo "Version committed"
echo ""

echo "Step 3: Creating git tag v$NEW_VERSION..."
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
echo "Tag created"
echo ""

echo "Step 4: Pushing to origin..."
git push origin main
git push origin "v$NEW_VERSION"
echo "Pushed to origin"
echo ""

# Calculate next dev version
IFS='.' read -r MAJOR MINOR PATCH <<< "$NEW_VERSION"
NEXT_MINOR=$((MINOR + 1))
NEXT_DEV_VERSION="$MAJOR.$NEXT_MINOR.0.9000"

echo "Step 5: Bumping to next development version..."
sed -i "s/^Version: .*/Version: $NEXT_DEV_VERSION/" DESCRIPTION
git add DESCRIPTION
git commit -m "Bump version to $NEXT_DEV_VERSION [skip ci]"
git push origin main
echo "Development version set to $NEXT_DEV_VERSION"
echo ""

echo "======================================"
echo "  Release Complete!"
echo "======================================"
echo ""
echo "Docker images will be built automatically and tagged as:"
echo "  - ghcr.io/miljodirektoratet/dp-gaupe-familiegrupper:$NEW_VERSION"
echo "  - ghcr.io/miljodirektoratet/dp-gaupe-familiegrupper:$MAJOR.$MINOR"
echo "  - ghcr.io/miljodirektoratet/dp-gaupe-familiegrupper:$MAJOR"
echo ""
echo "R package can be installed with:"
echo "  remotes::install_github(\"miljodirektoratet/dp-gaupe-familiegrupper@v$NEW_VERSION\")"
echo ""
echo "Check GitHub Actions: https://github.com/miljodirektoratet/dp-gaupe-familiegrupper/actions"
echo ""
