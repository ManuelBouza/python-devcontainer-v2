#!/bin/bash

# 📌 Capturando la rama actual
current_branch=$(git branch --show-current)

if [[ $current_branch != feature/* ]]; then
    echo "❌ Error: Debes estar en una rama 'feature/*' para ejecutar este script."
    exit 1
fi

# 📌 Comprobar si hay cambios pendientes (no ejecuta si hay archivos sin commit)
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: Hay cambios pendientes. Por favor, haz commit o stash antes de continuar."
    exit 1
fi

# 🛠 Confirmación del usuario antes de continuar
echo -n "🔔 ¿Deseas continuar con la integración de la rama '$current_branch'? (S/n): "
read -r continue_integration
if [[ "$continue_integration" != "" && "$continue_integration" != "s" ]]; then
    echo "⚠️ Operación cancelada por el usuario. Haciendo salida..."
    exit 1
fi
echo ""

# 🛠 Extrayendo el nombre de la rama actual
current_branch=$(git branch --show-current)
feature_name=${current_branch#feature/}

# Cambiando a rama develop
echo "🔄 Cambiando a rama 'develop'..."
git switch develop
echo ""

# 🔄 Haciendo merge de rama feature en develop
echo "🔄 Haciendo merge de '$current_branch' en 'develop'..."
git merge "$current_branch" --no-ff -m "Merge '$current_branch' into develop"
echo ""

# 🚀 Push a la rama develop
echo "🚀 Haciendo push a 'origin/develop'..."
git push origin develop
if [[ $? -ne 0 ]]; then
    echo "❌ Error al hacer push a 'origin/develop'."
    exit 1
fi
echo ""

# 🗑️ Eliminando rama local y remota
echo "🗑️ Eliminando rama local '$current_branch'..."
git branch -d "$current_branch"
echo ""

# 🗑️ Eliminar la rama remota
echo "🗑️ Eliminando rama remota 'origin/$current_branch'..."
git push origin --delete "$current_branch"
echo ""

echo "✅ ¡Proceso completado exitosamente!"
