#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

docker compose pull
docker compose up -d --remove-orphans
docker compose exec -T nginx nginx -t
docker compose exec -T nginx nginx -s reload

for app in shop school solar; do
  code=000
  for i in $(seq 1 36); do
    code=$(curl -s -L -o /dev/null -w '%{http_code}' "http://localhost/$app/swagger-ui.html" || true)
    [ "$code" = 200 ] && break
    sleep 5
  done
  if [ "$code" != 200 ]; then
    echo "$app nu raspunde (ultimul cod: $code)"
    docker compose logs --tail 50 "$app"
    exit 1
  fi
  echo "$app OK"
done

docker image prune -f
