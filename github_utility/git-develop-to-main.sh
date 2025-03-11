#!/bin/bash

# 📌 Capturing the current branch
current_branch=$(git branch --show-current)

if [[ $current_branch != "develop" ]]; then
    echo "❌ Error: You must be on the 'develop' branch to run this script."
    exit 1
fi

# 📌 Check for pending changes (does not run if there are uncommitted files)
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: There are pending changes. Please commit or stash them before proceeding."
    exit 1
fi

# 🛠 User confirmation before proceeding
echo -n "🔔 Do you want to continue integrating 'develop' into 'main'? (y/N): "
read -r continue_integration
if [[ "$continue_integration" != "" && "$continue_integration" != "y" ]]; then
    echo "⚠️ Operation canceled by the user. Exiting..."
    exit 1
fi

echo "🔄 Switching to 'main' branch..."
git switch main
echo ""

# 🔄 Merging develop into main
echo "🔄 Merging 'develop' into 'main'..."
git merge develop --no-ff -m "Merge 'develop' into main"
echo ""

# 🚀 Push to main branch
echo "🚀 Pushing to 'origin/main'..."
git push origin main
if [[ $? -ne 0 ]]; then
    echo "❌ Error pushing to 'origin/main'."
    exit 1
fi
echo ""

# Get the current version from pyproject.toml
current_version=$(grep -oP '(?<=version = ")([0-9]+)\.([0-9]+)\.([0-9]+)' pyproject.toml)

echo ""
echo -n "🔔 The current version is '$current_version'. Do you want to increment it and create a new tag? (y/N): "
read -r increase_version

if [[ "$increase_version" == "y" ]]; then
    IFS='.' read -r major minor patch <<<"$current_version"

    while true; do
        # Ask which type of version increment is desired
        echo ""
        echo "📌 Select the type of increment:"
        echo "1) Major ($((major + 1)).0.0)"
        echo "2) Minor ($major.$((minor + 1)).0)"
        echo "3) Patch ($major.$minor.$((patch + 1)))"
        echo "4) ❌ Cancel"
        echo ""
        echo -n "🔢 Option (1/2/3/4): "
        read -r option

        case $option in
            1)
                ((major++))
                minor=0
                patch=0
                break
                ;;
            2)
                ((minor++))
                patch=0
                break
                ;;
            3)
                ((patch++))
                break
                ;;
            4)
                echo "❌ Operation canceled."
                exit 0
                ;;
            *)
                echo "⚠️ Invalid option. Please try again."
                ;;
        esac
    done

    new_version="$major.$minor.$patch"

    echo ""
    echo "🔼 Updating version: $current_version ➡️ $new_version"
    sed -i "s/version = \"$current_version\"/version = \"$new_version\"/" pyproject.toml

    git add pyproject.toml
    git commit -m "Increment version to $new_version"

    new_tag="v$new_version"
    git tag "$new_tag"

    git push origin main
    git push origin "$new_tag"

    echo "✅ New version created and published: $new_tag!"
else
    echo "⚠️ Version was not incremented."
    
    # Get the current (latest) tag
    current_tag=$(git describe --tags --abbrev=0 2>/dev/null)
    
    if [[ -n "$current_tag" ]]; then
        # Ask if the current tag should be moved to the latest commit
        echo ""
        echo -n "🔄 The current tag is '$current_tag'. Do you want to move it to the latest commit? (y/N): "
        read -r move_tag
        if [[ "$move_tag" == "y" ]]; then
            echo "🔄 Moving tag $current_tag to the latest commit..."
            git tag -d "$current_tag" # Delete local tag
            git push origin --delete "$current_tag" # Delete remote tag
            git tag "$current_tag" # Create the tag on the new commit
            git push origin "$current_tag" # Push the updated tag

            echo "✅ The tag $current_tag has been moved to the latest commit!"
        else
            echo "🚀 No changes in version or tags."
        fi
    else
        echo "⚠️ No tag found to move."
    fi
fi
echo ""

echo "🔄 Switching back to 'develop' branch..."
git switch develop
echo ""

echo "✅ Process completed successfully!"
