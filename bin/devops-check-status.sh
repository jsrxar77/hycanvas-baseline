#!/usr/bin/env bash
# ==============================================================================
# HYCANVAS - VERIFICAR ESTADO DEL SERVICIO (LOCAL O REMOTO)
# ==============================================================================
set -e

TARGET="${1:-all}"
SERVER_IP="5.161.237.189"
SERVER_USER="root"

echo "======================================================"
echo "[+] HyCanvas: Verificacion de Estado y Salud"
echo "======================================================"

if [ "$TARGET" == "all" ] || [ "$TARGET" == "local" ]; then
    echo ""
    echo "--- 🖥️ Entorno Local (Docker) ---"
    docker compose ps
    echo -n "Health Check local (:8088): "
    curl -s http://localhost:8088/healthz || echo "Error"
    echo ""
fi

if [ "$TARGET" == "all" ] || [ "$TARGET" == "remote" ] || [ "$TARGET" == "hetzner" ]; then
    echo ""
    echo "--- ☁️ Servidor Hetzner ($SERVER_IP) ---"
    ssh "$SERVER_USER@$SERVER_IP" "
        cd /opt/hycanvas 2>/dev/null && docker compose ps
        echo -n 'Health Check interno Hetzner (:8088): '
        curl -s http://localhost:8088/healthz || echo 'Error'
        echo ''
    "
fi

echo ""
echo "--- 🌐 Dominio Publico (https://hycanvas.holospace.com.ar) ---"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" https://hycanvas.holospace.com.ar/healthz
echo -n "Respuesta Healthz Publica: "
curl -s https://hycanvas.holospace.com.ar/healthz
echo ""
echo "======================================================"
