#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"
DOWNLOAD_DIR="$HOME_DIR/Downloads"
LOCAL_BIN="$HOME_DIR/.local/bin"

mkdir -p "$DOWNLOAD_DIR" "$LOCAL_BIN"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq not found, installing..."
    sudo apt install -y jq
fi

### ------------------------------
### Helper function to download and install .deb from GitHub
### ------------------------------
download_from_github() {
    local OWNER="$1"
    local REPO="$2"
    local PATTERN="$3"
    local OUT_DIR="$4"

    echo "Fetching latest release for $REPO..."

    # Special case: Jellyfin Media Player (assume Trixie)
    if [[ "$REPO" == "jellyfin-media-player" ]]; then
        file_name="jellyfin-media-player_1.12.0-trixie.deb"
        url="https://github.com/jellyfin/${REPO}/releases/download/v1.12.0/$file_name"
        out_file="$OUT_DIR/$file_name"
        echo "Downloading $REPO to $out_file..."
        curl -L -o "$out_file" "$url"

        echo "Installing dependencies for Jellyfin Media Player..."
        sudo apt update
        sudo apt install -y libcec7 libqt5webchannel5 libqt5webengine5 \
            qml-module-qtwebengine qml-module-qtwebchannel qml-module-qtquick-controls

        echo "Installing $REPO..."
        sudo dpkg -i "$out_file"
        sudo apt-get install -f -y
        rm -f "$out_file"
        echo "$REPO installed successfully."
        return
    fi

    # Clear broken Helix installs if needed
    if [[ "$REPO" == "helix" ]]; then
        sudo dpkg --remove --force-remove-reinstreq helix || true
    fi

    # Standard GitHub release flow
    local API_URL="https://api.github.com/repos/${OWNER}/${REPO}/releases/latest"
    local DOWNLOAD_URL
    DOWNLOAD_URL=$(curl -sSL "$API_URL" \
        | jq -r --arg pattern "$PATTERN" '.assets[] | select(.name | test($pattern)) | .browser_download_url' \
        | head -n1)

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "❌ Could not find a matching .deb asset for $REPO"
        return 1
    fi

    local FILE_NAME
    FILE_NAME=$(basename "$DOWNLOAD_URL")
    local OUT_FILE="$OUT_DIR/$FILE_NAME"

    echo "Downloading $REPO to $OUT_FILE..."
    curl -L -o "$OUT_FILE" "$DOWNLOAD_URL"

    echo "Installing $REPO..."
    sudo dpkg -i "$OUT_FILE" || sudo apt-get install -f -y
    rm -f "$OUT_FILE"
    echo "$REPO installed successfully."
}

### ------------------------------
### Install .deb packages sequentially
### ------------------------------
download_from_github "jellyfin" "jellyfin-media-player" ".*amd64.*\\.deb$" "$DOWNLOAD_DIR"
download_from_github "gohugoio" "hugo" "hugo_extended.*amd64\\.deb$" "$DOWNLOAD_DIR"
download_from_github "helix-editor" "helix" "helix_.*amd64\\.deb$" "$DOWNLOAD_DIR"

### ------------------------------
### Install ltex-ls-plus last
### ------------------------------
install_ltex_ls_plus() {
    local OWNER="ltex-plus"
    local REPO="ltex-ls-plus"
    local DEST_DIR="$HOME_DIR/.local"
    local FINAL_NAME="ltex-ls-plus"

    echo "Installing ${REPO} into ${DEST_DIR}/${FINAL_NAME}…"

    mkdir -p "$DEST_DIR"

    local TAG=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
          | grep -Po '"tag_name":\s*"\K[^"]+')
    echo "Latest version: $TAG"

    local ASSET=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
         | grep -Po '"name":\s*"\K[^"]+' \
         | grep -E 'linux.*x64.*\.tar\.gz$' \
         | head -n1)
    echo "Found asset: $ASSET"

    local URL="https://github.com/${OWNER}/${REPO}/releases/download/${TAG}/${ASSET}"
    local TMPFILE=$(mktemp)
    curl -fsSL -o "$TMPFILE" "$URL"

    local TMP_EXTRACT_DIR=$(mktemp -d)
    tar -xzvf "$TMPFILE" -C "$TMP_EXTRACT_DIR"

    local EXTRACTED=$(find "$TMP_EXTRACT_DIR" -maxdepth 1 -type d -name "${REPO}-*" | head -n1)
    rm -rf "${DEST_DIR}/${FINAL_NAME}"
    mv "$EXTRACTED" "${DEST_DIR}/${FINAL_NAME}"

    rm -f "$TMPFILE"
    rm -rf "$TMP_EXTRACT_DIR"

    ln -sf "$DEST_DIR/$FINAL_NAME/bin/ltex-ls-plus" "$LOCAL_BIN"

    echo "Installed ${REPO} version $TAG into ${DEST_DIR}/${FINAL_NAME}"
}

install_ltex_ls_plus

# --- todo.txt ---
cat > "$DOWNLOAD_DIR/todo.txt" <<EOF
Download the following AppImages and then use 'appimage.sh' script to install:
Bitwarden - https://bitwarden.com/download/?app=desktop&platform=linux&variant=appimage
Obsidian - https://obsidian.md/download (alternatively could install the .deb)
EOF

sudo chown -R "$USER:$USER" "$HOME_DIR"
sudo chmod u+w "$HOME_DIR"

echo "All apps installed successfully."
