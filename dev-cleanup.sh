#!/usr/bin/env bash

set -e

ROOT_DIR="$HOME/Projects"
DRY_RUN=true   # change to false to actually delete

echo "Dev Cleanup Script"
echo "Root: $ROOT_DIR"
echo "Dry run: $DRY_RUN"
echo

delete_dir() {
  local dir="$1"
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN] Would delete: $dir"
  else
    echo "Deleting: $dir"
    rm -rf "$dir"
  fi
}

confirm() {
  read -rp "$1 [y/N]: " choice
  [[ "$choice" == "y" || "$choice" == "Y" ]]
}

# -------------------------------------
# node_modules
# -------------------------------------
echo "Searching for node_modules..."
mapfile -t NODE_MODULES < <(find "$ROOT_DIR" -type d -name node_modules -prune 2>/dev/null)

if [ "${#NODE_MODULES[@]}" -gt 0 ]; then
  echo "Found ${#NODE_MODULES[@]} node_modules directories."
  confirm "Delete ALL node_modules?" && \
  for d in "${NODE_MODULES[@]}"; do delete_dir "$d"; done
else
  echo "No node_modules found."
fi
echo

# -------------------------------------
# Python virtual environments
# -------------------------------------
echo "Searching for Python virtualenvs..."
mapfile -t VENV_DIRS < <(find "$ROOT_DIR" -type d \( -name venv -o -name .venv \) -prune 2>/dev/null)

if [ "${#VENV_DIRS[@]}" -gt 0 ]; then
  echo "Found ${#VENV_DIRS[@]} virtualenvs."
  confirm "Delete ALL Python virtualenvs?" && \
  for d in "${VENV_DIRS[@]}"; do delete_dir "$d"; done
else
  echo "No virtualenvs found."
fi
echo

# -------------------------------------
# Java build artifacts
# -------------------------------------
echo "Searching for Java build artifacts..."
mapfile -t JAVA_BUILDS < <(
  find "$ROOT_DIR" -type f \( -name pom.xml -o -name build.gradle -o -name settings.gradle \) \
  -exec dirname {} \; 2>/dev/null | while read -r proj; do
    [ -d "$proj/target" ] && echo "$proj/target"
    [ -d "$proj/build" ] && echo "$proj/build"
  done
)

if [ "${#JAVA_BUILDS[@]}" -gt 0 ]; then
  echo "Found ${#JAVA_BUILDS[@]} Java build directories."
  confirm "Delete ALL Java build artifacts?" && \
  for d in "${JAVA_BUILDS[@]}"; do delete_dir "$d"; done
else
  echo "No Java build artifacts found."
fi
echo

echo "Cleanup complete."
