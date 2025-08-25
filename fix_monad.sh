#!/usr/bin/env bash
set -euo pipefail

echo "=== XMonad Fix Script ==="

XMONAD_CONFIG="$HOME/.config/xmonad/xmonad.hs"
BACKUP_DIR="$HOME/.config/xmonad/backups"
MAX_BACKUPS=10

# Step 0: Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Step 0.5: Backup xmonad.hs
if [ -f "$XMONAD_CONFIG" ]; then
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE="$BACKUP_DIR/xmonad_$TIMESTAMP.hs"
  cp "$XMONAD_CONFIG" "$BACKUP_FILE"
  echo "Backed up xmonad.hs to $BACKUP_FILE"

  # Rotate backups: keep only the last $MAX_BACKUPS files
  BACKUP_COUNT=$(ls -1t "$BACKUP_DIR"/xmonad_*.hs 2>/dev/null | wc -l)
  if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    NUM_TO_DELETE=$((BACKUP_COUNT - MAX_BACKUPS))
    echo "Removing $NUM_TO_DELETE old backup(s)..."
    ls -1t "$BACKUP_DIR"/xmonad_*.hs | tail -n "$NUM_TO_DELETE" | xargs rm -f
  fi
else
  echo "Warning: xmonad.hs not found at $XMONAD_CONFIG. Skipping backup."
fi

# Step 1: Install libraries for GHC
echo "Installing xmonad and xmonad-contrib for GHC..."
if cabal install --lib xmonad xmonad-contrib; then
  echo "Libraries installed successfully."
else
  echo "Error: Failed to install xmonad libraries. Exiting."
  exit 1
fi

# Step 2: Clean old XMonad build caches
echo "Cleaning old XMonad build caches..."
if [ -d "$HOME/.cache/xmonad" ]; then
  rm -rf "$HOME/.cache/xmonad/build-"* || true
  rm -f "$HOME/.cache/xmonad/xmonad-"* || true
  echo "Cache cleaned."
else
  echo "No XMonad cache directory found. Skipping cleanup."
fi

# Step 3: Recompile XMonad
echo "Recompiling XMonad configuration..."
if xmonad --recompile; then
  echo "Recompile successful."
else
  echo "Error: Recompile failed. Exiting."
  exit 1
fi

# Step 4: Restart XMonad
echo "Restarting XMonad..."
if xmonad --restart; then
  echo "XMonad restarted successfully!"
else
  echo "Error: Failed to restart XMonad. Check logs."
  exit 1
fi

echo "=== XMonad Fix Script Finished ==="
