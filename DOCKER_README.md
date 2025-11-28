# Containerized Microservices TODO Application

This document describes the containerized version of the microservices TODO application with Traefik reverse proxy, SSL termination, and automatic HTTPS redirection.

## Architecture

The application consists of the following containerized services:

- **Frontend** (Vue.js) - Serves the web UI on port 8080
- **Auth API** (Go) - Handles authentication on port 8081
- **Todos API** (Node.js) - Manages todo operations on port 8082
- **Users API** (Java Spring Boot) - Manages user data on port 8083
- **Log Message Processor** (Python) - Processes Redis queue messages
- **Redis Queue** - Message queue for logging
- **Traefik** - Reverse proxy with SSL termination

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Ports 80, 443, and 8080 available on your system

### Starting the Application

**Option 1: Using Docker Compose directly**
```bash
docker compose up -d
```

**Option 2: Using the startup script**
```bash
# On Linux/Mac
./start.sh

# On Windows
start.bat
```

### Accessing the Application

- **Frontend**: https://localhost or http://localhost
- **Traefik Dashboard**: http://localhost:8080
- **API Endpoints**:
  - Auth API: https://localhost/api/auth
  - Todos API: https://localhost/api/todos
  - Users API: https://localhost/api/users

## SSL and Domain Configuration

### Local Development
The application is configured to work with `localhost` by default. Traefik will:
- Redirect HTTP to HTTPS automatically
- Generate self-signed certificates for localhost
- Handle SSL termination

### Production Domain
To use with a real domain:

1. Update the Traefik labels in `docker-compose.yml`:
   ```yaml
   - "traefik.http.routers.frontend.rule=Host(`your-domain.com`)"
   - "traefik.http.routers.frontend-secure.rule=Host(`your-domain.com`)"
   ```

2. Update the email in Traefik configuration:
   ```yaml
   - "--certificatesresolvers.myresolver.acme.email=your-email@domain.com"
   ```

3. Ensure your domain points to the server running Docker

## API Behavior

### Expected Responses

- **Frontend**: Login page accessible, redirects to TODO dashboard after authentication
- **Auth API Direct Access**: Returns "Not Found" (as expected)
- **Todos API Direct Access**: Returns "Invalid Token" (requires JWT)
- **Users API Direct Access**: Returns "Missing or invalid Authorization header"

### Authentication

Use the following test credentials:
- Username: `admin`, Password: `Admin123`
- Username: `hng`, Password: `HngTech`
- Username: `user`, Password: `Password`

## Service Details

### Frontend (Vue.js)
- **Build**: Multi-stage Docker build with nginx serving static files
- **Port**: 8080
- **Features**: SPA with Vue Router, proxies API calls through Traefik

### Auth API (Go)
- **Build**: Multi-stage build with Alpine Linux
- **Port**: 8081
- **Features**: JWT token generation, user authentication

### Todos API (Node.js)
- **Build**: Single-stage Node.js Alpine
- **Port**: 8082
- **Features**: CRUD operations, Redis logging, JWT validation

### Users API (Java Spring Boot)
- **Build**: Multi-stage Maven build
- **Port**: 8083
- **Features**: User profile management, JWT validation

### Log Message Processor (Python)
- **Build**: Python Alpine with Redis client
- **Features**: Processes messages from Redis queue

## Networking

All services communicate through the `app-network` Docker network:
- Services can reach each other using service names as hostnames
- External access is only through Traefik on ports 80/443
- Traefik dashboard accessible on port 8080

## Volumes

- `redis-data`: Persistent storage for Redis
- `letsencrypt`: SSL certificate storage for Traefik

## Stopping the Application

```bash
docker compose down
```

To remove all data:
```bash
docker compose down -v
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80, 443, and 8080 are not in use
2. **SSL certificate issues**: Wait a few minutes for Let's Encrypt certificate generation
3. **Service startup order**: Services have proper dependency configuration

### Logs

View logs for specific services:
```bash
docker compose logs frontend
docker compose logs auth-api
docker compose logs todos-api
docker compose logs users-api
docker compose logs log-message-processor
docker compose logs traefik
```

View all logs:
```bash
docker compose logs -f
```

## Development

### Rebuilding Services

To rebuild a specific service:
```bash
docker compose build frontend
docker compose up -d frontend
```

To rebuild all services:
```bash
docker compose up -d --build
```

### Environment Variables

All environment variables are configured in the docker-compose.yml file based on the original .env configuration.