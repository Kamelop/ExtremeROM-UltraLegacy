#!/bin/bash

set -e

# ==== Colors ====
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
NC="\033[0m"

# ==== ASCII Banner ====
cat << "EOF"
+================================================================+
|                                                                |        
|                  _   _                 _____   ____  __  __    |
|       /\        | | (_)               |  __ \ / __ \|  \/  |   |
|      /  \   _ __| |_ _ ___  __ _ _ __ | |__) | |  | | \  / |   |
|     / /\ \ | '__| __| / __|/ _` | '_ \|  _  /| |  | | |\/| |   |
|    / ____ \| |  | |_| \__ \ (_| | | | | | \ \| |__| | |  | |   |
|   /_/    \_\_|   \__|_|___/\__,_|_| |_|_|  \_\\____/|_|  |_|   |
|                                                                |        
|          ArtisanROM Ultra Legacy   V 1 . 0 . 0 - rc1           |          
+================================================================+

EOF

# ==== Git identity ====
read -p "Enter your name (required): " git_user
read -p "Enter your email (required): " git_email

if [ -z "$git_user" ] || [ -z "$git_email" ]; then
    echo -e "${RED}❌ Git name and email are required!${NC}"
    exit 1
fi

git config --global user.name "$git_user"
git config --global user.email "$git_email"
echo -e "${GREEN}✓ Git configured as $git_user <$git_email>${NC}"

# ==== Install Dependencies ====
echo -e "${YELLOW}Installing required packages...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y attr ccache clang git golang libbrotli-dev libgtest-dev liblz4-dev \
libpcre2-dev libprotobuf-dev libunwind-dev libusb-1.0-0-dev libzstd-dev lld openjdk-11-jdk \
protobuf-compiler zip zipalign make cmake npm lz4 brotli patchelf curl xxd bison flex

echo -e "${GREEN}✓ All packages installed.${NC}"

# ==== Clone or detect repo ====
REPO_URL="https://github.com/ArtisanROM/ExtremeROM-UltraLegacy.git"
REPO_NAME="ExtremeROM-UltraLegacy"

echo -e "${YELLOW}Checking for existing repo...${NC}"
if [ -d "$REPO_NAME" ]; then
    echo -e "${GREEN}✓ Found existing repo at ${REPO_NAME}${NC}"
else
    echo -e "${YELLOW}Cloning repo from $REPO_URL...${NC}"
    git clone --recurse-submodules "$REPO_URL"
    echo -e "${GREEN}✓ Repo cloned successfully.${NC}"
fi

cd "$REPO_NAME"

# ==== Prompt for device codename ====
echo
echo -e "${YELLOW}Choose a device codename to set up the build:${NC}"
echo -e "  ${CYAN}crownlte${NC}   → Samsung Galaxy Note9"
echo -e "  ${CYAN}r7n${NC}        → Samsung Galaxy Note10 Lite"
echo -e "  ${CYAN}star2lte${NC}   → Samsung Galaxy S9+"
echo -e "  ${CYAN}starlte${NC}    → Samsung Galaxy S9"
echo

read -p "Enter codename (e.g., crownlte): " codename

if [[ -z "$codename" ]]; then
    echo -e "${RED}❌ Codename is required to continue!${NC}"
    exit 1
fi

# ==== Source buildenv ====
echo -e "${CYAN}Sourcing buildenv.sh for '${codename}'...${NC}"
source ./buildenv.sh "$codename"

# ==== Confirm before build ====
echo
echo -e "${RED}⚠️  WARNING: This process will download over 25GB of files.${NC}"
read -p "Do you want to begin building now? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Starting build...${NC}"
    run_cmd make_rom
    echo -e "${GREEN}✅ Build complete! You can find your ROM in the ${CYAN}out${GREEN} directory.${NC}"
else
    echo -e "${YELLOW}🕓 Build was skipped. You can run it later using:${NC} ${CYAN}run_cmd make_rom${NC}"
fi
