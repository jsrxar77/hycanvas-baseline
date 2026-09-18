#!/usr/bin/env bash
# ==============================================================================
# Script de Despliegue y Sincronizacion Directa a Hetzner
# Uso: ./bin/deploy-hetzner.sh [IP_DEL_SERVIDOR] [SSH_USER]
# ==============================================================================
set -e

HOST="${1:-5.161.237.189}"
USER="${2:-root}"
REMOTE_DIR="/opt/hycanvas"

echo "=== [HYCANVAS] DESPLEGANDO EN SERVIDOR HETZNER ($HOST) ==="

# 1. Crear estructura remota
echo "[+] Preparando directorios en servidor remoto..."
ssh "${USER}@${HOST}" "mkdir -p ${REMOTE_DIR}/data/storage ${REMOTE_DIR}/nginx ${REMOTE_DIR}/bin"

# 2. Sincronizar archivos esenciales y secretos
echo "[+] Sincronizando configuracion y secretos..."
scp docker-compose.yml "${USER}@${HOST}:${REMOTE_DIR}/"
scp .env "${USER}@${HOST}:${REMOTE_DIR}/"
scp .env.example "${USER}@${HOST}:${REMOTE_DIR}/"
scp upgrade.sh "${USER}@${HOST}:${REMOTE_DIR}/"
scp nginx/hycanvas.holospace.com.ar.conf "${USER}@${HOST}:${REMOTE_DIR}/nginx/"

# 3. Dar permisos y levantar contenedores en Hetzner
echo "[+] Levantando servicios Docker en Hetzner..."
ssh "${USER}@${HOST}" "
    cd ${REMOTE_DIR}
    chmod +x upgrade.sh
    docker compose up -d
"

# 4. Verificar ejecucion remota
echo "[+] Comprobando servicios remotos..."
ssh "${USER}@${HOST}" "
    cd ${REMOTE_DIR}
    docker compose ps
    curl -s http://localhost:8088/healthz || echo 'Iniciando...'
"

echo "=== [HYCANVAS] DESPLIEGUE EN HETZNER COMPLETADO ==="
echo ""
echo "Acceso y Proxy:"
echo "1. El puerto 8088 esta escuchando en Hetzner para HyCanvas."
echo "2. En Nginx Proxy Manager (http://5.161.237.189:81):"
echo "   - Domain Names: hycanvas.holospace.com.ar"
echo "   - Forward Hostname / IP: 172.17.0.1 (o IP de host)"
echo "   - Forward Port: 8088"
echo "   - WebSockets Support: ON"
echo "   - SSL: Request a new SSL Certificate (Let's Encrypt)"
