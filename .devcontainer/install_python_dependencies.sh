#!/bin/bash

echo "⬆️ Updating pip to the latest version..."
pip3 install --user --upgrade pip
echo ""

echo "📦 Installing Python dependencies..."
pip3 install --user -r requirements-dev.txt
echo ""

echo "🎉 Python dependencies setup complete!"
