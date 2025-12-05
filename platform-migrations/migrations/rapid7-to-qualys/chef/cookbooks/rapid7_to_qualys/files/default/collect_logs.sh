#!/bin/bash
# collect_logs.sh
# Helper: collect migration logs and either upload to S3 or print archive path
# Usage: collect_logs.sh [--upload] [--bucket my-bucket] [--dest /tmp]
#
# This script is intentionally simple and safe: it will not fail the node if AWS
# credentials are missing. It writes a tar.gz archive to /tmp and optionally attempts
# to upload to S3 if awscli is configured.

set -euo pipefail

LOG_DIR="/opt/migration/logs"
STATUS_DIR="/opt/migration/status"
OUT_DIR="/tmp"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE="${OUT_DIR}/migration-logs-${TIMESTAMP}.tar.gz"
UPLOAD=false
BUCKET=""
DEST="/tmp"

# simple arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --upload) UPLOAD=true; shift ;;
    --bucket) BUCKET="$2"; shift 2 ;;
    --dest) DEST="$2"; shift 2 ;;
    *) echo "Unknown arg $1"; shift ;;
  esac
done

# create archive
tar -czf "${ARCHIVE}" -C "${LOG_DIR}" . || {
  echo "[collect_logs] failed to create archive, aborting" >&2
  exit 0
}

echo "[collect_logs] Created archive: ${ARCHIVE}"

if [ "${UPLOAD}" = true ] && [ -n "${BUCKET}" ]; then
  if command -v aws >/dev/null 2>&1; then
    echo "[collect_logs] Attempting upload to s3://${BUCKET}/"
    aws s3 cp "${ARCHIVE}" "s3://${BUCKET}/" --only-show-errors || {
      echo "[collect_logs] Upload failed or credentials missing - leaving archive locally"
    }
  else
    echo "[collect_logs] aws cli not found; cannot upload"
  fi
fi

# optional local move
if [ -d "${DEST}" ]; then
  mv "${ARCHIVE}" "${DEST}/" || true
  echo "[collect_logs] Archive moved to ${DEST}/$(basename ${ARCHIVE})"
fi

exit 0
