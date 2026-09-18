# Handover: Integracion y Despliegue de HyCanvas Baseline

> **Documento de Traspaso Operativo (Handover):** Este documento sintetiza el contexto, los requerimientos, las decisiones arquitectonicas y los pasos de ejecucion para que el agente que opere en el workspace `hycanvas-baseline` pueda iniciar las tareas de inmediato y sin perdida de contexto.

---

## 1. Contexto y Mision del Proyecto

- **Nombre del Proyecto:** `hycanvas-baseline`
- **Objetivo Central:** Desplegar y mantener una instancia de **HyCanvas** (la plataforma open-source de diseno alternativo a Canva desarrollada por HyScaler) bajo el subdominio oficial:
  ```text
  hycanvas.holospace.com.ar
  ```
- **Repositorio Oficial Upstream:** [github.com/hyscaler/HyCanvas](https://github.com/hyscaler/HyCanvas)
- **Licencia:** Elastic License 2.0 (permite self-hosting, uso interno y modificaciones, prohibiendo ofrecerlo como servicio gestionado a terceros).

---

## 2. Decision Arquitectonica: Proyecto Satelite Aislado

Se acordo con el usuario que HyCanvas resida en su propio directorio/repositorio (`/Users/javier/Projects/hycanvas-baseline` en local, y `/opt/hycanvas` o equivalente en el servidor Hetzner) para garantizar:
1. **Actualizaciones Limpias:** Capacidad de bajar la ultima version oficial upstream de HyCanvas (`docker compose pull && docker compose up -d` o `git pull`) sin generar conflictos de Git, codigo ni dependencias con `holospace-baseline`.
2. **Aislamiento Docker:** Base de datos Postgres propia, almacenamiento persistente de assets en `./data/storage` y puerto independiente (ej. `8088`), evitando colisiones con los puertos de HoloSpace (App: 3001, Postgres: 5434, Redis: 6379, Expo: 8081).
3. **Integracion Externa:** Ruteo mediante Nginx reverse proxy en el host hacia `hycanvas.holospace.com.ar` con SSL (Certbot / Let's Encrypt).

---

## 3. Estructura Inicial Configurada en `hycanvas-baseline`

En este directorio se dejaron preparados:
- `.agents/AGENTS.md`: Reglas canonicas del agente (prohibido inventar datos, cero emojis en logs/UI, cero credenciales hardcodeadas, prioridad Docker).
- `.agents/mcp_config.json`: Configuracion de MCP servers.
- `.agents/skills/`: Todas las skills especializadas de HoloSpace (deploy Docker, CRUD, temas, arquitectura, testing).
- `docs/`: Los 6 documentos canonicos heredados de HoloSpace para mantener la disciplina tecnica y coherencia de arquitectura.

---

## 4. Proximos Pasos Inmediatos para el Agente en `hycanvas-baseline`

El nuevo agente debe ejecutar las siguientes fases:

1. **Clonado / Configuracion de HyCanvas:**
   - Clonar o configurar el `docker-compose.yml` oficial de HyCanvas con sus variables de entorno recomendadas:
     ```env
     JWT_SECRET=<generar-secreto-seguro>
     APP_PORT=8088
     DATABASE_URL=postgresql://hycanvas_user:hycanvas_pass@postgres:5432/hycanvas_db
     ```
2. **Persistencia de Datos:**
   - Asegurar el mapeo de `./data/storage` para los disenos y assets subidos.
3. **Script de Actualizacion Facil (`upgrade.sh`):**
   - Crear un script ejecutable para que el usuario pueda actualizar a la ultima version en un solo comando:
     ```bash
     #!/usr/bin/env bash
     echo "Descargando ultima version de HyCanvas..."
     docker compose pull
     docker compose up -d
     echo "HyCanvas actualizado correctamente."
     ```
4. **Configuracion de Nginx para `hycanvas.holospace.com.ar`:**
   - Redactar el archivo de configuracion de Nginx para el servidor Hetzner:
     ```nginx
     server {
         server_name hycanvas.holospace.com.ar;

         location / {
             proxy_pass http://127.0.0.1:8088;
             proxy_http_version 1.1;
             proxy_set_header Upgrade $http_upgrade;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_set_header X-Forwarded-Proto $scheme;
             client_max_body_size 100M;
         }
     }
     ```
5. **DNS & Certificado SSL:**
   - Indicar al usuario que apunte el registro `A` de `hycanvas` a la IP de Hetzner y correr `certbot --nginx -d hycanvas.holospace.com.ar`.

---

## 5. Cierre de Traspaso

El workspace actual (`holospace-baseline`) permanece intacto y libre de dependencias externas. El usuario puede ahora abrir el workspace `hycanvas-baseline` en su editor/agente y comenzar de inmediato con la implementacion.
