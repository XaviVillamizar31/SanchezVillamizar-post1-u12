# ── Etapa 1: compilación con Maven ──────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /app

RUN apk add --no-cache maven

COPY pom.xml .
RUN mvn dependency:go-offline -q 2>/dev/null || true

COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Etapa 2: imagen de producción (solo JRE) ─────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Crear usuario no root y carpeta de logs con permisos correctos
RUN addgroup -S spring && adduser -S spring -G spring \
    && mkdir -p /app/logs \
    && chown -R spring:spring /app

USER spring

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]