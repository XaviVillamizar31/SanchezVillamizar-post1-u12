# Post-Contenido 1 — Contenedorizar la Aplicación Spring Boot y Desplegar en Railway

**Programación Web — Unidad 12: Despliegue y CI/CD**  
Ingeniería de Sistemas — UDES 2026

---

## Descripción

Contenedorización de la aplicación Spring Boot del catálogo de productos mediante un Dockerfile multi-stage, configuración del ambiente de producción con perfiles y variables de entorno, orquestación local con Docker Compose incluyendo PostgreSQL, y despliegue en Railway con la base de datos conectada y los endpoints REST funcionando públicamente.

---

## Aplicación desplegada en Railway

**URL pública:**
```
https://sanchezvillamizar-post1-u12-production-a6db.up.railway.app
```

Endpoints disponibles públicamente:
- `GET /api/productos` → Lista productos
- `POST /api/productos` → Crea producto
- `GET /api/productos/{id}` → Busca por ID
- `DELETE /api/productos/{id}` → Elimina producto
- `GET /actuator/health` → Estado de la aplicación

---

## Requisitos previos

- Java 17+
- Maven 3.9.x
- Docker Desktop instalado y en ejecución
- Cuenta en Railway (railway.app) vinculada a GitHub

---

## Estructura del Proyecto

```
apellido-post1-u12/
├── .github/
├── src/
│   └── main/
│       ├── java/com/empresa/catalogo/
│       └── resources/
│           ├── application.properties           ← Perfil desarrollo (H2)
│           ├── application-prod.properties      ← Perfil producción (PostgreSQL)
│           └── logback-spring.xml
├── Dockerfile                                   ← Multi-stage build
├── .dockerignore
├── docker-compose.yml                           ← Orquestación local con PostgreSQL
└── pom.xml
```

---

## Checkpoint 1 — Dockerfile Multi-Stage

El `Dockerfile` usa dos etapas:
- **builder** — imagen JDK + Maven para compilar el JAR
- **producción** — imagen JRE liviana con usuario no root para ejecutar

### Construir la imagen localmente

```bash
docker build -t catalogo:local .
```

### Verificar la imagen

```bash
docker images catalogo
```

---

## Checkpoint 2 — Docker Compose con PostgreSQL

### Variables de entorno requeridas

| Variable | Descripción |
|---|---|
| `SPRING_PROFILES_ACTIVE` | Perfil activo (`prod`) |
| `DATABASE_URL` | URL JDBC de PostgreSQL |
| `DB_USER` | Usuario de la base de datos |
| `DB_PASS` | Contraseña de la base de datos |

### Levantar el stack completo localmente

```bash
docker compose up -d --build
```

### Verificar que ambos servicios estén corriendo

```bash
docker compose ps
```

Debe mostrar `app` y `db` en estado `Up/healthy`.

### Verificar que la app responde

```
http://localhost:8081/api/productos
http://localhost:8081/actuator/health
```

### Ver logs de la aplicación

```bash
docker compose logs app --tail=50
```

### Detener el stack

```bash
docker compose down
```

---

## Checkpoint 3 — Despliegue en Railway

### Pasos realizados

1. Conectar el repositorio GitHub en Railway → **Deploy from GitHub repo**
2. Railway detecta el `Dockerfile` automáticamente y construye la imagen
3. Agregar servicio PostgreSQL → **+ New → Database → Add PostgreSQL**
4. Configurar variables de entorno en el servicio de la aplicación:

| Variable | Valor en Railway |
|---|---|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `DATABASE_URL` | `jdbc:postgresql://postgres.railway.internal:5432/railway` |
| `DB_USER` | `postgres` |
| `DB_PASS` | (valor de `PGPASSWORD` del servicio PostgreSQL) |
| `SERVER_PORT` | `${PORT:8080}` |

5. Generar dominio público en **Settings → Networking → Generate Domain**

### Verificar el despliegue

```bash
curl https://sanchezvillamizar-post1-u12-production-a6db.up.railway.app/actuator/health
```

Respuesta esperada:
```json
{"groups":["liveness","readiness"],"status":"UP"}
```

```bash
curl https://sanchezvillamizar-post1-u12-production-a6db.up.railway.app/api/productos
```

---

## Evidencias

| Evidencia | Descripción |
|-----------|-------------|
| `evidencia/docker-images.png` | Imagen `catalogo:local` construida |
<img width="1920" height="1032" alt="image" src="https://github.com/user-attachments/assets/0f4ae33c-22ff-4461-ad07-382fb3aa1d88" />

| `evidencia/docker-compose-ps.png` | Stack local con `app` y `db` en estado Up/healthy |
<img width="1912" height="914" alt="image" src="https://github.com/user-attachments/assets/e149953c-3f4f-4531-b94c-6ec82c26ff1e" />

| `evidencia/health-local.png` | `GET /actuator/health` retorna `{"status":"UP"}` local |
<img width="1920" height="1032" alt="msedge_h5MyPi12FY" src="https://github.com/user-attachments/assets/7a5e7292-34de-4501-8001-8756c8ddbd75" />

| `evidencia/railway-panel.png` | Panel de Railway con servicios app y PostgreSQL |
<img width="1912" height="914" alt="image" src="https://github.com/user-attachments/assets/4bb6cabf-9547-4e42-a011-1dea367a128c" />


| `evidencia/railway-health.png` | `GET /actuator/health` en URL de Railway |
<img width="1920" height="1032" alt="image" src="https://github.com/user-attachments/assets/093fc7e9-b24d-4313-9a47-0e58d5c4ff69" />

| `evidencia/railway-productos.png` | `GET /api/productos` funcionando en Railway |
<img width="1920" height="1032" alt="msedge_yOTBZPBFPL" src="https://github.com/user-attachments/assets/18d9b719-8c39-4159-9a23-6fbfa558743a" />


---

## Tecnologías usadas

| Tecnología | Versión | Uso |
|------------|---------|-----|
| Spring Boot | 4.0.6 | Framework base |
| PostgreSQL | 16 | Base de datos en producción |
| H2 | — | Base de datos en desarrollo local |
| Docker | — | Contenedorización |
| Docker Compose | — | Orquestación local |
| Railway | — | Plataforma de despliegue en la nube |
