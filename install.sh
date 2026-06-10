#!/usr/bin/env bash
set -euo pipefail

REPO="melikednl/data-engineer"
BRANCH="main"
REGISTRY_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/registry.json"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/components"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Data Engineer - Opencode Pack Installer║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Parse args ---
TARGET="project"
while [[ $# -gt 0 ]]; do
  case $1 in
    --global) TARGET="global" ;;
    --help|-h)
      echo "Usage: install.sh [--global]"
      echo "  --global    Install globally (~/.config/opencode/)"
      echo "  (default)   Install in current project (.opencode/)"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
  shift
done

if [ "$TARGET" = "global" ]; then
  COMMANDS_DIR="$HOME/.config/opencode/commands"
  SKILLS_DIR="$HOME/.config/opencode/skills"
  echo -e "${GLOBAL}→ Installing globally (~/.config/opencode/)${NC}"
else
  PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
  COMMANDS_DIR="$PROJECT_ROOT/.opencode/commands"
  SKILLS_DIR="$PROJECT_ROOT/.opencode/skills"
  echo -e "${GREEN}→ Installing in project ($PROJECT_ROOT/.opencode/)${NC}"
fi

# --- Detect mode ---
USE_OCX=false
if command -v ocx &>/dev/null; then
  USE_OCX=true
fi

install_via_ocx() {
  echo -e "${CYAN}📦 OCX detected — installing via ocx...${NC}"
  if [ "$TARGET" = "global" ]; then
    ocx registry add data-engineer "$REGISTRY_URL" --global 2>/dev/null || true
    ocx add data-engineer/commands --global
    ocx add data-engineer/skills --global
  else
    ocx init 2>/dev/null || true
    ocx registry add data-engineer "$REGISTRY_URL" 2>/dev/null || true
    ocx add data-engineer/commands
    ocx add data-engineer/skills
  fi
  echo -e "${GREEN}✅ Installed via OCX!${NC}"
}

install_via_curl() {
  echo -e "${YELLOW}📦 OCX not found — installing via curl (direct copy)${NC}"
  echo -e "${YELLOW}   Install OCX for better update management: curl -fsSL https://ocx.kdco.dev/install.sh | sh${NC}"
  echo ""

  mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR"

  echo -e "${CYAN}Downloading commands...${NC}"
  for cmd in analyze commit data_investigation execute jira_action jira_review project_resolver repo_apply review solve test typecheck; do
    url="$BASE_URL/commands/$cmd.md"
    dest="$COMMANDS_DIR/$cmd.md"
    echo "  → $cmd.md"
    curl -sfL "$url" -o "$dest" || echo -e "  ${YELLOW}⚠  Failed: $cmd.md${NC}"
  done

  echo -e "${CYAN}Downloading skills...${NC}"
  for skill_file in caveman/SKILL.md context7/SKILL.md context7/library-registry.md; do
    url="$BASE_URL/skills/$skill_file"
    dest="$SKILLS_DIR/$skill_file"
    mkdir -p "$(dirname "$dest")"
    echo "  → $skill_file"
    curl -sfL "$url" -o "$dest" || echo -e "  ${YELLOW}⚠  Failed: $skill_file${NC}"
  done

  echo ""
  echo -e "${GREEN}✅ Installed successfully!${NC}"

  if [ "$TARGET" = "project" ]; then
    echo ""
    echo -e "${YELLOW}   OpenCode'u projende başlat: opencode${NC}"
    echo -e "${YELLOW}   Kullanılabilir komutlar:${NC}"
    echo -e "${YELLOW}   /analyze  /commit  /data_investigation  /execute${NC}"
    echo -e "${YELLOW}   /jira_action  /jira_review  /project_resolver${NC}"
    echo -e "${YELLOW}   /repo_apply  /review  /solve  /test  /typecheck${NC}"
  fi
}

if [ "$USE_OCX" = true ]; then
  install_via_ocx
else
  install_via_curl
fi

echo ""
echo -e "${CYAN}📖 Docs: https://github.com/$REPO${NC}"
echo -e "${CYAN}⭐ Star the repo if you find it useful!${NC}"
