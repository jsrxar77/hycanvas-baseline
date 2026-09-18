#!/usr/bin/env bash
# ==============================================================================
# HYCANVAS - ACTUALIZAR A LA ULTIMA VERSION OFICIAL UPSTREAM
# Alcance: Local o Remoto en Hetzner
# ==============================================================================
set -e

TARGET="${1:-local}"
SERVER_IP="5.161.237.189"
SERVER_USER="root"
REMOTE_DIR="/opt/hycanvas"

echo "======================================================"
echo "[+] HyCanvas: Actualizacion a la Ultima Version"
echo "    Destino: $TARGET"
echo "======================================================"

if [ "$TARGET" == "remote" ] || [ "$TARGET" == "hetzner" ]; then
    echo "[+] Conectando con Servidor Hetzner ($SERVER_IP)..."
    ssh "$SERVER_USER@$SERVER_IP" "
        cd $REMOTE_DIR
        echo 'Descargando imagen hycanvas/hycanvas:latest...'
        docker compose pull hycanvas_app
        docker compose up -d
        echo 'Verificando estado...'
        docker compose ps
        curl -s http://localhost:8088/healthz || echo 'Iniciando...'
    "
    echo "[+] Servidor Hetzner actualizado correctamente."
else
    echo "[+] Actualizando entorno local..."
    if [ -d ".git" ]; then
        git pull origin main 2>/dev/null || true
    fi
    echo "[+] Descargando imagen hycanvas/hycanvas:latest..."
    docker compose pull hycanvas_app
    docker compose up -d
    echo "[+] Verificando estado local..."
    docker compose ps
    curl -s http://localhost:8088/healthz || echo 'Iniciando...'
    echo "[+] Entorno local actualizado correctamente."
fi

echo "======================================================"
echo "[+] Proceso completado con exito."
echo "======================================================"
