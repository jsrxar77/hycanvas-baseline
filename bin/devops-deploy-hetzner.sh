#!/usr/bin/env bash
# ==============================================================================
# HYCANVAS - DESPLEGAR / REPLICAR A HETZNER
# ==============================================================================
set -e

SERVER_IP="5.161.237.189"
SERVER_USER="root"
REMOTE_DIR="/opt/hycanvas"

echo "======================================================"
echo "[+] Desplegando replica HyCanvas en Hetzner ($SERVER_IP)..."
echo "======================================================"

ssh "$SERVER_USER@$SERVER_IP" "mkdir -p $REMOTE_DIR/data/storage $REMOTE_DIR/nginx $REMOTE_DIR/bin"

echo "[+] Sincronizando archivos base y variables de entorno..."
scp docker-compose.yml "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
scp .env "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
scp .env.example "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
scp upgrade.sh "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/"
scp bin/devops-upgrade-hycanvas.sh "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/bin/"
scp nginx/hycanvas.holospace.com.ar.conf "$SERVER_USER@$SERVER_IP:$REMOTE_DIR/nginx/"

echo "[+] Levantando servicios en Hetzner..."
ssh "$SERVER_USER@$SERVER_IP" "
    cd $REMOTE_DIR
    chmod +x upgrade.sh bin/devops-upgrade-hycanvas.sh
    docker compose up -d
    docker network connect hycanvas_network proxy-manager 2>/dev/null || true
    docker compose ps
"

echo "======================================================"
echo "[+] Despliegue en Hetzner finalizado con exito."
echo "======================================================"
