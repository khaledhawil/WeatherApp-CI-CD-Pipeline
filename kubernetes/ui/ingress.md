# UI Ingress Configuration

## Overview
This file defines a Kubernetes Ingress resource for the UI service, providing HTTP/HTTPS routing and SSL termination with custom domain support.

## File: `ui/ingress.yaml`

## What it does
- Creates an Ingress resource for domain-based routing
- Provides SSL/TLS termination for secure HTTPS access
- Routes traffic from custom domain to UI service
- Enables advanced HTTP routing and load balancing

## Configuration Details

### Ingress Specifications
- **Name**: `weatherapp-ui-ingress`
- **Ingress Class**: `nginx` (NGINX Ingress Controller)
- **Host**: `weatherapp.local` (custom domain)
- **Backend Service**: `weatherapp-ui` on port 3000

### SSL/TLS Configuration
- **TLS Secret**: `weatherapp-ui-tls`
- **Certificate**: Custom SSL certificate for domain
- **HTTPS Support**: Secure connections via port 443
- **HTTP Redirect**: Automatic redirect to HTTPS

### Ingress Controller
Uses NGINX Ingress Controller for:
1. **HTTP Routing**: Routes requests based on hostname
2. **SSL Termination**: Handles HTTPS encryption/decryption
3. **Load Balancing**: Distributes traffic across service pods
4. **Advanced Features**: Rate limiting, authentication, etc.

## Why Use Ingress
Ingress provides advantages over LoadBalancer:
1. **Cost Effective**: Single entry point for multiple services
2. **SSL Management**: Centralized certificate handling
3. **Domain Routing**: Route different domains to different services
4. **Advanced Routing**: Path-based routing, redirects, rewrites
5. **Protocol Support**: HTTP/HTTPS, WebSocket support

## Domain Configuration
To use `weatherapp.local`:
1. **Local Development**: Add to `/etc/hosts` file
2. **DNS Configuration**: Point domain to LoadBalancer IP
3. **Certificate**: Install SSL certificate for domain
4. **Testing**: Access via `https://weatherapp.local`

### Hosts File Entry
```
165.22.78.175 weatherapp.local
```

## TLS Certificate
The ingress references TLS secret containing:
- **Certificate File**: `tls.crt`
- **Private Key**: `tls.key`
- **Certificate Authority**: Trusted CA or self-signed

### Certificate Creation
```bash
kubectl create secret tls weatherapp-ui-tls \
  --cert=tls.crt \
  --key=tls.key
```

## Traffic Flow
```
Browser → Domain DNS → Ingress Controller → UI Service → UI Pods
```

## Ingress Controller Requirements
Requires NGINX Ingress Controller installed:
1. **Installation**: Deploy NGINX controller in cluster
2. **LoadBalancer**: Controller service needs external access
3. **Configuration**: Controller handles ingress resources automatically

## Path-Based Routing
Can be extended for multiple paths:
- `/` → UI Service
- `/api/auth` → Authentication Service
- `/api/weather` → Weather Service

## Deployment Command
```bash
kubectl apply -f ui/ingress.yaml
```

## Verification
Check ingress status:
```bash
kubectl get ingress weatherapp-ui-ingress
kubectl describe ingress weatherapp-ui-ingress
```

## Testing Access
Access via domain:
```bash
curl https://weatherapp.local
curl -k https://weatherapp.local  # Skip SSL verification for self-signed
```

## Production Considerations
1. **Valid SSL Certificate**: Use trusted CA certificates
2. **DNS Configuration**: Proper domain DNS setup
3. **Rate Limiting**: Configure ingress rate limits
4. **Monitoring**: Monitor ingress controller metrics
5. **Security Headers**: Add security headers via annotations

## Alternative to LoadBalancer
Ingress can replace LoadBalancer service:
- Change UI service to ClusterIP
- Use ingress for external access
- Reduce cloud provider costs
- Gain advanced routing features
