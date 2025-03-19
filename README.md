# Unofficial Rio AppImage

![rio-logo](https://github.com/danrobi11/rio-appimage/blob/main/rio-resized.png)

Welcome to the Unofficial Rio AppImage—a portable, hardware-accelerated GPU terminal emulator based on [raphamorim/rio](https://github.com/raphamorim/rio), version 0.1.12. Built for Linux, this AppImage runs anywhere with no sandbox restrictions and a full system PATH—minimal fuss, maximum power!

## Features
- **Portable**: Single executable, no installation needed—download and run.
- **GPU-Accelerated**: Leverages `wgpu` for smooth, fast terminal rendering.
- **No Sandbox**: Full system access for ultimate flexibility.
- **Lightweight**: Bundled with just what’s needed to run Rio, nothing extra.

## Usage

1. **Download the AppImage**:
   - Grab it from the [Releases page](https://github.com/danrobi11/rio-appimage/releases).

2. **Make it Executable**:
   ```
   chmod +x rio-0.1.12-x86_64.AppImage
```
## Dependencies for Building Rio AppImage

Below is the complete list of dependencies used to build `rio-0.1.12-x86_64.AppImage`, tailored for a Debian Sid environment as of March 19, 2025.

### System Dependencies (via `apt`)

Install with:

sudo apt update
sudo apt install -y <packages>

Core Build Tools
build-essential - Includes gcc, g++, make, etc., for compilation.
git - For version control (common dependency).
wget - For downloading source and tools.

Rust Build Requirements
rustc - Rust compiler.
cargo - Rust package manager and build tool.

Rio Build Requirements
libxkbcommon-dev - Keyboard handling for X11 and Wayland.
libgl1-mesa-dev - OpenGL support for GPU rendering.
libegl1-mesa-dev - EGL support for GPU rendering.
libgles2-mesa-dev - OpenGL ES support for GPU rendering.
libx11-dev - X11 protocol client library.
libxcb1-dev - X C Binding for X11.
libxkbcommon-x11-dev - XKB integration with X11.
libwayland-dev - Wayland protocol support.

AppImage Tools
libfuse3-dev - FUSE 3 development files.
fuse3 - FUSE 3 runtime.

Terminal Fallback
xterm - Fallback terminal.
Runtime Libraries (Bundled)
These libraries are copied into $APPDIR/usr/lib/ from /usr/lib/x86_64-linux-gnu/ or /lib/x86_64-linux-gnu/:

libxkbcommon.so.0, libGL.so.1, libEGL.so.1, libGLESv2.so.2, libX11.so.6, libxcb.so.1, libwayland-client.so.0, libwayland-server.so.0, libc.so.6, libm.so.6, libdl.so.2, libpthread.so.0, librt.so.1.

Additional Tools
linuxdeployqt: Download.
appimagetool: Download.

Notes
Source: https://github.com/raphamorim/rio/archive/refs/tags/v0.1.12.tar.gz.
Runtime: Libraries bundled for portability.
```
## Disclaimer

This repository contains a script for building the rio-0.1.12-x86_64.AppImage. The script was created with assistance from Grok 3, an AI developed by xAI (https://grok.com). While efforts have been made to ensure the script functions correctly, it is provided "as is" without any warranties or guarantees of performance, reliability, or compatibility. Users are responsible for testing and verifying the script's output before use. Neither the repository owner nor xAI is liable for any issues, damages, or data loss that may arise from using this script or the resulting AppImage.
