#!/bin/bash

# 📌 Capturando la rama actual
current_branch=$(git branch --show-current)

if [[ $current_branch != "develop" ]]; then
    echo "❌ Error: Debes estar en la rama 'develop' para ejecutar este script."
    exit 1
fi

# 📌 Comprobar si hay cambios pendientes (no ejecuta si hay archivos sin commit)
if [[ -n $(git status --porcelain) ]]; then
    echo "❌ Error: Hay cambios pendientes. Por favor, haz commit o stash antes de continuar."
    exit 1
fi

# 🛠 Confirmación del usuario antes de continuar
echo -n "🔔 ¿Deseas continuar con la integración de 'develop' en 'main'? (S/n): "
read -r continue_integration
if [[ "$continue_integration" != "" && "$continue_integration" != "s" ]]; then
    echo "⚠️ Operación cancelada por el usuario. Saliendo..."
    exit 1
fi

echo "🔄 Cambiando a la rama 'main'..."
git switch main
echo ""

# 🔄 Haciendo merge de develop en main
echo "🔄 Haciendo merge de 'develop' en 'main'..."
git merge develop --no-ff -m "Merge 'develop' into main"
echo ""

# 🚀 Push a la rama main
echo "🚀 Haciendo push a 'origin/main'..."
git push origin main
if [[ $? -ne 0 ]]; then
    echo "❌ Error al hacer push a 'origin/main'."
    exit 1
fi
echo ""

# 📌 Incrementar la versión y crear tag (opcional)
echo ""
echo -n "🔔 ¿Deseas incrementar la versión y crear un nuevo tag? (s/N): "
read -r increase_version
if [[ "$increase_version" == "s" ]]; then
    # Obtener la versión actual del archivo pyproject.toml
    current_version=$(grep -oP '(?<=version = \")([0-9]+)\.([0-9]+)\.([0-9]+)' pyproject.toml)

    IFS='.' read -r major minor patch <<<"$current_version"

    # Preguntar qué tipo de incremento se desea
    echo ""
    echo "📌 Selecciona el tipo de incremento:"
    echo "1) Major (X.0.0)"
    echo "2) Minor ($major.X.0)"
    echo "3) Patch ($major.$minor.X)"
    echo -n "🔢 Opción (1/2/3): "
    read -r option

    case $option in
        1)
            ((major++))
            minor=0
            patch=0
            ;;
        2)
            ((minor++))
            patch=0
            ;;
        3)
            ((patch++))
            ;;
        *)
            echo "⚠️ Opción no válida. No se actualizará la versión."
            exit 1
            ;;
    esac

    new_version="$major.$minor.$patch"

    echo "🔼 Actualizando versión: $current_version ➡️ $new_version"
    sed -i "s/version = \"$current_version\"/version = \"$new_version\"/" pyproject.toml

    git add pyproject.toml
    git commit -m "Incrementar versión a $new_version"

    new_tag="v$new_version"
    git tag "$new_tag"

    git push origin main
    git push origin "$new_tag"

    echo "✅ ¡Nueva versión creada y publicada: $new_tag!"
else
    echo "⚠️ La versión no fue incrementada."
    
    # Obtener el tag actual (último creado)
    current_tag=$(git describe --tags --abbrev=0 2>/dev/null)
    
    if [[ -n "$current_tag" ]]; then
        # Preguntar si se desea mover el tag actual al nuevo commit
        echo ""
        echo -n "🔄 El tag actual es '$current_tag'. ¿Deseas moverlo al último commit? (s/N): "
        read -r move_tag
        if [[ "$move_tag" == "s" ]]; then
            echo "🔄 Moviendo el tag $current_tag al último commit..."
            git tag -d "$current_tag" # Eliminar el tag localmente
            git push origin --delete "$current_tag" # Eliminar el tag en remoto
            git tag "$current_tag" # Crear el tag en el nuevo commit
            git push origin "$current_tag" # Subir el tag actualizado

            echo "✅ ¡El tag $current_tag ha sido movido al nuevo commit!"
        else
            echo "🚀 Sin cambios en la versión ni en los tags."
        fi
    else
        echo "⚠️ No se encontró ningún tag para mover."
    fi
fi
echo ""

echo "✅ ¡Proceso completado exitosamente!"
