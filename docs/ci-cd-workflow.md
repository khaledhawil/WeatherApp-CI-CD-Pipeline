# GitHub Actions CI/CD Workflow Documentation

## Overview

This GitHub Actions workflow provides automated CI/CD for the Weather Application microservices. It detects changes in individual service directories, builds and pushes Docker images only for changed services, and automatically updates Kubernetes deployment manifests with new image tags.

## Workflow Features

### 🎯 Selective Building
- **Path-based Detection**: Only builds services that have actual code changes
- **Service Directories Monitored**:
  - `auth/` → Auth service (Go)
  - `weather/` → Weather service (Python)
  - `UI/` → UI service (Node.js)

### 🏗️ Docker Image Management
- **Dynamic Tagging**: Images tagged with timestamp and commit SHA (`YYYYMMDD-HHMMSS-shortsha`)
- **Multi-tag Strategy**: Each image gets both specific tag and `latest` tag
- **Registry**: DockerHub (`khaledhawil/[service]:tag`)

### 📝 Automated Manifest Updates
- **Kubernetes Deployment Updates**: Automatically updates deployment YAML files with new image tags
- **Git Commit & Push**: Changes committed back to repository with `[skip ci]` to prevent CI loops
- **Selective Updates**: Only updates manifests for services that were rebuilt

### 🚀 CI Loop Prevention
- **Skip CI Commits**: Uses `[skip ci]` in commit messages to prevent infinite loops
- **Conditional Execution**: Only runs when actual service code changes

## Workflow Jobs

### 1. detect-changes
**Purpose**: Determine which services have changes
- Uses `dorny/paths-filter` action to detect file changes
- Sets outputs for downstream jobs to conditionally execute

### 2. build-and-push-[service]
**Purpose**: Build and push Docker images for changed services
- **Conditional Execution**: Only runs if corresponding service changed
- **Steps**:
  1. Generate unique image tag
  2. Set up Docker Buildx for multi-platform builds
  3. Login to DockerHub
  4. Build and push image with caching

### 3. update-manifests
**Purpose**: Update Kubernetes deployment manifests
- **Dependencies**: Runs after all build jobs complete
- **Conditional Execution**: Only runs if at least one build job succeeded
- **Steps**:
  1. Update deployment YAML files with new image tags
  2. Commit and push changes with `[skip ci]`

### 4. deploy-notification
**Purpose**: Provide deployment summary
- **Always Runs**: Provides status regardless of success/failure
- **GitHub Step Summary**: Creates a formatted summary table

## Required GitHub Secrets

### DockerHub Authentication
```bash
DOCKERHUB_USERNAME=khaledhawil
DOCKERHUB_TOKEN=<your_dockerhub_access_token>
```

### GitHub Repository Access
```bash
GITHUB_TOKEN=<automatically_provided_by_github>
```

## Setting Up GitHub Secrets

