#!/bin/bash
# rio-appimage.sh
# Purpose: Build a portable Rio terminal AppImage based on Debian Sid, fully self-contained, with no sandbox.

set -e

# Variables
APP="rio"
VERSION="0.1.12"  # Latest stable release as of March 19, 2025; adjust as needed
WORKDIR="$HOME/appimage-workdir"
APPDIR="$WORKDIR/$APP.AppDir"
OUTPUT="$HOME/$APP-$VERSION-x86_64.AppImage"
LOGFILE="\$HOME/rio-appimage-run.log"
SOURCE_URL="https://github.com/raphamorim/rio/archive/refs/tags/v$VERSION.tar.gz"

# Clean up previous workdir
[ -d "$WORKDIR" ] && { echo "Cleaning up previous workdir..."; rm -rf "$WORKDIR"; }
mkdir -p "$WORKDIR" "$APPDIR"

# Install system dependencies
echo "Installing system dependencies..."
sudo apt update
sudo apt install -y \
    build-essential git wget libfuse3-dev fuse3 \
    rustc cargo \
    libxkbcommon-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
    libx11-dev libxcb1-dev libxkbcommon-x11-dev libwayland-dev \
    xterm  # For terminal fallback

# Download and extract Rio source
echo "Downloading Rio $VERSION source from $SOURCE_URL..."
wget -c "$SOURCE_URL" -O "$WORKDIR/rio-$VERSION.tar.gz" || { echo "Failed to download Rio source"; exit 1; }
tar -xzf "$WORKDIR/rio-$VERSION.tar.gz" -C "$WORKDIR"
cd "$WORKDIR/rio-$VERSION"

# Build Rio with cargo
echo "Building Rio with cargo..."
cargo build --release

# Prepare AppDir
echo "Preparing AppDir..."
mkdir -p "$APPDIR/usr/bin"
cp "target/release/rio" "$APPDIR/usr/bin/"

# Bundle runtime libraries
echo "Bundling libraries..."
mkdir -p "$APPDIR/usr/lib"
for lib in \
    libxkbcommon.so.0 libGL.so.1 libEGL.so.1 libGLESv2.so.2 \
    libX11.so.6 libxcb.so.1 libwayland-client.so.0 libwayland-server.so.0 \
    libc.so.6 libm.so.6 libdl.so.2 libpthread.so.0 librt.so.1; do
    cp -v /usr/lib/x86_64-linux-gnu/$lib "$APPDIR/usr/lib/" 2>/dev/null || \
    cp -v /lib/x86_64-linux-gnu/$lib "$APPDIR/usr/lib/" 2>/dev/null || \
    echo "Warning: $lib not found; may need manual addition."
done

# Download tools with error checking
echo "Downloading linuxdeployqt and appimagetool..."
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" -O "$WORKDIR/linuxdeployqt" || { echo "Failed to download linuxdeployqt"; exit 1; }
wget -c "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" -O "$WORKDIR/appimagetool" || { echo "Failed to download appimagetool"; exit 1; }
chmod +x "$WORKDIR/linuxdeployqt" "$WORKDIR/appimagetool"

# Create AppRun with dynamic log path and debug output
echo "Creating AppRun with custom PATH and terminal enforcement..."
cat << EOF > "$APPDIR/AppRun"
#!/bin/bash
HERE="\$(dirname "\$(readlink -f "\${0}")")"
export PATH="\$HERE/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:\$PATH"
export LD_LIBRARY_PATH="\$HERE/usr/lib:\$LD_LIBRARY_PATH"
LOGFILE="\$HOME/rio-appimage-run.log"
echo "Starting Rio..." >> "\$LOGFILE"
echo "PATH: \$PATH" >> "\$LOGFILE"
echo "LD_LIBRARY_PATH: \$LD_LIBRARY_PATH" >> "\$LOGFILE"
echo "LOGFILE: \$LOGFILE" >> "\$LOGFILE"
echo "Checking dependencies..." >> "\$LOGFILE"
ldd "\$HERE/usr/bin/rio" >> "\$LOGFILE" 2>&1
if [ -t 0 ]; then
    echo "Running in existing terminal..." >> "\$LOGFILE"
    "\$HERE/usr/bin/rio" "\$@" >> "\$LOGFILE" 2>&1
else
    echo "No TTY detected; launching in xterm..." >> "\$LOGFILE"
    xterm -e "\$HERE/usr/bin/rio" "\$@" >> "\$LOGFILE" 2>&1
fi
EXIT_CODE=\$?
echo "Rio exited with code \$EXIT_CODE" >> "\$LOGFILE"
exit \$EXIT_CODE
EOF
chmod +x "$APPDIR/AppRun"

# Create desktop file
echo "Creating desktop file..."
cat << EOF > "$APPDIR/rio.desktop"
[Desktop Entry]
Name=Rio Terminal
Exec=rio
Type=Application
Icon=rio
Categories=Utility;TerminalEmulator;
Terminal=true
EOF

# Copy icon
echo "Copying icon..."
wget -O "$APPDIR/rio.png" "https://raw.githubusercontent.com/raphamorim/rio/main/docs/static/assets/rio-logo.png" 2>/dev/null || \
echo "Icon download failed; proceeding without it..."

# Bundle with linuxdeployqt, bypassing glibc check
echo "Bundling dependencies with linuxdeployqt..."
"$WORKDIR/linuxdeployqt" "$APPDIR/usr/bin/rio" -bundle-non-qt-libs -unsupported-allow-new-glibc -verbose=2

# Package AppImage with verbosity and no AppStream
echo "Packaging AppImage..."
"$WORKDIR/appimagetool" --no-appstream -v "$APPDIR" "$OUTPUT"

# Clean up (optional; uncomment if desired)
# echo "Cleaning up..."
# rm -rf "$WORKDIR"

echo "Done! Your Rio AppImage is at: $OUTPUT"
echo "Check the debug log at \$HOME/rio-appimage-run.log"
