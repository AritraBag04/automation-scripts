#!/usr/bin/env bash

set -e

DOWNLOADS="$HOME/Downloads"
ARCHIVE_DIR="$DOWNLOADS/archive_$(date +%Y-%m-%d)"

AGE_OPTIONS=(30 60 90)
FILE_TYPES=("deb" "zip" "AppImage" "tar.gz")

echo "Downloads Janitor"
echo "Directory: $DOWNLOADS"
echo

# Ask for age threshold
echo "Select file age to clean:"
select AGE in "${AGE_OPTIONS[@]}"; do
  [[ -n "$AGE" ]] && break
done

echo
echo "Files older than $AGE days will be scanned."
echo

# Find files
declare -A FILE_GROUPS

for ext in "${FILE_TYPES[@]}"; do
  mapfile -t files < <(
    find "$DOWNLOADS" -maxdepth 1 -type f -name "*.$ext" -mtime +"$AGE"
  )
  FILE_GROUPS["$ext"]="${files[*]}"
done

# -----------------------------
# Display results
# -----------------------------
FOUND_ANY=false
for ext in "${FILE_TYPES[@]}"; do
  files=(${FILE_GROUPS[$ext]})
  if [[ ${#files[@]} -gt 0 ]]; then
    FOUND_ANY=true
    echo ".$ext files:"
    for f in "${files[@]}"; do
      echo "  - $(basename "$f")"
    done
    echo
  fi
done

if [[ "$FOUND_ANY" == false ]]; then
  echo "No matching files found. You're clean."
  exit 0
fi

# -----------------------------
# Ask action
# -----------------------------
echo "What do you want to do?"
echo "[a] Archive   [d] Delete   [i] Ignore"
read -rp "> " ACTION

case "$ACTION" in
  a|A)
    mkdir -p "$ARCHIVE_DIR"
    for ext in "${FILE_TYPES[@]}"; do
      for f in ${FILE_GROUPS[$ext]}; do
        [[ -f "$f" ]] && mv "$f" "$ARCHIVE_DIR/"
      done
    done
    echo "Files archived to $ARCHIVE_DIR"
    ;;
  d|D)
    for ext in "${FILE_TYPES[@]}"; do
      for f in ${FILE_GROUPS[$ext]}; do
        [[ -f "$f" ]] && rm -f "$f"
      done
    done
    echo "Files deleted."
    ;;
  *)
    echo "Ignored. No changes made."
    ;;
esac

echo "Done."
