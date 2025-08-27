#!/bin/bash
# Usage: ./generate_alt.sh relative_image_path.jpg
# Example: ./generate_alt.sh about/tristengrant_2022_photo.jpg

BASE_DIR="/misc/files/github/tristengrant-website/src/images"
REL_PATH="$1"

if [[ -z "$REL_PATH" ]]; then
  echo "Usage: $0 relative_path_from_src_images/"
  exit 1
fi

IMAGE_PATH="$BASE_DIR/$REL_PATH"

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "Error: File does not exist: $IMAGE_PATH"
  exit 1
fi

TEMP_B64="/tmp/ollama_photo.b64"
TEMP_JSON="/tmp/ollama_request.json"

# Encode image to base64
base64 -w0 "$IMAGE_PATH" > "$TEMP_B64"

# Build JSON request
cat > "$TEMP_JSON" <<EOF
{
  "model": "llava",
  "prompt": "Describe this image for alt text",
  "stream": false,
  "images": ["$(cat "$TEMP_B64")"]
}
EOF

# Call Ollama API and return only the response
curl -s http://192.168.2.221:11434/api/generate \
  -H "Content-Type: application/json" \
  -d @"$TEMP_JSON" \
  | jq -r '.response'
