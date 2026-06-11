#!/usr/bin/env bash
# data-engineer installer — opencode + Devin CLI support
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
echo -e "${CYAN}║   Data Engineer — Pack Installer         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# --- Detect CLI ---
if command -v devin &>/dev/null; then
  DETECTED_CLI="devin"
elif [ -d "$HOME/.codeium/windsurf" ]; then
  DETECTED_CLI="devin"
elif command -v opencode &>/dev/null; then
  DETECTED_CLI="opencode"
else
  DETECTED_CLI="opencode"
fi

# --- Detect Windsurf base dir ---
detect_windsurf_dir() {
  local paths=(
    "$HOME/.codeium/windsurf"
    "$HOME/.codeium/windsurf-next"
    "$HOME/.codeium/windsurf-insiders"
    "$HOME/.config/devin"
  )
  for p in "${paths[@]}"; do
    if [ -d "$p" ]; then
      echo "$p"
      return
    fi
  done
  echo "$HOME/.codeium/windsurf"
}

# --- Parse args ---
CLI="$DETECTED_CLI"
TARGET="global"
while [[ $# -gt 0 ]]; do
  case $1 in
    --global) TARGET="global" ;;
    --project) TARGET="project" ;;
    --opencode) CLI="opencode" ;;
    --devin|--windsurf) CLI="devin" ;;
    --help|-h)
      echo "Usage: install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --opencode    Install for opencode (default if opencode detected)"
      echo "  --devin       Install for Devin/Windsurf CLI"
      echo "  --windsurf    Same as --devin"
      echo "  --global      Install globally (default)"
      echo "  --project     Install in current project only"
      echo "  --help, -h    Show this help"
      echo ""
      echo "Auto-detection: Devin/Windsurf CLI > opencode"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
  shift
done

# --- Install opencode ---
install_opencode() {
  if [ "$TARGET" = "global" ]; then
    COMMANDS_DIR="$HOME/.config/opencode/commands"
    SKILLS_DIR="$HOME/.config/opencode/skills"
    echo -e "${GREEN}→ Installing for opencode (global — ~/.config/opencode/)${NC}"
  else
    PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    COMMANDS_DIR="$PROJECT_ROOT/.opencode/commands"
    SKILLS_DIR="$PROJECT_ROOT/.opencode/skills"
    echo -e "${GREEN}→ Installing for opencode (project — $PROJECT_ROOT/.opencode/)${NC}"
  fi

  # OCX mode
  if command -v ocx &>/dev/null; then
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
    return
  fi

  # curl mode
  echo -e "${YELLOW}📦 Installing via curl (direct copy)${NC}"
  mkdir -p "$COMMANDS_DIR" "$SKILLS_DIR"

  echo -e "${CYAN}Downloading commands...${NC}"
  for cmd in analyze execute investigate jira repo review; do
    curl -sfL "$BASE_URL/commands/$cmd.md" -o "$COMMANDS_DIR/$cmd.md" \
      && echo "  → $cmd.md" \
      || echo -e "  ${YELLOW}⚠  Failed: $cmd.md${NC}"
  done

  echo -e "${CYAN}Downloading skills...${NC}"
  for skill_file in caveman/SKILL.md context7/SKILL.md context7/library-registry.md; do
    mkdir -p "$SKILLS_DIR/$(dirname "$skill_file")"
    curl -sfL "$BASE_URL/skills/$skill_file" -o "$SKILLS_DIR/$skill_file" \
      && echo "  → $skill_file" \
      || echo -e "  ${YELLOW}⚠  Failed: $skill_file${NC}"
  done

  echo -e "${GREEN}✅ Installed for opencode!${NC}"
  if [ "$TARGET" = "project" ]; then
    echo -e "${YELLOW}   Start: opencode${NC}"
    echo -e "${YELLOW}   Commands: /analyze /execute /investigate /jira /repo /review${NC}"
  fi
}

# --- Install Windsurf/Devin ---
install_devin() {
  if [ "$TARGET" = "global" ]; then
    WINDSURF_DIR="$(detect_windsurf_dir)"
    WORKFLOWS_DIR="$WINDSURF_DIR/global_workflows"
    SKILLS_DIR="$WINDSURF_DIR/skills"
    echo -e "${GREEN}→ Installing for Windsurf/Devin (global — $WINDSURF_DIR)${NC}"
  else
    PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
    WORKFLOWS_DIR="$PROJECT_ROOT/.devin/workflows"
    SKILLS_DIR="$PROJECT_ROOT/.devin/skills"
    echo -e "${GREEN}→ Installing for Windsurf/Devin (project — $PROJECT_ROOT/.devin/)${NC}"
  fi

  echo -e "${CYAN}Downloading workflows...${NC}"
  for cmd in analyze execute investigate jira repo review; do
    curl -sfL "$BASE_URL/devin-workflows/$cmd.md" -o "$WORKFLOWS_DIR/$cmd.md" \
      && echo "  → global_workflows/$cmd.md" \
      || echo -e "  ${YELLOW}⚠  Failed: $cmd.md${NC}"
  done

  echo -e "${CYAN}Downloading skills...${NC}"
  for skill in caveman context7; do
    dest="$SKILLS_DIR/$skill"
    mkdir -p "$dest"
    if [ "$skill" = "context7" ]; then
      curl -sfL "$BASE_URL/skills/context7/SKILL.md" -o "$dest/SKILL.md" \
        && echo "  → skills/$skill/SKILL.md" \
        || echo -e "  ${YELLOW}⚠  Failed: $skill/SKILL.md${NC}"
    else
      curl -sfL "$BASE_URL/skills/$skill/SKILL.md" -o "$dest/SKILL.md" \
        && echo "  → skills/$skill/SKILL.md" \
        || echo -e "  ${YELLOW}⚠  Failed: $skill/SKILL.md${NC}"
    fi
  done

  echo ""
  echo -e "${GREEN}✅ Installed for Windsurf/Devin CLI!${NC}"
  echo -e "${YELLOW}   Workflows: /analyze /execute /investigate /jira /repo /review${NC}"
  echo -e "${YELLOW}   Skills: caveman, context7${NC}"
}

# --- Run ---
if [ "$CLI" = "devin" ]; then
  install_devin
else
  install_opencode
fi

echo ""
echo -e "${CYAN}📖 Docs: https://github.com/$REPO${NC}"
echo -e "${CYAN}⭐ Star the repo if you find it useful!${NC}"
