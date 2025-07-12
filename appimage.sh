#!/bin/bash

set -e

APP_DIR="$HOME/Applications"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$APP_DIR" "$ICON_DIR" "$DESKTOP_DIR"

function extract_icon() {
  local appimage="$1"
  local app_name="$2"
  local temp_dir
  temp_dir=$(mktemp -d)

  (cd "$temp_dir" && "$appimage" --appimage-extract > /dev/null 2>&1 || true)

  local found_icon
  found_icon=$(find "$temp_dir/squashfs-root" -type f \( -iname '*.png' -o -iname '*.svg' \) | head -n 1)

  if [[ -n "$found_icon" ]]; then
    local ext="${found_icon##*.}"
    local dest="$ICON_DIR/${app_name,,}.$ext"
    cp "$found_icon" "$dest"
    echo "$dest"
  else
    echo ""
  fi

  rm -rf "$temp_dir"
}

function install_new_appimage() {
  echo "Available AppImages in ~/Downloads:"
  ls "$HOME/Downloads"/*.AppImage 2>/dev/null || { echo "No AppImages found."; return; }
  echo

  read -rp "Enter the AppImage filename (e.g., krita-5.2.10-x86_64.AppImage): " file
  src="$HOME/Downloads/$file"
  [[ ! -f "$src" ]] && { echo "File not found."; return; }

  read -rp "Application name (e.g., Krita): " app_name
  read -rp "Application category (e.g., Graphics, Utility, Development): " category
  read -rp "Icon path (leave blank to extract from AppImage): " icon_path
  read -rp "Keywords (comma-separated, optional): " keywords
  read -rp "Mime types (semicolon-separated, optional): " mimetypes

  dest="$APP_DIR/$file"
  mv "$src" "$dest"
  chmod +x "$dest"

  if [[ -z "$icon_path" ]]; then
    echo "Extracting icon..."
    icon_path=$(extract_icon "$dest" "$app_name")
    if [[ -z "$icon_path" ]]; then
      echo "⚠️ No icon found, using AppImage path as icon."
      icon_path="$dest"
    else
      echo "✅ Icon extracted to $icon_path"
    fi
  fi

  # Format optional fields
  [[ -n "$keywords" ]] && keywords="Keywords=$(echo "$keywords" | tr ',' ';');"
  [[ -n "$mimetypes" ]] && mimetypes="MimeType=$mimetypes"

  desktop_file="$DESKTOP_DIR/${app_name,,}.desktop"
  cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=$app_name
Exec=$dest
Icon=$icon_path
Categories=$category;
$keywords
$mimetypes
Terminal=false
StartupNotify=true
EOF

  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  echo "✅ $app_name installed and integrated."
}

function update_appimage() {
  echo "Installed AppImages in $APP_DIR:"
  ls "$APP_DIR"/*.AppImage 2>/dev/null || { echo "No AppImages found."; return; }
  echo

  read -rp "Enter the application name to update (e.g., Krita): " app_name
  app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
  old_appimage=$(find "$APP_DIR" -iname "$app_name_lower*.AppImage" | head -n 1)

  [[ -z "$old_appimage" ]] && { echo "AppImage not found."; return; }
  echo "Found: $old_appimage"

  read -rp "Enter the new AppImage filename in ~/Downloads: " new_file
  new_path="$HOME/Downloads/$new_file"
  [[ ! -f "$new_path" ]] && { echo "New AppImage not found."; return; }

  chmod +x "$new_path"
  mv "$new_path" "$old_appimage"
  echo "✅ Replaced with new AppImage."

  read -rp "Re-extract icon from new AppImage? (y/N): " update_icon
  desktop_file="$DESKTOP_DIR/$app_name_lower.desktop"
  icon_path=$(grep -i '^Icon=' "$desktop_file" | cut -d= -f2)
  category=$(grep -i '^Categories=' "$desktop_file" | cut -d= -f2)
  keywords=$(grep -i '^Keywords=' "$desktop_file" | cut -d= -f2)
  mimetypes=$(grep -i '^MimeType=' "$desktop_file" | cut -d= -f2)

  if [[ "$update_icon" =~ ^[Yy]$ ]]; then
    echo "Extracting new icon..."
    icon_path=$(extract_icon "$old_appimage" "$app_name")
    if [[ -z "$icon_path" ]]; then
      echo "⚠️ Icon not found, keeping old icon."
      icon_path="$old_appimage"
    else
      echo "✅ Icon updated: $icon_path"
    fi
  fi

  [[ -n "$keywords" ]] && keywords="Keywords=$keywords;"
  [[ -n "$mimetypes" ]] && mimetypes="MimeType=$mimetypes"

  cat > "$desktop_file" <<EOF
[Desktop Entry]
Type=Application
Name=$app_name
Exec=$old_appimage
Icon=$icon_path
Categories=$category;
$keywords
$mimetypes
Terminal=false
StartupNotify=true
EOF

  update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  echo "✅ $app_name updated and menu entry refreshed."
}

function uninstall_appimage() {
  echo "Installed AppImages:"
  find "$APP_DIR" -maxdepth 1 -type f -name "*.AppImage" | while read -r app; do
    echo " - $(basename "$app")"
  done

  echo
  read -rp "Enter the application name to uninstall (e.g., Krita): " app_name
  app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
  app_path=$(find "$APP_DIR" -iname "$app_name_lower*.AppImage" | head -n 1)
  icon_path=$(find "$ICON_DIR" -iname "$app_name_lower.*" | head -n 1)
  desktop_file="$DESKTOP_DIR/$app_name_lower.desktop"

  [[ ! -f "$app_path" ]] && { echo "❌ AppImage not found."; return; }

  read -rp "Are you sure you want to uninstall $app_name? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -f "$app_path"
    rm -f "$icon_path"
    rm -f "$desktop_file"
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    echo "✅ $app_name has been uninstalled."
  else
    echo "❎ Cancelled."
  fi
}

while true; do
  echo
  echo "==== AppImage Manager ===="
  echo "1. Install new AppImage"
  echo "2. Update existing AppImage"
  echo "3. Uninstall AppImage"
  echo "4. Exit"
  read -rp "Choose an option [1-4]: " choice

  case "$choice" in
    1) install_new_appimage ;;
    2) update_appimage ;;
    3) uninstall_appimage ;;
    4) echo "👋 Goodbye!"; exit 0 ;;
    *) echo "Invalid option. Try again." ;;
  esac
done
