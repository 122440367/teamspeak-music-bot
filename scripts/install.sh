#!/usr/bin/env bash
set -euo pipefail

echo "╔══════════════════════════════════════╗"
echo "║       TSMusicBot Installer           ║"
echo "╚══════════════════════════════════════╝"
echo ""

INSTALL_DIR="/opt/tsmusicbot"
SERVICE_NAME="tsmusicbot"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS"
    exit 1
fi

echo "[1/5] Installing system dependencies..."
case $OS in
    ubuntu|debian)
        sudo apt-get update -qq
        sudo apt-get install -y -qq curl ffmpeg
        ;;
    centos|rhel|fedora)
        sudo yum install -y curl ffmpeg
        ;;
    arch|manjaro)
        sudo pacman -S --noconfirm curl ffmpeg
        ;;
    *)
        echo "Unsupported OS: $OS. Please install Node.js 20 and FFmpeg manually."
        ;;
esac

echo "[2/5] Installing Node.js 20 LTS..."
if ! command -v node &> /dev/null || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs 2>/dev/null || sudo yum install -y nodejs 2>/dev/null
fi
echo "Node.js $(node -v) installed"

echo "[3/5] Downloading TSMusicBot..."
sudo mkdir -p "$INSTALL_DIR"
if [ -d "$(pwd)/dist" ]; then
    sudo cp -r "$(pwd)"/* "$INSTALL_DIR/"
else
    echo "Please run this script from the TSMusicBot source directory after building."
    exit 1
fi

echo "[4/5] Installing npm dependencies..."
cd "$INSTALL_DIR"
sudo npm install --production

echo "[5/5] Creating systemd service..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOL
[Unit]
Description=TSMusicBot - TeamSpeak Music Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/node ${INSTALL_DIR}/dist/index.js
Restart=on-failure
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl start ${SERVICE_NAME}

echo ""
echo "╔══════════════════════════════════════╗"
echo "║    TSMusicBot installed and running! ║"
echo "║                                      ║"
echo "║    WebUI: http://localhost:3000       ║"
echo "║                                      ║"
echo "║    Commands:                          ║"
echo "║    systemctl status tsmusicbot       ║"
echo "║    systemctl restart tsmusicbot      ║"
echo "║    systemctl stop tsmusicbot         ║"
echo "╚══════════════════════════════════════╝"
