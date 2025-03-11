#!/bin/bash

# 📌 Capturing the current branch
current_branch=$(git branch --show-current)

if [[ $current_branch != feature/* ]]; then
    echo "❌ Error: You must be on a 'feature/*' branch to run this script."
    exit 1
fi

# 📌 Check for pending changes (does not run if there are uncommitted files)
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: There are pending changes. Please commit or stash them before proceeding."
    exit 1
fi

# 🛠 User confirmation before proceeding
echo -n "🔔 Do you want to continue integrating the branch '$current_branch'? (y/N): "
read -r continue_integration
if [[ "$continue_integration" != "" && "$continue_integration" != "y" ]]; then
    echo "⚠️ Operation canceled by the user. Exiting..."
    exit 1
fi
echo ""

# 🛠 Extracting the feature branch name
current_branch=$(git branch --show-current)
feature_name=${current_branch#feature/}

# Switching to develop branch
echo "🔄 Switching to 'develop' branch..."
git switch develop
echo ""

# 🔄 Merging feature branch into develop
echo "🔄 Merging '$current_branch' into 'develop'..."
git merge "$current_branch" --no-ff -m "Merge '$current_branch' into develop"
echo ""

# 🚀 Push to develop branch
echo "🚀 Pushing to 'origin/develop'..."
git push origin develop
if [[ $? -ne 0 ]]; then
    echo "❌ Error pushing to 'origin/develop'."
    exit 1
fi
echo ""

# 🗑️ Deleting local and remote branches
echo "🗑️ Deleting local branch '$current_branch'..."
git branch -d "$current_branch"
echo ""

# 🗑️ Check if the remote branch exists before deleting it
if git ls-remote --exit-code --heads origin "$current_branch" &>/dev/null; then
    echo "🗑️ Deleting remote branch 'origin/$current_branch'..."
    git push origin --delete "$current_branch"
    echo "✅ Remote branch '$current_branch' deleted successfully!"
else
    echo "⚠️ Remote branch '$current_branch' does not exist. Skipping deletion."
fi
echo ""

echo "✅ Process completed successfully!"
