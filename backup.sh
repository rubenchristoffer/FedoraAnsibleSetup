#!/bin/bash
# backup.sh — run the Borg backup playbook (backup.yml)
#
# Prerequisites:
#   Run generateBackupList.sh first to create vars/backup_list.yml.
#
# Usage:
#   ./backup.sh                 # read user from vars/backup_list.yml
#   -h, --help                  Show this help

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PLAYBOOK="$DIR/backup.yml"
BACKUP_LIST="$DIR/vars/backup_list.yml"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage:
  $0          Run backup using vars/backup_list.yml

Prerequisite:
  Run ./generateBackupList.sh first to generate vars/backup_list.yml.
  See ./restore.sh for restoring a backup.
EOF
  exit 0
fi

# ─── Sanity check ─────────────────────────────────────────────────────────────

if [[ ! -f "$BACKUP_LIST" ]]; then
  echo "ERROR: $BACKUP_LIST does not exist." >&2
  echo "  Run ./generateBackupList.sh first to scan this machine and generate the list." >&2
  exit 1
fi

# ─── Run ──────────────────────────────────────────────────────────────────────

echo "════════════════════════════════════════════════"
echo "  BACKUP"
echo "  List file : ${BACKUP_LIST}"
echo "════════════════════════════════════════════════"
echo ""

sudo ansible-playbook "$PLAYBOOK"
