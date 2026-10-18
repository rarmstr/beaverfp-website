#!/usr/bin/env bash
# Tell IndexNow (Bing, Yandex, Seznam, Naver) which pages changed. Run it after
# a push is live: IndexNow verifies the request by fetching the key file from
# the site, so it has to be deployed first.
#
#   ./scripts/indexnow.sh                    # every URL in sitemap.xml
#   ./scripts/indexnow.sh /privacy /terms    # just these paths

set -euo pipefail

WEB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="beaverfp.com"
# The key is public by design; the same value is the content of /<key>.txt.
KEY="c8682c44433de06ee3d21314f26a5b0d"
KEY_URL="https://$HOST/$KEY.txt"

if [ "$(curl -fsS "$KEY_URL" 2>/dev/null)" != "$KEY" ]; then
  echo "The key file isn't live at $KEY_URL yet -- push and wait for Pages first." >&2
  exit 1
fi

if [ $# -gt 0 ]; then
  urls=()
  for path in "$@"; do urls+=("https://$HOST$path"); done
else
  urls=()
  while IFS= read -r u; do urls+=("$u"); done \
    < <(sed -n 's:.*<loc>\(.*\)</loc>.*:\1:p' "$WEB/sitemap.xml")
fi

list=$(printf '"%s",' "${urls[@]}")
body=$(printf '{"host":"%s","key":"%s","keyLocation":"%s","urlList":[%s]}' \
  "$HOST" "$KEY" "$KEY_URL" "${list%,}")

printf '  %s\n' "${urls[@]}"
status=$(curl -sS -o /dev/null -w '%{http_code}' -X POST \
  -H 'Content-Type: application/json; charset=utf-8' \
  --data "$body" https://api.indexnow.org/indexnow)
echo "IndexNow: HTTP $status (200 or 202 means accepted)"
