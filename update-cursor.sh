sudo tee /usr/local/bin/update-cursor >/dev/null <<'EOF'
#!/bin/sh
set -e

if [ -z "$1" ]; then
    echo "Usage: update-cursor /path/to/Cursor-NEW-VERSION.AppImage"
    exit 1
fi

APPIMAGE="$1"

if [ ! -f "$APPIMAGE" ]; then
    echo "Error: '$APPIMAGE' not found."
    exit 1
fi

TMPDIR=$(mktemp -d)
cd "$TMPDIR"

echo "[*] Extracting new AppImage..."
"$APPIMAGE" --appimage-extract >/dev/null

echo "[*] Replacing /opt/cursor..."
sudo rm -rf /opt/cursor
sudo mv squashfs-root /opt/cursor

echo "[*] Setting permissions..."
sudo chmod -R a+rX /opt/cursor
sudo find /opt/cursor -type f -name AppRun -exec sudo chmod a+rx {} \;

echo "[*] Cleaning up..."
cd /
rm -rf "$TMPDIR"

echo "[✔] Cursor updated successfully."
EOF
