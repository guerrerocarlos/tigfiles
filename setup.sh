#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_PATH="$REPO_DIR/tigrc.template"
CURRENT_PATH="$REPO_DIR/tigrc.current"
TARGET_PATH="${HOME}/.tigrc"
MODE="template"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--current]

Options:
  --current   Install tigrc.current exactly as committed in the repo.
              Default behavior installs tigrc.template with an auto-detected
              diff-highlight path for the local machine.
EOF
}

find_diff_highlight() {
  if command -v diff-highlight >/dev/null 2>&1; then
    command -v diff-highlight
    return 0
  fi

  local candidates=()

  case "$(uname -s)" in
    Darwin)
      candidates+=(
        "/opt/homebrew/share/git-core/contrib/diff-highlight/diff-highlight"
        "/opt/homebrew/opt/git/share/git-core/contrib/diff-highlight/diff-highlight"
        "/usr/local/share/git-core/contrib/diff-highlight/diff-highlight"
        "/usr/local/opt/git/share/git-core/contrib/diff-highlight/diff-highlight"
      )
      ;;
    Linux)
      candidates+=(
        "/usr/share/doc/git/contrib/diff-highlight/diff-highlight"
        "/usr/share/git-core/contrib/diff-highlight/diff-highlight"
        "/usr/local/share/git-core/contrib/diff-highlight/diff-highlight"
      )
      ;;
  esac

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

while (($# > 0)); do
  case "$1" in
    --current)
      MODE="current"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "unknown argument: $1"
      ;;
  esac
done

if [[ -f "$TARGET_PATH" ]]; then
  BACKUP_PATH="${TARGET_PATH}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$TARGET_PATH" "$BACKUP_PATH"
  log "Backed up existing ~/.tigrc to $BACKUP_PATH"
fi

if [[ "$MODE" == "current" ]]; then
  [[ -f "$CURRENT_PATH" ]] || fail "missing current config: $CURRENT_PATH"
  cp "$CURRENT_PATH" "$TARGET_PATH"
  log "Installed ~/.tigrc from tigrc.current"
  exit 0
fi

[[ -f "$TEMPLATE_PATH" ]] || fail "missing template: $TEMPLATE_PATH"

DIFF_HIGHLIGHT_PATH="$(find_diff_highlight)" || fail "could not find diff-highlight. Install Git with contrib tools, then rerun this script."

sed "s|__DIFF_HIGHLIGHT__|$DIFF_HIGHLIGHT_PATH|g" "$TEMPLATE_PATH" > "$TARGET_PATH"

log "Installed ~/.tigrc"
log "Using diff-highlight at: $DIFF_HIGHLIGHT_PATH"
