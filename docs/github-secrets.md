# GitHub Secrets Configuration

## Required Secrets for CI/CD Pipeline

### DockerHub Secrets

#### `DOCKERHUB_USERNAME`
- **Value**: `khaledhawil`
- **Description**: Your DockerHub username
- **Required**: Yes

#### `DOCKERHUB_TOKEN`
- **Description**: DockerHub Personal Access Token
- **Required**: Yes
- **Permissions**: Read, Write, Delete
- **How to Generate**:
  1. Login to [DockerHub](https://hub.docker.com)
  2. Go to Account Settings → Security
  3. Click "New Access Token"
  4. Name: `github-actions-k8s-course`
  5. Select permissions: Read, Write, Delete
  6. Copy the generated token

### GitHub Repository Secrets

#### `GITHUB_TOKEN`
- **Description**: GitHub Personal Access Token (automatically provided)
- **Required**: Automatically available
- **Permissions**: Contents: write, Pull requests: write
- **Note**: This is automatically provided by GitHub Actions

## Setting Up Secrets in GitHub Repository

### Step-by-Step Instructions

1. **Navigate to Repository Settings**
   - Go to your GitHub repository
   - Click on "Settings" tab

2. **Access Secrets Configuration**
   - In the left sidebar, click "Secrets and variables"
   - Click "Actions"

3. **Add Repository Secrets**
   - Click "New repository secret"
   - Add each secret with the exact name and value

### Secret Configuration Table

| Secret Name | Value | Source | Required |
|-------------|-------|--------|----------|
| `DOCKERHUB_USERNAME` | `khaledhawil` | Manual | ✅ |
| `DOCKERHUB_TOKEN` | `<your_token>` | DockerHub | ✅ |
| `GITHUB_TOKEN` | `<auto>` | GitHub | ✅ (Auto) |

## Verification

### Test DockerHub Access
```bash
# Test login locally (optional)
echo $DOCKERHUB_TOKEN | docker login --username $DOCKERHUB_USERNAME --password-stdin
```

### Common Issues

#### Invalid DockerHub Token
- **Error**: `unauthorized: authentication required`
- **Solution**: Regenerate token with proper permissions

#### Missing Secrets
- **Error**: `Secret not found`
- **Solution**: Verify secret names match exactly (case-sensitive)

#### Token Permissions
- **Error**: `insufficient permissions`
- **Solution**: Ensure token has Read, Write, Delete permissions

## Security Best Practices

1. **Token Rotation**: Rotate DockerHub tokens every 90 days
2. **Minimal Permissions**: Use least-privilege access
3. **Monitor Usage**: Check DockerHub access logs regularly
4. **Repository Access**: Limit repository collaborators

## Quick Setup Command

For repository maintainers, here's the information needed:

```bash
# Required GitHub Secrets (add via GitHub UI):
DOCKERHUB_USERNAME=khaledhawil
DOCKERHUB_TOKEN=<generate_from_dockerhub>

# GITHUB_TOKEN is automatically provided
```
