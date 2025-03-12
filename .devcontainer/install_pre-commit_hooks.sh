#!/bin/bash

echo "🔧 Installing pre-commit hooks..."
pre-commit install --hook-type pre-commit --hook-type pre-push
echo ""

echo "⬆️ Updating pre-commit hooks..."
pre-commit autoupdate
echo ""

echo "✅ Running pre-commit on all files..."
SKIP=prevent-commit-to-main-develop pre-commit run --all-files --hook-stage pre-commit 
pre-commit run --all-files --hook-stage pre-push
echo ""

echo "🎉 Setup complete!"
echo ""
