#!/bin/bash
# restore.sh — restore a Borg backup to this machine
#
# Usage:
#   ./restore.sh                                      # interactive (all prompts)
#   ./restore.sh <backup-name>                        # prompts for user
#   ./restore.sh <backup-name> <user>                 # prompts for archive
#   ./restore.sh <backup-name> <user> <archive>       # fully non-interactive
#
# backup-name   The pc-id / hostname of the backup to restore (e.g. "john-pc").
#               Run with --list to see available backups.
# user          Linux username to restore TO on this machine.
# archive       Exact archive name, or 'latest' (default).
#
# Options:
#   -h, --help    Show this help
#   --list        List available backups on the remote

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PLAYBOOK="$DIR/restore.yml"

RESTORE_NAME="${1:-}"
TARGET_USER="${2:-}"
ARCHIVE="${3:-}"

# ─── Help ─────────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage:
  $0                                     Interactive (all prompts)
  $0 <backup-name>                       Restore from named backup
  $0 <backup-name> <user>               Restore to specific user
  $0 <backup-name> <user> <archive>     Fully non-interactive

Options:
  --list        List available backups on the remote
  -h, --help    Show this help
EOF
}

if [[ "${RESTORE_NAME}" == "-h" || "${RESTORE_NAME}" == "--help" ]]; then
  usage; exit 0
fi

if [[ "${RESTORE_NAME}" == "--list" ]]; then
  DEFAULTS="$DIR/roles/backup/defaults/main.yml"
  REMOTE_USER=$(grep 'backup_remote_user:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  REMOTE_HOST=$(grep 'backup_remote_host:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  REMOTE_PORT=$(grep 'backup_remote_port:' "$DEFAULTS" | head -1 | awk '{print $NF}')
  REMOTE_BASE=$(grep 'backup_remote_base_path:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  echo "Available backups on ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/"
  ssh -p "${REMOTE_PORT:-22}" "${REMOTE_USER}@${REMOTE_HOST}" "ls -1 ${REMOTE_BASE}/"
  exit 0
fi

# ─── Build extra-vars ─────────────────────────────────────────────────────────

EXTRA_VARS=()
[[ -n "$RESTORE_NAME" ]] && EXTRA_VARS+=("backup_restore_name=${RESTORE_NAME}")
[[ -n "$TARGET_USER"  ]] && EXTRA_VARS+=("user=${TARGET_USER}")
[[ -n "$ARCHIVE"      ]] && EXTRA_VARS+=("backup_restore_archive=${ARCHIVE}")

EXTRA_ARGS=()
if [[ ${#EXTRA_VARS[@]} -gt 0 ]]; then
  EXTRA_ARGS=(-e "$(IFS=' '; echo "${EXTRA_VARS[*]}")")
fi

# ─── Run ──────────────────────────────────────────────────────────────────────

echo "════════════════════════════════════════════════"
echo "  RESTORE"
[[ -n "$RESTORE_NAME" ]] && echo "  Backup     : ${RESTORE_NAME}"
[[ -n "$TARGET_USER"  ]] && echo "  User       : ${TARGET_USER}"
[[ -n "$ARCHIVE"      ]] && echo "  Archive    : ${ARCHIVE}"
echo "════════════════════════════════════════════════"
echo ""

sudo ansible-playbook "$PLAYBOOK" "${EXTRA_ARGS[@]}" "$@"
