#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-all}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

install_one() {
  local dst_root="$1"
  local dst="${dst_root}/mission-ops"
  mkdir -p "${dst_root}"
  rm -rf "${dst}"
  cp -R "${SRC_DIR}" "${dst}"
  rm -rf "${dst}/.git"
  echo "Installed mission-ops to ${dst}"
}

case "${TARGET}" in
  codex)
    install_one "${HOME}/.codex/skills"
    ;;
  claude)
    install_one "${HOME}/.claude/skills"
    ;;
  cursor)
    install_one "${HOME}/.cursor/skills"
    ;;
  both|all)
    install_one "${HOME}/.codex/skills"
    install_one "${HOME}/.claude/skills"
    install_one "${HOME}/.cursor/skills"
    ;;
  *)
    echo "Usage: $0 [codex|claude|cursor|both|all]" >&2
    exit 1
    ;;
esac
