#!/usr/bin/env bash
# ==============================================================================
# Script de Actualizacion Desatendida de HyCanvas
# ==============================================================================
set -e

echo "[+] Verificando Docker y Compose..."
if ! command -v docker &> /dev/null; then
    echo "Error: docker no esta instalado o no se encuentra en el PATH."
    exit 1
fi

echo "[+] Descargando la version mas reciente de la imagen oficial de HyCanvas..."
docker compose pull hycanvas_app

echo "[+] Recreando contenedores con la nueva version..."
docker compose up -d

echo "[+] Estado de los servicios:"
docker compose ps

echo "[+] HyCanvas actualizado exitosamente."
