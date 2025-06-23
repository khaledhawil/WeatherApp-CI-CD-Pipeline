# MySQL Headless Service Configuration

## Overview
This file defines a Kubernetes headless service for MySQL StatefulSet, enabling direct pod-to-pod communication.

## File: `authentication/mysql/headless-service.yaml`

## What it does
- Creates a headless service (ClusterIP: None) for MySQL
- Enables direct access to MySQL pods by hostname
- Provides stable network identity for StatefulSet pods

## Configuration Details

### Service Type
- **Type**: Headless Service (ClusterIP: None)
- **Name**: `mysql`
- **Port**: 3306 (MySQL default port)

### Service Discovery
- Pods can connect using: `mysql-0.mysql.default.svc.cluster.local`
- Short form: `mysql-0.mysql`
- Service name: `mysql`

## Why Headless Service
StatefulSets require headless services because:
1. **Stable Pod Names**: Each pod gets a predictable hostname
2. **Direct Pod Access**: Applications can connect to specific pods
3. **Ordered Deployment**: Pods are created and terminated in order
4. **Persistent Identity**: Pod names remain consistent across restarts

## Usage
This service is used by:
- MySQL initialization jobs
- Authentication service for database connections
- Any service needing MySQL access

## Network Access
- **Internal Access**: Available within the cluster
- **Pod DNS**: `mysql-0.mysql` resolves to the MySQL pod
- **Port**: 3306 for MySQL connections

## Deployment Command
```bash
kubectl apply -f authentication/mysql/headless-service.yaml
```

## Verification
Check service creation:
```bash
kubectl get svc mysql
kubectl describe svc mysql
```
