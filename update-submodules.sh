#!/bin/bash
# update-submodules.sh
#
# Syncs Git submodules, configures them to track the branch defined in .gitmodules,
# and updates them by pulling the latest changes. If no branch is set, 'main' is used.

set -e

echo "📦 Syncing submodule configuration..."
git submodule sync

echo "🔄 Setting submodules to track their configured branches (defaulting to 'main')..."

git config -f .gitmodules --get-regexp 'submodule\..*\.path' | while read -r key path; do
  # Extract submodule name from key
  name=$(basename "$key" | cut -d'.' -f2)

  # Try to get branch from .gitmodules
  branch=$(git config -f .gitmodules --get "submodule.${name}.branch")

  # Fallback to 'main' if not set
  branch=${branch:-main}

  echo "→ Setting $path to track branch '$branch'"
  git submodule set-branch --branch "$branch" "$path"
done

echo "⬇️  Fetching and updating submodules..."
git submodule update --init --remote --recursive

echo "✅ Submodules updated."

