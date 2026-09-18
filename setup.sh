#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Omarchy Welcome - Plugin Setup"
echo "=================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="mans.welcome"
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"

# Step 1: Dependencies
echo -e "${BLUE}[1/4]${NC} Checking dependencies..."
MISSING=()
command -v foot &>/dev/null || MISSING+=("foot")
command -v figlet &>/dev/null || MISSING+=("figlet")
command -v chafa &>/dev/null || MISSING+=("chafa")
command -v zenity &>/dev/null || MISSING+=("zenity")

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "${YELLOW}⚠️  Installing: ${MISSING[*]}${NC}"
    if command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm "${MISSING[@]}"
    elif command -v apt &>/dev/null; then
        sudo apt install -y "${MISSING[@]}"
    fi
else
    echo -e "${GREEN}✅ All dependencies installed${NC}"
fi

# Step 2: Copy plugin files
echo -e "${BLUE}[2/4]${NC} Installing plugin files..."
mkdir -p "$PLUGIN_DIR/bin"
cp "$SCRIPT_DIR/manifest.json" "$PLUGIN_DIR/"
cp "$SCRIPT_DIR/BarWidget.qml" "$PLUGIN_DIR/"
cp "$SCRIPT_DIR/Service.qml" "$PLUGIN_DIR/"
cp "$SCRIPT_DIR/bin/omarchy-welcome" "$PLUGIN_DIR/bin/"
chmod +x "$PLUGIN_DIR/bin/omarchy-welcome"
echo -e "${GREEN}✅ Plugin files installed${NC}"

# Step 4: Window config
echo -e "${BLUE}[3/4]${NC} Configuring window appearance..."
LOOKFEEL_FILE="$HOME/.config/omarchy/lookfeel.lua"
mkdir -p "$(dirname "$LOOKFEEL_FILE")"

if [ -f "$LOOKFEEL_FILE" ]; then
    if grep -q "omarchy-welcome" "$LOOKFEEL_FILE"; then
        echo -e "${GREEN}✅ Window config already exists${NC}"
    else
        cat >> "$LOOKFEEL_FILE" << 'EOF'

-- Omarchy Welcome Window
o.window("omarchy-welcome", {
    float = true,
    center = true,
    size = "26% 20%",
    rounding = 14,
    pin = true,
})
EOF
        echo -e "${GREEN}✅ Added window config to lookfeel.lua${NC}"
    fi
else
    cat > "$LOOKFEEL_FILE" << 'EOF'
-- Omarchy Welcome Window
o.window("omarchy-welcome", {
    float = true,
    center = true,
    size = "26% 20%",
    rounding = 14,
    pin = true,
})
EOF
    echo -e "${GREEN}✅ Created lookfeel.lua${NC}"
fi

echo ""
echo "=================================="
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=================================="
echo ""
echo "You should now see a  icon in your bar."
echo "Click it to configure your name and avatar."
echo ""
echo "If the icon doesn't appear, run:"
echo "  omarchy bar move mans.welcome right"
echo ""
