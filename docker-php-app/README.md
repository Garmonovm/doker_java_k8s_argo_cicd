# PHP Application — Containerized

Minimal, production-ready PHP application with a `/health` endpoint, containerized via a multi-stage Docker build.

## Project Structure

```
docker-php-app/
├── Dockerfile              # Multi-stage build (builder → runtime)
├── .dockerignore           # Keeps image lean
├── docker-compose.yml      # Local development / testing
├── composer.json           # PHP dependencies (Slim framework)
└── public/
    └── index.php           # Application entry point
```

## Endpoints

| Method | Path      | Description                          | Response |
|--------|-----------|--------------------------------------|----------|
| GET    | `/`       | Root — confirms app is running       | 200 JSON |
| GET    | `/health` | Health check for ALB / ECS / EKS     | 200 JSON |

#### Health Response Example

```json
{
  "status": "healthy",
  "timestamp": "2026-02-19T12:00:00Z",
  "service": "php-app",
  "version": "1.0.0"
}
```

## Quick Start

### Build & Run with Docker Compose

```bash
docker compose up --build -d
curl http://localhost:8080/health
```

### Build & Run with Docker

```bash
docker build -t php-app .
docker run -d -p 8080:8080 -e PORT=8080 --name php-app php-app
curl http://localhost:8080/health
```

### Custom Port

```bash
docker run -d -p 3000:3000 -e PORT=3000 --name php-app php-app
curl http://localhost:3000/health
```

## Dockerfile Stages

| Stage     | Base Image        | Purpose                                      |
|-----------|-------------------|----------------------------------------------|
| `builder` | `composer:2.8`    | Install Composer dependencies (no dev deps)   |
| `runtime` | `php:8.3-apache`  | Lean production image with opcache enabled    |

### Production Hardening

- **OPcache enabled** — bytecode caching, no file revalidation
- **`php.ini-production`** used as base config
- **`expose_php=Off`** — hides PHP version from headers
- **Logs to stdout/stderr** — compatible with CloudWatch, Fluentd, etc.
- **Non-root execution** — Apache runs as `www-data`
- **HEALTHCHECK** instruction for Docker / ECS native health checks

## Environment Variables

| Variable      | Default   | Description                    |
|---------------|-----------|--------------------------------|
| `PORT`        | `8080`    | Port Apache listens on         |
| `APP_NAME`    | `php-app` | Service name in health response|
| `APP_VERSION` | `1.0.0`   | Version in health response     |
| `APP_DEBUG`   | `false`   | Show detailed errors           |

## Next Steps (Infrastructure)

- **Terraform**: ECR repository, ECS/EKS cluster, ALB, networking
- **GitHub Actions**: CI/CD pipeline — build image → push to ECR → deploy to ECS/EKS
