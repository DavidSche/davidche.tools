#!/usr/bin/env bash
set -eou pipefail

PUBLIC_KEY_FILE=/run/secrets/public_key
OUTPUT_FOLDER=/tmp/backup
OUTPUT_FILE="${OUTPUT_FOLDER}/backup_$(date +%u).sql.gpg"

if [[ -z "${RCLONE_TARGET:-}" ]]; then
  >&2 echo "Error – need RCLONE_TARGET"
  exit 1
fi

public_key="$(gpg --status-fd=1 --import "${PUBLIC_KEY_FILE}" | head -n1 | awk '{print $3}')"
echo -e "5\ny\n" | gpg --no-tty --command-fd 0 --expert --edit-key "${public_key}" trust

>&2 echo Imported public key: "${public_key}"

>&2 echo Starting backup..

mkdir "$OUTPUT_FOLDER"

set +e
(pg_dump "$DATABASE_URL" | gpg --no-tty --encrypt -r "${public_key}" --output "$OUTPUT_FILE") 2>&1 | tee /tmp/error_output
rc=$?
set -e

if [[ "$rc" == 0 ]]; then
  >&2 echo "Backup successful."
  ls -hl "${OUTPUT_FOLDER}"

  set +e
  rclone copy "${OUTPUT_FILE}" "${RCLONE_TARGET}" 2>&1 | tee /tmp/error_output
  rc=$?
  set -e

  if [[ "$rc" == 0 ]]; then
    >&2 echo "Upload successful."

    if [[ -n "${HEALTHCHECKS_URL:-}" ]]; then
      curl -fsS -m 10 --retry 5 "${HEALTHCHECKS_URL}"
    fi
  else
    >&2 echo "Upload failed!"
    curl -fsS -m 10 --retry 5 -d @/tmp/error_output "${HEALTHCHECKS_URL}/fail"
    exit $rc
  fi
else
  >&2 echo "Backup failed!"
  curl -fsS -m 10 --retry 5 -d @/tmp/error_output "${HEALTHCHECKS_URL}/fail"
  exit $rc
fi