# Authentication Service Configuration

## Overview
This file defines a Kubernetes Service that exposes the authentication deployment within the cluster for internal communication.

## File: `authentication/service.yaml`

## What it does
- Creates a ClusterIP service for the authentication deployment
- Enables internal cluster communication on port 8080
- Provides stable network endpoint for other services
- Acts as a load balancer for authentication pods

## Configuration Details

### Service Specifications
- **Name**: `weatherapp-auth`
- **Type**: `ClusterIP` (internal cluster access only)
- **Port**: 8080 (HTTP traffic)
- **Target Port**: 8080 (matches container port)
- **Protocol**: TCP

### Service Discovery
Other services can access authentication using:
- **Service Name**: `weatherapp-auth`
- **Full DNS**: `weatherapp-auth.default.svc.cluster.local`
- **Port**: 8080
- **Example URL**: `http://weatherapp-auth:8080`

### Load Balancing
The service provides:
1. **Traffic Distribution**: Balances requests across pod replicas
2. **Health Checking**: Only routes to healthy pods
3. **Service Discovery**: Stable endpoint regardless of pod changes
4. **Internal Access**: Available only within the cluster

## Why ClusterIP
ClusterIP is used because:
1. **Internal Service**: Authentication is accessed by other services, not users
2. **Security**: Not exposed to external traffic
3. **Performance**: Direct cluster networking
4. **Service Mesh**: Works with service mesh architectures

## Usage by Other Services
The UI service uses this service to:
- Validate user login credentials
- Register new users
- Verify JWT tokens
- Handle authentication workflows

## Network Flow
```
UI Service → weatherapp-auth:8080 → Authentication Pod(s)
```

## Service Selector
Uses label selector to find pods:
- **Label**: `app.kubernetes.io/name: weatherapp-auth`
- Matches pods created by the authentication deployment

## Deployment Command
```bash
kubectl apply -f authentication/service.yaml
```

## Verification
Check service status:
```bash
kubectl get svc weatherapp-auth
kubectl describe svc weatherapp-auth
kubectl get endpoints weatherapp-auth
```

## Testing Connectivity
Test service from within cluster:
```bash
kubectl run test-pod --image=curlimages/curl -it --rm -- sh
curl http://weatherapp-auth:8080/health
```
