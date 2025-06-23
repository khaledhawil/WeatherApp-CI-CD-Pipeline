# UI Service Configuration

## Overview
This file defines a Kubernetes Service that exposes the UI deployment with a DigitalOcean LoadBalancer for external internet access.

## File: `ui/service.yaml`

## What it does
- Creates a LoadBalancer service for external access to the web interface
- Provides public internet access via DigitalOcean LoadBalancer
- Routes traffic to UI pods running the web frontend
- Assigns an external IP address for user access

## Configuration Details

### Service Specifications
- **Name**: `weatherapp-ui`
- **Type**: `LoadBalancer` (external access via cloud provider)
- **Port**: 80 (standard HTTP port)
- **Target Port**: 3000 (container port)
- **Protocol**: TCP

### LoadBalancer Features
DigitalOcean LoadBalancer provides:
1. **External IP**: Public IP address for internet access
2. **High Availability**: Redundant load balancer infrastructure
3. **Health Checking**: Routes traffic only to healthy pods
4. **SSL Termination**: Can handle HTTPS traffic
5. **Geographic Distribution**: Multiple data center support

### DigitalOcean Annotations
- **service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol**: `true`
- **service.beta.kubernetes.io/do-loadbalancer-hostname**: `weatherapp.local`
- Enables advanced LoadBalancer features

## Why LoadBalancer Type
LoadBalancer is used because:
1. **External Access**: Users need internet access to the web interface
2. **Cloud Integration**: Leverages DigitalOcean's LoadBalancer service
3. **Automatic IP**: Cloud provider assigns public IP automatically
4. **Production Ready**: Enterprise-grade load balancing

## Network Architecture
```
Internet → DigitalOcean LoadBalancer → Kubernetes Service → UI Pods
```

## External Access
Users can access the application via:
- **External IP**: Assigned by DigitalOcean (e.g., 165.22.78.175)
- **Port**: 80 (standard web port)
- **URL**: `http://external-ip/`

## Traffic Flow
1. **Internet Request**: User browser connects to external IP
2. **LoadBalancer**: DigitalOcean routes traffic to healthy nodes
3. **Kubernetes Service**: Distributes traffic across UI pods
4. **UI Application**: Serves web interface and handles requests

## Service Discovery
- **External DNS**: Can configure domain to point to external IP
- **Internal Access**: Other services use `weatherapp-ui:3000`
- **LoadBalancer Status**: Kubernetes tracks external IP assignment

## High Availability Features
1. **Multiple Pods**: 2 UI replicas for redundancy
2. **Health Checks**: Only healthy pods receive traffic
3. **Cloud SLA**: DigitalOcean LoadBalancer uptime guarantee
4. **Automatic Failover**: Seamless pod replacement

## Cost Considerations
DigitalOcean LoadBalancer:
- **Monthly Fee**: Additional cost for LoadBalancer service
- **Traffic Costs**: Potential data transfer charges
- **Regional Pricing**: Varies by datacenter location

## Deployment Command
```bash
kubectl apply -f ui/service.yaml
```

## Verification
Check LoadBalancer status:
```bash
kubectl get svc weatherapp-ui
kubectl describe svc weatherapp-ui
```

Wait for external IP assignment:
```bash
kubectl get svc weatherapp-ui -w
```

## Access Testing
Once external IP is assigned:
```bash
curl http://EXTERNAL-IP/
```

## Security Notes
- LoadBalancer exposes service to internet
- Consider implementing ingress with SSL/TLS
- Monitor access logs for security threats
- Use proper authentication and authorization
