# External Services Ingress Configuration

This directory contains Kubernetes Ingress resources for external services running on the master node (192.168.1.10).

## Services

All services are accessed via Traefik ingress controller with automatic HTTPS (cert-manager/Let's Encrypt):

- **LibreChat** (`librechat.reveek-io.ru`) → localhost:3080
- **LibreChat Admin** (`admin.librechat.reveek-io.ru`) → localhost:3000
- **LibreChat User Admin** (`librechat.reveek-io.ru/user-admin`) → localhost:3001
- **SearXNG** (`searxng.reveek-io.ru`) → localhost:8888
- **Presenton** (`presenton.reveek-io.ru`) → localhost:5001
- **Noodle** (`noodle.reveek-io.ru`) → localhost:2283
- **Root App** (`reveek-io.ru`) → localhost:11000

## Implementation

Each service uses:
- Kubernetes Service (headless, no selector)
- Kubernetes Endpoints (pointing to master node IP)
- Ingress resource (Traefik + cert-manager)

This allows Traefik to route external traffic to services running directly on the master node, replacing the previous Caddy reverse proxy setup.
