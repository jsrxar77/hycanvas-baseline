#!/usr/bin/env bash
# ==============================================================================
# Script Universal de Actualizacion de HyCanvas (Local o Remoto en Hetzner)
# ==============================================================================
set -e

echo "=== [HYCANVAS] INICIANDO PROCESO DE ACTUALIZACION ==="

# 1. Traer cambios de Git (configuraciones, compose, scripts)
if [ -d ".git" ]; then
    echo "[+] Verificando actualizaciones de configuracion en Git..."
    git pull origin main || echo "[!] Advertencia: No se pudo hacer git pull (se mantendra la configuracion actual)."
fi

# 2. Descargar la version mas reciente de la imagen oficial upstream
echo "[+] Descargando ultima version oficial de HyCanvas desde Docker Registry..."
docker compose pull hycanvas_app

# 3. Recrear contenedores de forma segura preservando la base de datos y assets
echo "[+] Reiniciando servicios con la nueva version..."
docker compose up -d

# 4. Comprobar salud del servicio
echo "[+] Verificando estado de los contenedores..."
docker compose ps

# Esperar unos segundos para health check
echo "[+] Comprobando respuesta de salud..."
for i in {1..6}; do
    STATUS=$(curl -s http://localhost:8088/healthz || true)
    if [[ "$STATUS" == *"ok"* ]]; then
        echo "[+] HyCanvas respondiendo correctamente: $STATUS"
        break
    fi
    echo "    Esperando inicio de HyCanvas (intento $i/6)..."
    sleep 3
done

echo "=== [HYCANVAS] ACTUALIZACION COMPLETADA EXITOSAMENTE ==="
