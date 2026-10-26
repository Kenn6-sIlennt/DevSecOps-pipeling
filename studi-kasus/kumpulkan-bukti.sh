#!/usr/bin/env bash
# Opsional: unduh log GitHub Actions per branch skenario ke studi-kasus/bukti/logs/
# Butuh GitHub CLI (gh) yang sudah login: gh auth login
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
mkdir -p studi-kasus/bukti/logs
for b in case/g1-sqli case/g2-pylint case/g3-dependency case/g4-runtime-crash case/s2-new-routes; do
  echo "== $b"
  gh run list --branch "$b" --limit 5 --json databaseId,conclusion,event,headSha,createdAt \
    --jq '.[] | [.databaseId,.conclusion,.event,.headSha[0:7],.createdAt] | @tsv' \
    | tee "studi-kasus/bukti/logs/$(echo "$b" | tr '/' '-')-ringkasan.tsv"
  for id in $(gh run list --branch "$b" --limit 5 --json databaseId --jq '.[].databaseId'); do
    gh run view "$id" --log > "studi-kasus/bukti/logs/$(echo "$b" | tr '/' '-')-run-$id.log" 2>/dev/null || true
  done
done
echo "Selesai. Log tersimpan di studi-kasus/bukti/logs/"
