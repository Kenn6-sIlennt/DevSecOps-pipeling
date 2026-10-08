#!/bin/bash
# IMP-healthcheck.sh: Script untuk memeriksa kesehatan container, status kerusakan, dan kebutuhan upgrade.

echo "=== IMP-DevSecOps Container Health & Optimization Diagnostic ==="

# 1. Cek apakah container web-flask berjalan
if [ ! "$(docker ps -q -f name=web-flask)" ]; then
    echo "[CRITICAL] Container web-flask tidak berjalan atau dalam keadaan rusak (stopped/failed)."
    docker ps -a -f name=web-flask
    exit 1
fi

echo "[OK] Container web-flask sedang berjalan."

# 2. Cek Exit Code dan Restart Count
EXIT_CODE=$(docker inspect --format='{{.State.ExitCode}}' web-flask)
RESTART_COUNT=$(docker inspect --format='{{.RestartCount}}' web-flask)
HEALTH_STATUS=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' web-flask)

echo "Status Detil:"
echo " - Exit Code    : $EXIT_CODE"
echo " - Restart Count: $RESTART_COUNT"
echo " - Health Status: $HEALTH_STATUS"

if [ "$EXIT_CODE" != "0" ]; then
    echo "[ERROR] Container mengalami error (Exit Code: $EXIT_CODE)."
    exit 1
fi

if [ "$RESTART_COUNT" -gt 2 ]; then
    echo "[WARNING] Container sering melakukan restart ($RESTART_COUNT kali). Kemungkinan ada ketidakstabilan aplikasi."
fi

# 3. Cek Penggunaan Sumber Daya (CPU/Memory Optimization)
echo "Penggunaan Sumber Daya:"
docker stats web-flask --no-stream

# 4. Cek Endpoint HTTP Aplikasi
echo "Melakukan tes HTTP ke http://localhost:5000/..."
if curl -sSf http://localhost:5000/ > /dev/null; then
    echo "[SUCCESS] Aplikasi merespon dengan baik (HTTP 200 OK)."
else
    echo "[ERROR] Aplikasi gagal merespon HTTP request."
    exit 1
fi

# 5. Cek Upgrade / Paket Outdated
echo "Memeriksa paket Python yang butuh upgrade di dalam container..."
docker exec web-flask pip list --outdated || echo "Semua paket sudah up-to-date atau pip list outdated tidak didukung."

echo "=== Pemeriksaan Selesai: Container Optimal dan Aman ==="
