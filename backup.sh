#!/bin/bash
# backup.sh — wrapper for backup.yml
#
# Usage:
#   ./backup.sh                          # interactive prompts
#   ./backup.sh backup                   # backup mode, prompts for user
#   ./backup.sh backup john              # backup mode, user=john
#   ./backup.sh restore john-pc          # restore from backup named "john-pc", prompts for user
#   ./backup.sh restore john-pc john     # restore from "john-pc" as user john

set -euo pipefail

MODE="${1:-}"
RESTORE_NAME="${2:-}"
TARGET_USER="${3:-}"

PLAYBOOK="$(dirname "$0")/backup.yml"

# ─── Helpers ──────────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Usage:
  $0                                   Interactive (all prompts)
  $0 backup [user]                     Backup mode
  $0 restore <backup-name> [user]      Restore mode

Arguments:
  backup-name   The pc-id / hostname of the backup to restore from.
                Run with --list to see available backups.

Options:
  -h, --help    Show this help
  --list        List available backups on the remote (requires backup_remote_*
                variables to be set in roles/backup/defaults/main.yml)

Environment variables:
  ANSIBLE_BECOME_PASSWORD   Set sudo password non-interactively (avoids prompt)
EOF
}

# ─── Argument parsing ─────────────────────────────────────────────────────────

if [[ "${MODE}" == "-h" || "${MODE}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${MODE}" == "--list" ]]; then
  # Pull remote settings from defaults and SSH in to list available backups.
  # Quick & dirty: parse the YAML with grep rather than requiring a Python dep.
  DEFAULTS="$(dirname "$0")/roles/backup/defaults/main.yml"
  REMOTE_USER=$(grep 'backup_remote_user:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  REMOTE_HOST=$(grep 'backup_remote_host:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  REMOTE_PORT=$(grep 'backup_remote_port:' "$DEFAULTS" | head -1 | awk '{print $NF}')
  REMOTE_BASE=$(grep 'backup_remote_base_path:' "$DEFAULTS" | head -1 | awk -F'"' '{print $2}')
  echo "Available backups on ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/"
  ssh -p "${REMOTE_PORT:-22}" "${REMOTE_USER}@${REMOTE_HOST}" "ls -1 ${REMOTE_BASE}/"
  exit 0
fi

# ─── Validate mode ────────────────────────────────────────────────────────────

if [[ -n "$MODE" && "$MODE" != "backup" && "$MODE" != "restore" ]]; then
  echo "ERROR: unknown mode '${MODE}'. Expected 'backup' or 'restore'." >&2
  usage
  exit 1
fi

if [[ "$MODE" == "restore" && -z "$RESTORE_NAME" ]]; then
  echo "ERROR: restore mode requires a backup name." >&2
  echo "  Run '$0 --list' to see available backups." >&2
  usage
  exit 1
fi

# ─── Build extra-vars string ──────────────────────────────────────────────────

EXTRA_VARS=()

if [[ -n "$MODE" ]]; then
  EXTRA_VARS+=("backup_mode=${MODE}")
fi

if [[ -n "$RESTORE_NAME" ]]; then
  EXTRA_VARS+=("backup_restore_name=${RESTORE_NAME}")
fi

if [[ -n "$TARGET_USER" ]]; then
  EXTRA_VARS+=("user=${TARGET_USER}")
fi

EXTRA_ARGS=()
if [[ ${#EXTRA_VARS[@]} -gt 0 ]]; then
  # Join array elements with space into a single -e string
  JOINED=$(IFS=' ' ; echo "${EXTRA_VARS[*]}")
  EXTRA_ARGS=(-e "$JOINED")
fi

# ─── Run ─────────────────────────────────────────────────────────────────────

echo "========================================"
if [[ -n "$MODE" ]]; then
  echo "  Mode       : ${MODE^^}"
else
  echo "  Mode       : (interactive prompt)"
fi
if [[ -n "$RESTORE_NAME" ]]; then
  echo "  Restore ID : ${RESTORE_NAME}"
fi
if [[ -n "$TARGET_USER" ]]; then
  echo "  User       : ${TARGET_USER}"
fi
echo "========================================"
echo ""

sudo ansible-playbook "$PLAYBOOK" "${EXTRA_ARGS[@]}" "$@"