### 1. DockerHub Access Token
1. Go to [DockerHub Account Settings](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Name: `github-actions-k8s-course`
4. Permissions: `Read, Write, Delete`
5. Copy the generated token

### 2. Adding Secrets to GitHub Repository
1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `DOCKERHUB_USERNAME` | `khaledhawil` | Your DockerHub username |
| `DOCKERHUB_TOKEN` | `<token_from_step_1>` | DockerHub access token |

> **Note**: `GITHUB_TOKEN` is automatically provided by GitHub Actions for repository operations.

## Workflow Triggers

### Push Events
```yaml
on:
  push:
    branches: [ main, master ]
    paths:
      - 'auth/**'
      - 'weather/**'
      - 'UI/**'
      - '.github/workflows/**'
```

### Pull Request Events
```yaml
on:
  pull_request:
    branches: [ main, master ]
    paths:
      - 'auth/**'
      - 'weather/**'
      - 'UI/**'
```

## Image Tag Strategy

### Format
`YYYYMMDD-HHMMSS-shortsha`

### Example
- **Timestamp**: `20240315-143022`
- **Short SHA**: `a1b2c3d`
- **Final Tag**: `20240315-143022-a1b2c3d`

### Benefits
- **Chronological Ordering**: Easy to identify when image was built
- **Unique Identification**: Commit SHA ensures uniqueness
- **Rollback Capability**: Previous versions easily identifiable

## Deployment Process

### Automatic Process
1. **Code Change**: Developer pushes changes to service directory
2. **Change Detection**: Workflow detects which services changed
3. **Image Build**: Only changed services are built and pushed
4. **Manifest Update**: Deployment YAMLs updated with new tags
5. **Git Commit**: Changes committed back to repository

### Manual Deployment to Kubernetes
After the workflow completes, apply the updated manifests:

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# Or apply specific service
kubectl apply -f kubernetes/authentication/
kubectl apply -f kubernetes/weather/
kubectl apply -f kubernetes/ui/
```

### Verify Deployment
```bash
# Check deployment status
kubectl get deployments

# Check pods
kubectl get pods

# Check service endpoints
kubectl get services
```

## Troubleshooting

### Common Issues

#### 1. DockerHub Authentication Failure
**Error**: `unauthorized: authentication required`
**Solution**: 
- Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
- Ensure DockerHub token has write permissions

#### 2. Git Push Failure
**Error**: `Permission denied` or `remote: Permission to repository denied`
**Solution**:
- Ensure `GITHUB_TOKEN` has proper permissions
- Check repository settings for Actions permissions

#### 3. Infinite CI Loop
**Error**: Workflow triggers itself repeatedly
**Solution**:
- Verify `[skip ci]` is included in commit messages
- Check path filters exclude workflow files from triggering builds

#### 4. Manifest Update Failure
**Error**: `sed` command fails to update image tags
**Solution**:
- Check image tag format in deployment YAML files
- Ensure regex patterns match actual file content

### Debugging Steps

1. **Check Workflow Logs**: Review GitHub Actions logs for specific error messages
2. **Verify Secrets**: Ensure all required secrets are properly set
3. **Test Locally**: Build Docker images locally to verify Dockerfiles
4. **Check Permissions**: Verify repository and DockerHub permissions

## Monitoring and Maintenance

### Regular Tasks
- **Monitor Builds**: Check workflow success/failure rates
- **Clean Up Images**: Remove old Docker images from DockerHub
- **Update Dependencies**: Keep GitHub Actions up to date
- **Review Logs**: Monitor for authentication or permission issues

### Performance Optimization
- **Docker Layer Caching**: Workflow uses GitHub Actions cache
- **Conditional Execution**: Only builds changed services
- **Parallel Builds**: Services build in parallel when multiple changed

## Security Considerations

### Secrets Management
- **Limited Scope**: Secrets only accessible to this repository
- **Token Rotation**: Regularly rotate DockerHub tokens
- **Minimal Permissions**: Use least-privilege access tokens

### Docker Security
- **Base Image Updates**: Regularly update base images in Dockerfiles
- **Vulnerability Scanning**: Consider adding security scanning steps
- **Registry Security**: Use private registries for sensitive applications

## Example Workflow Run

### Scenario: UI Service Update
1. Developer modifies `UI/app.js`
2. Push triggers workflow
3. Only `build-and-push-ui` job runs
4. New image: `khaledhawil/ui:20240315-143022-a1b2c3d`
5. `kubernetes/ui/deployment.yaml` updated
6. Changes committed with `[skip ci] Update deployment manifests with new image tags`

### Scenario: Multiple Service Update
1. Developer modifies `auth/main.go` and `weather/main.py`
2. Both `build-and-push-auth` and `build-and-push-weather` jobs run
3. Both deployment manifests updated
4. Single commit with all changes

This CI/CD workflow ensures efficient, automated deployment while maintaining security and preventing infinite loops.
