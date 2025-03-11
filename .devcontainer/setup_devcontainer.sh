#!/bin/bash

echo ""
echo "📜 Adjusting permissions for command history..."
sudo chown -R $(whoami): /commandhistory
echo "✔️ Successfully adjusted permissions for /commandhistory."
echo ""

echo "🚀 Running Zsh plugin installation script..."
chmod +x .devcontainer/install_zsh_plugins.sh
echo "✔️ Granting execute permission to install_zsh_plugins.sh..."
.devcontainer/install_zsh_plugins.sh
echo ""

echo "📌 Granting execute permission to github scripts"
chmod +x github_utility/git-feature-to-develop.sh
chmod +x github_utility/git-develop-to-main.sh
echo "✔️ Granting execute permission to git-feature-to-develop.sh"
echo ""

echo "🎉 DevContainer setup complete!"
echo ""
