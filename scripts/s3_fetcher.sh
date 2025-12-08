#!/usr/bin/env sh

set -euo pipefail

: "${EODATA_QUERY_URL:?EODATA_QUERY_URL is required}"

mkdir -p /work

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

curl -fsSL "$EODATA_QUERY_URL" |
  jq -r '.value[]?.S3Path // empty' |
  sort -u >"$TMP"

if [ ! -s "$TMP" ]; then
  echo "No s3:// entries found from EODATA_QUERY_URL" >&2
  exit 1
fi

mv "$TMP" /work/s3_paths.txt
COUNT="$(wc -l </work/s3_paths.txt | tr -d ' ')"
echo "Saved ${COUNT} s3 path(s) to /work/s3_paths.txt"
