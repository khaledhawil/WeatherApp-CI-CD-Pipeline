# Authentication Service Deployment Configuration

## Overview
This file defines a Kubernetes Deployment for the authentication service written in Go, which handles user registration and login functionality.

## File: `authentication/deployment.yaml`

## What it does
- Deploys the authentication service as a Go application
- Connects to MySQL database for user management
- Provides JWT token-based authentication
- Handles user registration and login endpoints

## Configuration Details

### Deployment Specifications
- **Name**: `weatherapp-auth`
- **Replicas**: 1 (single instance)
- **Image**: `khaledhawil/auth:1.0.0`
- **Port**: 8080 (HTTP service)

### Environment Variables
1. **DB_HOST**: MySQL server hostname (`mysql`)
2. **DB_USER**: Database username (`authuser`)
3. **DB_PASSWORD**: Database password from secret
4. **DB_NAME**: Database name (`weatherapp`)
5. **DB_PORT**: Database port (`3306`)
6. **SECRET_KEY**: JWT signing key from secret

### Application Features
The authentication service provides:
1. **User Registration**: `/signup` endpoint for new users
2. **User Login**: `/login` endpoint for authentication
3. **JWT Tokens**: Secure token generation for session management
4. **Password Hashing**: MD5 hashing for password security
5. **Database Integration**: User data stored in MySQL

### Service Architecture
- **Language**: Go (Golang)
- **Framework**: Gin web framework
- **Database**: MySQL with GORM ORM
- **Authentication**: JWT tokens
- **CORS**: Enabled for web frontend access

## Database Connection
The service connects to MySQL using:
- Host: `mysql` (headless service name)
- Database: `weatherapp`
- User: `authuser`
- Password: Retrieved from Kubernetes secret

## Security Features
1. **Secret Management**: Sensitive data stored in Kubernetes secrets
2. **Password Hashing**: User passwords are hashed before storage
3. **JWT Tokens**: Secure token-based authentication
4. **CORS Configuration**: Controlled cross-origin access

## API Endpoints
- **POST /signup**: Register new user
- **POST /login**: Authenticate existing user
- **GET /health**: Health check endpoint

## Image Pull Policy
- **Policy**: `IfNotPresent`
- Downloads image only if not cached locally
- Improves deployment speed and reduces bandwidth

## Deployment Command
```bash
kubectl apply -f authentication/deployment.yaml
```

## Verification
Check deployment status:
```bash
kubectl get deployment weatherapp-auth
kubectl get pods -l app.kubernetes.io/name=weatherapp-auth
kubectl logs deployment/weatherapp-auth
```

## Dependencies
This deployment requires:
1. MySQL StatefulSet running
2. MySQL secret created
3. Database initialization completed
