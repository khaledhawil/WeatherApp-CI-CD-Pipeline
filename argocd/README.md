# ArgoCD Application Configuration

This directory contains ArgoCD Application manifests for deploying the WeatherApp microservices using GitOps principles.

## Overview

The ArgoCD configuration provides automated deployment and management of the WeatherApp through multiple ArgoCD Applications, following the App-of-Apps pattern for better organization and dependency management.

## Architecture

### Application Structure
```
weatherapp (App-of-Apps)
├── weatherapp-mysql      (Sync Wave: 1)
├── weatherapp-auth       (Sync Wave: 2)
├── weatherapp-weather    (Sync Wave: 3)
└── weatherapp-ui         (Sync Wave: 4)
```

### Sync Waves
Applications are deployed in order using sync waves to ensure proper dependency management:
1. **Wave 1**: MySQL Database (StatefulSet, Services, Secrets)
2. **Wave 2**: Authentication Service (depends on MySQL)
3. **Wave 3**: Weather Service (independent)
4. **Wave 4**: UI Service (depends on Auth and Weather services)

## Files Description

### Application Manifests

#### `weatherapp-mysql.yaml`
- **Purpose**: Deploys MySQL database components
- **Path**: `kubernetes/authentication/mysql`
- **Sync Wave**: 1
- **Components**: StatefulSet, HeadlessService, Secret, InitJob

#### `weatherapp-auth.yaml`
- **Purpose**: Deploys authentication service
- **Path**: `kubernetes/authentication` (excludes mysql directory)
- **Sync Wave**: 2
- **Components**: Deployment, Service

#### `weatherapp-weather.yaml`
- **Purpose**: Deploys weather service
- **Path**: `kubernetes/weather`
- **Sync Wave**: 3
- **Components**: Deployment, Service, Secret

#### `weatherapp-ui.yaml`
- **Purpose**: Deploys UI frontend service
- **Path**: `kubernetes/ui`
- **Sync Wave**: 4
- **Components**: Deployment, Service, Ingress

#### `app-of-apps.yaml`
- **Purpose**: Root application managing all child applications
- **Path**: `argocd`
- **Pattern**: App-of-Apps
- **Function**: Creates and manages all weatherapp applications

#### `weatherapp-complete.yaml`
- **Purpose**: Alternative single application with multiple sources
- **Project**: Uses custom weatherapp-project
- **Sources**: All four application paths in one application

#### `weatherapp-project.yaml`
- **Purpose**: Custom ArgoCD project with RBAC and resource policies
- **Features**: Role-based access control, resource whitelisting
- **Roles**: read-only, admin

## Configuration Features

### Automated Sync Policy
```yaml
syncPolicy:
  automated:
    prune: true          # Remove resources not in Git
    selfHeal: true       # Auto-fix drift
    allowEmpty: false    # Prevent empty deployments
```

### Sync Options
- **CreateNamespace**: Automatically create target namespaces
- **PrunePropagationPolicy**: Control resource deletion order
- **PruneLast**: Delete resources after deploying new ones
- **ApplyOutOfSyncOnly**: Only sync changed resources

### Retry Configuration
- **Limit**: 5 retry attempts
- **Backoff**: Exponential backoff (5s → 10s → 20s → 40s → 3m)

### Ignore Differences
- **Deployment replicas**: Ignore HPA-managed replica counts
- **Service ClusterIP**: Ignore Kubernetes-assigned cluster IPs

## Prerequisites

### ArgoCD Installation
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### Access ArgoCD UI
```bash
# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Deployment Options

### Option 1: App-of-Apps Pattern (Recommended)
Deploy the root application that manages all child applications:

```bash
# Deploy the App-of-Apps
kubectl apply -f argocd/app-of-apps.yaml

# This will automatically create:
# - weatherapp-mysql
# - weatherapp-auth
# - weatherapp-weather
# - weatherapp-ui
```

### Option 2: Individual Applications
Deploy applications individually:

```bash
# Deploy in order (respecting dependencies)
kubectl apply -f argocd/weatherapp-mysql.yaml
kubectl apply -f argocd/weatherapp-auth.yaml
kubectl apply -f argocd/weatherapp-weather.yaml
kubectl apply -f argocd/weatherapp-ui.yaml
```

### Option 3: Complete Application
Deploy using the single multi-source application:

```bash
# First create the project
kubectl apply -f argocd/weatherapp-project.yaml

