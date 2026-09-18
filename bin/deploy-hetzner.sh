#!/usr/bin/env bash
# ==============================================================================
# Script de Despliegue en Servidor Hetzner
# Uso: ./deploy-hetzner.sh <IP_DEL_SERVIDOR_HETZNER> [SSH_USER]
# ==============================================================================
set -e

HOST="${1}"
USER="${2:-root}"
REMOTE_DIR="/opt/hycanvas"

if [ -z "$HOST" ]; then
    echo "Uso: ./deploy-hetzner.sh <IP_DEL_SERVIDOR> [SSH_USER]"
    echo "Ejemplo: ./deploy-hetzner.sh 159.69.x.x root"
    exit 1
fi

echo "[+] Sincronizando configuraciones locales a ${USER}@${HOST}:${REMOTE_DIR}..."
ssh "${USER}@${HOST}" "mkdir -p ${REMOTE_DIR}/data/storage ${REMOTE_DIR}/nginx"

# Copiar archivos base
scp docker-compose.yml "${USER}@${HOST}:${REMOTE_DIR}/"
scp .env "${USER}@${HOST}:${REMOTE_DIR}/"
scp upgrade.sh "${USER}@${HOST}:${REMOTE_DIR}/"
scp nginx/hycanvas.holospace.com.ar.conf "${USER}@${HOST}:${REMOTE_DIR}/nginx/"

echo "[+] Configurando Nginx en el host remoto..."
ssh "${USER}@${HOST}" "
    cp ${REMOTE_DIR}/nginx/hycanvas.holospace.com.ar.conf /etc/nginx/sites-available/hycanvas.holospace.com.ar
    ln -sf /etc/nginx/sites-available/hycanvas.holospace.com.ar /etc/nginx/sites-enabled/
    nginx -t && systemctl reload nginx
"

echo "[+] Iniciando contenedores en el host remoto..."
ssh "${USER}@${HOST}" "
    cd ${REMOTE_DIR}
    chmod +x upgrade.sh
    docker compose up -d
"

echo "[+] Despliegue completado."
echo "Recordatorio SSL: ejecute en el servidor remoto: certbot --nginx -d hycanvas.holospace.com.ar"
