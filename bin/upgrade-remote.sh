#!/usr/bin/env bash
# ==============================================================================
# Script para Actualizar HyCanvas Remoto en Hetzner desde tu Maquina Local
# Uso: ./bin/upgrade-remote.sh [IP_DEL_SERVIDOR] [SSH_USER]
# ==============================================================================
set -e

HOST="${1:-5.161.237.189}"
USER="${2:-root}"
REMOTE_DIR="/opt/hycanvas"

echo "=== [HYCANVAS] DISPARANDO ACTUALIZACION REMOTA EN HETZNER ($HOST) ==="

ssh "${USER}@${HOST}" "
    cd ${REMOTE_DIR}
    ./upgrade.sh
"

echo "=== [HYCANVAS] SERVIDOR HETZNER ACTUALIZADO EXITOSAMENTE ==="