# Then deploy the complete application
kubectl apply -f argocd/weatherapp-complete.yaml
```

### Option 4: Custom Project Setup
For enhanced RBAC and organization:

```bash
# Create custom project
kubectl apply -f argocd/weatherapp-project.yaml

# Update applications to use the project
# Edit each application file and change:
# spec.project: weatherapp-project
```

## GitOps Workflow Integration

### Automatic Deployment
When GitHub Actions CI/CD pipeline updates Kubernetes manifests:

1. **Code Push**: Developer pushes code changes
2. **CI/CD Build**: GitHub Actions builds and pushes new Docker images
3. **Manifest Update**: CI/CD updates deployment manifests with new image tags
4. **ArgoCD Sync**: ArgoCD detects changes and automatically deploys
5. **Health Check**: ArgoCD monitors application health and status

### Manual Sync
Force synchronization via ArgoCD UI or CLI:

```bash
# Sync specific application
argocd app sync weatherapp-auth

# Sync all applications
argocd app sync weatherapp-mysql weatherapp-auth weatherapp-weather weatherapp-ui

# Sync with App-of-Apps
argocd app sync weatherapp
```

## Monitoring and Troubleshooting

### Check Application Status
```bash
# List all applications
kubectl get applications -n argocd

# Get application details
kubectl describe application weatherapp-auth -n argocd

# Check sync status
argocd app get weatherapp-auth
```

### Common Issues

#### 1. Sync Wave Dependencies
**Issue**: Applications deploy out of order
**Solution**: Verify sync wave annotations are correct

#### 2. Resource Not Found
**Issue**: ArgoCD can't find Kubernetes resources
**Solution**: Check path configuration and repository access

#### 3. Sync Failure
**Issue**: Application fails to sync
**Solution**: Check resource YAML validity and RBAC permissions

#### 4. Image Pull Errors
**Issue**: Pods can't pull Docker images
**Solution**: Verify image tags are updated by CI/CD pipeline

### Health Checks
ArgoCD monitors:
- **Pod Status**: Running, Ready, Healthy
- **Service Endpoints**: Available and responsive
- **Ingress Status**: External access working
- **Resource Sync**: Git vs Cluster state

## Security Considerations

### RBAC Configuration
The custom project includes role-based access control:

- **read-only**: View applications and resources
- **admin**: Full management capabilities

### Network Security
- Applications deployed in default namespace
- Consider using dedicated namespace for production
- Implement NetworkPolicies for pod-to-pod communication

### Secret Management
- MySQL secrets managed through Kubernetes Secrets
- Weather API key stored in Secret
- Consider using external secret management (Vault, AWS Secrets Manager)

## Best Practices

### 1. Resource Organization
- Use labels for consistent resource identification
- Implement proper resource naming conventions
- Group related resources in same directory

### 2. Sync Configuration
- Use automated sync for development environments
- Consider manual sync for production environments
- Implement proper retry and backoff strategies

### 3. Monitoring
- Enable ArgoCD notifications
- Monitor application health metrics
- Set up alerts for sync failures

### 4. Version Control
- Keep ArgoCD manifests in same repository as application code
- Use meaningful commit messages for deployment tracking
- Tag releases for rollback capabilities

## Integration with CI/CD

The ArgoCD applications work seamlessly with the GitHub Actions CI/CD pipeline:

1. **Image Updates**: CI/CD updates deployment manifests with new image tags
2. **Auto Sync**: ArgoCD detects changes and deploys automatically  
3. **Health Monitoring**: ArgoCD ensures deployments are healthy
4. **Rollback**: Easy rollback to previous versions through ArgoCD UI

This creates a complete GitOps workflow where:
- **Git is the single source of truth**
- **Deployments are automated and consistent**
- **Changes are auditable and trackable**
- **Rollbacks are quick and reliable**

## Customization

### Environment-Specific Configurations
To deploy to different environments, create separate ArgoCD applications:

```yaml
# argocd/weatherapp-staging.yaml
metadata:
  name: weatherapp-staging
spec:
  source:
    targetRevision: develop  # Use develop branch
  destination:
    namespace: staging       # Deploy to staging namespace
```

### Resource Customization
Use Kustomize overlays for environment-specific configurations:

```yaml
# Base configuration in kubernetes/
# Environment overlays in kubernetes/overlays/production/
source:
  path: kubernetes/overlays/production
```

This ArgoCD configuration provides a robust, scalable GitOps solution for the WeatherApp microservices deployment.
