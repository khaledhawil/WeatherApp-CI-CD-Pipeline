# MySQL Secret Configuration

## Overview
This file defines a Kubernetes Secret that stores sensitive MySQL database credentials securely.

## File: `authentication/mysql/secret.yaml`

## What it does
- Stores MySQL root password, authentication user password, and secret key
- Encrypts sensitive data using base64 encoding
- Provides secure credential storage for MySQL database access

## Configuration Details

### Secret Type
- **Type**: `Opaque` - Generic secret type for arbitrary data
- **Namespace**: `default` - Deployed in the default namespace

### Stored Credentials
1. **root-password**: MySQL root user password (base64 encoded)
2. **auth-password**: Password for the authentication database user
3. **secret-key**: Application secret key for JWT token signing

## Usage
This secret is referenced by:
- MySQL StatefulSet for root password
- Authentication service for database connection
- Application services for JWT token signing

## Security Notes
- Credentials are base64 encoded (not encrypted)
- Secret should be created before deploying dependent services
- Access is controlled by Kubernetes RBAC

## Base64 Encoding
The values are encoded as follows:
- `secure-root-pw` → `c2VjdXJlLXJvb3QtcHc=`
- `my-secret-pw` → `bXktc2VjcmV0LXB3`
- `xco0sr0fh4e52x03g9mv` → `eGNvMHNyMGZoNGU1MngwM2c5bXY=`

## Deployment Command
```bash
kubectl apply -f authentication/mysql/secret.yaml
```
