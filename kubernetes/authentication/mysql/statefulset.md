# MySQL StatefulSet Configuration

## Overview
This file defines a Kubernetes StatefulSet for MySQL database with persistent storage and proper resource management.

## File: `authentication/mysql/statefulset.yaml`

## What it does
- Deploys MySQL 5.7 database as a StatefulSet
- Provides persistent storage for database data
- Configures environment variables and resource limits
- Sets up health checks and probes

## Configuration Details

### StatefulSet Specifications
- **Name**: `mysql`
- **Replicas**: 1 (single MySQL instance)
- **Service Name**: `mysql` (headless service)
- **Image**: `mysql:5.7`

### Environment Variables
1. **MYSQL_ROOT_PASSWORD**: Root user password from secret
2. **MYSQL_DATABASE**: Creates `weatherapp` database
3. **MYSQL_USER**: Creates `authuser` for application access
4. **MYSQL_PASSWORD**: Password for the application user

### MySQL Arguments
- `--ignore-db-dir=lost+found`: Prevents initialization errors with existing volumes

### Resource Management
- **Requests**: 512Mi memory, 250m CPU
- **Limits**: 1Gi memory, 500m CPU
- Ensures predictable performance and prevents resource starvation

### Health Checks
1. **Liveness Probe**: Uses `mysqladmin ping` to check if MySQL is alive
2. **Readiness Probe**: Uses TCP socket check on port 3306

### Persistent Storage
- **Volume**: Mounted at `/var/lib/mysql`
- **Storage Class**: `do-block-storage` (DigitalOcean)
- **Size**: 10Gi
- **Access Mode**: ReadWriteOnce

## Storage Configuration
The StatefulSet uses a PersistentVolumeClaim template:
- Automatically creates PVC for each pod
- Uses DigitalOcean Block Storage
- Data persists across pod restarts and rescheduling

## Why StatefulSet
StatefulSets are used for databases because they provide:
1. **Stable Pod Names**: Predictable hostnames (mysql-0)
2. **Ordered Deployment**: Pods start in sequence
3. **Persistent Storage**: Each pod gets its own PVC
4. **Stable Network Identity**: Consistent DNS names

## Security Features
- Passwords stored in Kubernetes secrets
- Non-root MySQL user for application access
- Resource limits prevent resource exhaustion

## Deployment Command
```bash
kubectl apply -f authentication/mysql/statefulset.yaml
```

## Verification
Check StatefulSet status:
```bash
kubectl get statefulset mysql
kubectl get pods -l app=mysql
kubectl logs mysql-0
```
