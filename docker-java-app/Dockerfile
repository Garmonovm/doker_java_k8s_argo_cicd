# ============================================================================
# Multi-stage Dockerfile for Java Application
# Stage 1: Build — compile with Maven
# Stage 2: Runtime — lean JRE image
# ============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Builder — compile Java app with Maven
# ---------------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

## Copy POM first (Docker layer caching for dependencies)
COPY pom.xml .

## Download all dependencies offline — cached unless pom.xml changes
RUN mvn dependency:go-offline -B

## Copy application source code
COPY src ./src

## Build the application JAR (skip tests — they run in CI)
RUN mvn package -DskipTests -B

# ---------------------------------------------------------------------------
# Stage 2: Runtime — minimal production image
# ---------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine AS runtime

# Metadata
LABEL maintainer="maksim" \
      description="Production Java application" \
      version="1.0.0"

# JVM tuning for containers
# UseContainerSupport — JVM respects cgroup memory/CPU limits
# MaxRAMPercentage=75  — use 75% of container memory limit for heap
# UseG1GC             — low-latency garbage collector
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

# Configurable environment variables
ENV PORT=8080
ENV APP_NAME=java-app
ENV APP_VERSION=1.0.0

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /build/target/*.jar app.jar

# Ensure correct ownership
RUN chown -R appuser:appgroup /app

# Security: run as non-root
USER appuser

# Expose the configurable port
EXPOSE ${PORT}

# Health check — used by Docker, ECS, and K8s probes
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

# Run the application
# sh -c allows $JAVA_OPTS and $PORT to be expanded at runtime
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT} -jar app.jar"]
