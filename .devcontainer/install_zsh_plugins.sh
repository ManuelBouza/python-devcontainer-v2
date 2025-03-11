#!/bin/bash

echo "📂 Defining the directory where plugins will be installed..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo ""

# Install zsh-autosuggestions if not already installed
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "🔧 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed."
fi

echo ""

# Install zsh-syntax-highlighting if not already installed
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "🔧 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting is already installed."
fi

echo ""

# Add plugins to ~/.zshrc if they are not already added
if ! grep -q "plugins=.*zsh-autosuggestions.*zsh-syntax-highlighting.*" ~/.zshrc; then
    echo "🔄 Updating ~/.zshrc to include plugins..."
    sed -i '/^plugins=/ s/)/ zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
else
    echo "✅ Plugins are already configured in ~/.zshrc."
fi

echo ""

# Apply changes
echo "🔄 Applying changes..."
echo "source $ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
echo "source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

echo ""

# Final message
echo "🎉 Installation complete! Restart your terminal to apply the changes."
echo ""
