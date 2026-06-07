#!/bin/bash
# generateBackupList.sh — scan this machine and write vars/backup_list.yml
#
# Usage:
#   ./generateBackupList.sh              # interactive (prompts for username)
#   ./generateBackupList.sh john         # skip prompt, use user=john

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PLAYBOOK="$DIR/generate_backup_list.yml"
TARGET_USER="${1:-}"

EXTRA_ARGS=()
if [[ -n "$TARGET_USER" ]]; then
  EXTRA_ARGS+=(-e "user=${TARGET_USER}")
fi

echo "════════════════════════════════════════════════"
echo "  GENERATE BACKUP LIST"
echo "════════════════════════════════════════════════"
echo ""

ansible-playbook "$PLAYBOOK" "${EXTRA_ARGS[@]}"
