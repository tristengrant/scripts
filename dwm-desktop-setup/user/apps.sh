#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"
DOWNLOAD_DIR="$HOME_DIR/Downloads"

mkdir -p "$DOWNLOAD_DIR"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt install -y jq
fi

# Define AppImages: Name|Source (GitHub repo or direct URL)
APPIMAGES=(
    "Krita|kde/krita"
    "Bitwarden|bitwarden/desktop"
    "Obsidian|obsidianmd/obsidian-releases"
)

for entry in "${APPIMAGES[@]}"; do
    IFS='|' read -r NAME SOURCE <<< "$entry"

    FILE="$DOWNLOAD_DIR/${NAME}.AppImage"

    if [[ "$NAME" == "Krita" ]]; then
        echo "Fetching latest Krita AppImage..."
        LATEST_VERSION=$(curl -fsSL https://download.kde.org/stable/krita/ \
            | grep -Po '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' \
            | sort -V | tail -n1)
        DOWNLOAD_URL="https://download.kde.org/stable/krita/${LATEST_VERSION}/krita-${LATEST_VERSION}-x86_64.AppImage"
    elif [[ "$SOURCE" == *"/"* ]]; then
        echo "Fetching latest release for $NAME from GitHub..."
        API_URL="https://api.github.com/repos/$SOURCE/releases/latest"
        DOWNLOAD_URL=$(curl -sSL "$API_URL" \
            | jq -r '.assets[] | select(.name | test("AppImage$")) | .browser_download_url' \
            | head -n1)

        if [ -z "$DOWNLOAD_URL" ]; then
            echo "Warning: Could not find AppImage download for $NAME, skipping."
            continue
        fi
    else
        DOWNLOAD_URL="$SOURCE"
    fi

    if [ ! -f "$FILE" ]; then
        echo "Downloading $NAME to $DOWNLOAD_DIR..."
        curl -L -o "$FILE" "$DOWNLOAD_URL"
        chmod +x "$FILE"
    else
        echo "$NAME AppImage already exists in $DOWNLOAD_DIR, skipping download."
    fi
done

echo "All AppImages downloaded to $DOWNLOAD_DIR."

# Add DWM session
sudo mkdir -p /usr/share/xsessions
cat <<EOF | sudo tee /usr/share/xsessions/dwm.desktop >/dev/null
[Desktop Entry]
Name=dwm
Comment=Dynamic window manager
Exec=dwm
Type=XSession
EOF

# Install Taplo TOML toolkit
cd /home/tristen/Downloads
curl -fsSL -o taplo.gz https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-x86_64.gz
gzip -d taplo.gz
sudo install -m 755 taplo /usr/local/bin/taplo
rm taplo
echo "Taplo installed."

# Install marksman markdown assist
curl -fsSL -o marksman  https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64
sudo install -m 755 marksman /usr/local/bin/marksman
rm marksman
echo "Marksman installed."

# Install markdown-oxide
IFS=$'\n\t'

echo "Installing markdown-oxide via cargo..."

# Ensure Rust toolchain
if ! command -v cargo >/dev/null; then
  echo "Rust not found. Installing rustup and toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Install markdown-oxide
cargo install --locked --git https://github.com/Feel-ix-343/markdown-oxide.git markdown-oxide

echo "markdown-oxide installed successfully."

# Install latest ltex-ls-plus
IFS=$'\n\t'

OWNER="ltex-plus"
REPO="ltex-ls-plus"
DEST_DIR="$HOME/.local"
FINAL_NAME="ltex-ls-plus"

echo "Installing ${REPO} into ${DEST_DIR}/${FINAL_NAME}…"

# Create destination if missing
mkdir -p "$DEST_DIR"

# Get latest tag
tag=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
      | grep -Po '"tag_name":\s*"\K[^"]+')
if [ -z "$tag" ]; then
  echo "❗ Could not fetch latest tag for ${OWNER}/${REPO}"
  exit 1
fi
echo "Latest version: $tag"

# Find linux x64 tar.gz asset
asset=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
         | grep -Po '"name":\s*"\K[^"]+' \
         | grep -E 'linux.*x64.*\.tar\.gz$' \
         | head -n1)
if [ -z "$asset" ]; then
  echo "❗ Could not find linux x64 tar.gz asset for version $tag"
  exit 1
fi
echo "Found asset: $asset"

# Construct download URL
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${asset}"
echo "Download URL: $url"

# Download to temp file
tmpfile=$(mktemp)
curl -fsSL -o "$tmpfile" "$url"

# Extract directly into DEST_DIR
tmp_extract_dir=$(mktemp -d)
tar -xzvf "$tmpfile" -C "$tmp_extract_dir"

# Find the extracted folder
extracted=$(find "$tmp_extract_dir" -maxdepth 1 -type d -name "${REPO}-*" | head -n1)
if [ -z "$extracted" ]; then
  echo "❗ Could not determine extracted directory"
  exit 1
fi

# Remove old install if exists
rm -rf "${DEST_DIR}/${FINAL_NAME}"

# Move and rename
mv "$extracted" "${DEST_DIR}/${FINAL_NAME}"

# Clean up
rm -f "$tmpfile"
rm -rf "$tmp_extract_dir"

echo "Symlinking ltex-ls-plus bin to ~/.local/bin"
ln -sf ~/.local/ltex-ls-plus/bin/ltex-ls-plus ~/.local/bin

echo "Installed ${REPO} version $tag into ${DEST_DIR}/${FINAL_NAME}"

echo "Writing todo file in Downloads directory..."
cat > /home/tristen/Downloads/todo.txt <<EOF
Manually Install:
Jellyfin Media Player - https://github.com/jellyfin/jellyfin-media-player/releases
Hugo - https://github.com/gohugoio/hugo/releases/
VCV Rack - https://vcvrack.com/Rack#get
Reaper - https://www.reaper.fm/download.php
Helix - https://github.com/helix-editor/helix/releases/
EOF

sudo chown -R tristen:tristen /home/tristen
sudo chmod u+w /home/tristen
