---
name: hycanvas-architect
description: Especialista en arquitectura, operacion, personalizacion y desarrollo sobre la plataforma HyCanvas (Go backend + Next.js frontend + Fabric.js/Canvas + Docker). Usar para diagnostico, integracion, migraciones, APIs, WebSockets y extensiones sobre HyCanvas.
---

# Skill: HyCanvas Architect & Platform Specialist

Este skill condensa todo el conocimiento arquitectonico, operativo y tecnico necesario para dominar, mantener, personalizar y escalar **HyCanvas** (la plataforma open-source AI-native de diseno grafico, alternativa a Canva desarrollada por HyScaler).

---

## 1. Arquitectura del Sistema HyCanvas

HyCanvas es un monorrepo moderno empaquetado como un binario autocontenido o ejecutable distribuido:

### Componentes Principales:
1. **Backend (Go / `cmd/api`):**
   - Servidor HTTP de alto rendimiento escrito en Go.
   - Expone la API REST bajo `/api/v1`.
   - Servidor WebSocket para colaboracion en tiempo real (`/realtime`).
   - Gestor de migraciones SQL automaticas en el arranque (`DB_AUTO_MIGRATE=true`).
   - Motor de exportacion multimedia con `ffmpeg` embebido dentro de la imagen de contenedor.
2. **Frontend (Next.js / React / TypeScript / Canvas Engine):**
   - Interfaz visual SPA de diseno interactivo basada en Canvas (Fabric.js / HTML5 Canvas).
   - Servido en produccion directamente desde el binario Go (Next.js export embebido).
   - Modos Claro/Oscuro nativos y soporte multilenguaje (RTL y LTR).
3. **Capa de Persistencia (PostgreSQL 16):**
   - Tablas de usuarios, proyectos, plantillas (templates), capas (layers), fuentes tipograficas y configuraciones de espacio de trabajo.
4. **Almacenamiento de Archivos (Storage):**
   - Driver local (`STORAGE_DRIVER=local`): Mapeado en `/app/.data/storage` hacia el host en `./data/storage`.
   - Driver S3 (`STORAGE_DRIVER=s3`): Compatible con AWS S3, Cloudflare R2 o MinIO.

---

## 2. Pila Tecnologica y Endpoints Clave

- **Puerto Interno de Contenedor:** `8005`
- **Puerto Publicado en Host:** `8088` (Hetzner y Local)
- **Ruta de Salud (Liveness/Readiness):** `GET /healthz` (Responde `{"status":"ok","version":"..."}`)
- **API Base:** `http://localhost:8005/api/v1/`
- **WebSockets:** `ws://localhost:8005/realtime` (Requiere cabeceras `Upgrade: websocket` y `Connection: Upgrade` en proxy)

---

## 3. Variables de Entorno Criticas

| Variable | Descripcion | Valor Recomendado / Produccion |
|---|---|---|
| `JWT_SECRET` | Llave criptografica para firma de tokens y cifrado simetrico | 32 bytes hex (`openssl rand -hex 32`) |
| `AI_SECRET` | Cifrado en reposo para API keys de IA y TOTP | 32 bytes hex |
| `DATABASE_URL` | String de conexion Postgres | `postgresql://user:pass@host:5432/db?schema=public` |
| `COOKIE_SECURE` | Flag seguro de cookies | `true` (detras de SSL/TLS) / `false` (en dev plano) |
| `APP_URL` | URL base publica | `https://hycanvas.holospace.com.ar` |
| `FRONTEND_URL` | URL del cliente web | `https://hycanvas.holospace.com.ar` |
| `STORAGE_DRIVER` | Driver de persistencia de medios | `local` (o `s3`) |
| `LOCAL_STORAGE_PATH` | Ruta interna del contenedor para archivos | `/app/.data/storage` |
| `NODE_ENV` | Entorno de ejecucion | `production` |
| `PORT` | Puerto de escucha interno | `8005` |

---

## 4. Operaciones DevOps y Mantenimiento Desatendido

Todos los scripts siguen la convencion `devops-*` en `bin/`:

### A. Actualizar a la ultima version upstream
```bash
# Actualizar en Local:
./bin/devops-upgrade-hycanvas.sh local

# Actualizar en Hetzner (Remoto):
./bin/devops-upgrade-hycanvas.sh remote
```

### B. Diagnostico Integral y Healthcheck 360°
```bash
./bin/devops-check-status.sh
```
Comprueba:
1. Docker local (`hycanvas_app` y `hycanvas_db`).
2. Docker remoto en Hetzner (`5.161.237.189`).
3. Dominio publico `https://hycanvas.holospace.com.ar/healthz`.

### C. Despliegue de Configuraciones
```bash
./bin/devops-deploy-hetzner.sh
```

---

## 5. Reglas de Integridad para Extensiones y Personalizaciones

1. **Persistencia Intacta:** Nunca tocar ni eliminar `./data/storage/` ni el volumen `hycanvas_pgdata`.
2. **Cero Conflictos de Puertos:** HyCanvas opera exclusivamente en `8088` (host) y `8005` (interno), garantizando aislamiento total de HoloSpace (`3001`, `5434`, `6382`, `8081`).
3. **WebSockets Obligatorios:** En cualquier proxy inverso (Nginx / Cloudflare / NPM), siempre mantener encendidas las directivas `Upgrade` y `Connection` para evitar caidas en la sincronizacion de diseno.
