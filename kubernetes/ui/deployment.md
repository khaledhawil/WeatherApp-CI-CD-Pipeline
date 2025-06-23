# UI Service Deployment Configuration

## Overview
This file defines a Kubernetes Deployment for the UI service built with Node.js and Express, which serves the web frontend and orchestrates backend services.

## File: `ui/deployment.yaml`

## What it does
- Deploys a Node.js Express server as the web frontend
- Serves HTML pages for user registration, login, and weather dashboard
- Coordinates communication between authentication and weather services
- Provides the main user interface for the weather application

## Configuration Details

### Deployment Specifications
- **Name**: `release-name-weatherapp-ui`
- **Replicas**: 2 (two instances for high availability)
- **Image**: `khaledhawil/ui:1.0.0`
- **Port**: 3000 (Express server port)

### Environment Variables
1. **AUTH_HOST**: Authentication service hostname (`weatherapp-auth`)
2. **AUTH_PORT**: Authentication service port (`8080`)
3. **WEATHER_HOST**: Weather service hostname (`weatherapp-weather`)
4. **WEATHER_PORT**: Weather service port (`5000`)

### Application Features
The UI service provides:
1. **Web Interface**: HTML pages for user interaction
2. **User Authentication**: Registration and login forms
3. **Weather Dashboard**: Interface for weather queries
4. **Session Management**: JWT token handling
5. **API Orchestration**: Coordinates backend service calls

### Health Checks
1. **Liveness Probe**: HTTP GET request to `/health` endpoint
2. **Readiness Probe**: HTTP GET request to `/health` endpoint
3. **Probe Benefits**:
   - Kubernetes monitors service health
   - Automatic pod restart on failures
   - Traffic only routed to healthy pods

### Technology Stack
- **Runtime**: Node.js
- **Framework**: Express.js web framework
- **Templates**: EJS templating engine
- **Security**: JWT token validation, rate limiting
- **Logging**: Winston logging framework

## Web Pages Served
- **Home Page**: Main dashboard interface
- **Login Page**: User authentication form
- **Registration Page**: New user signup form
- **Weather Page**: Weather data display interface

## Service Integration
The UI service integrates with:
1. **Authentication Service**: User login/registration
2. **Weather Service**: Weather data retrieval
3. **Frontend Assets**: Static files (CSS, JS, images)

### Request Flow
```
User → UI Service → Authentication/Weather Services → External APIs
```

## Security Features
1. **JWT Validation**: Verifies user authentication tokens
2. **Rate Limiting**: Prevents API abuse
3. **CORS Configuration**: Controlled cross-origin access
4. **Input Validation**: Sanitizes user inputs
5. **Session Security**: Secure cookie handling

## Static Assets
Serves static files including:
- CSS stylesheets
- JavaScript files
- Images and icons
- Favicon and web manifest

## High Availability
- **Multiple Replicas**: 2 instances for redundancy
- **Load Balancing**: Service distributes traffic
- **Rolling Updates**: Zero-downtime deployments
- **Health Monitoring**: Automatic failure detection

## Deployment Command
```bash
kubectl apply -f ui/deployment.yaml
```

## Verification
Check deployment status:
```bash
kubectl get deployment release-name-weatherapp-ui
kubectl get pods -l app.kubernetes.io/name=weatherapp-ui
kubectl logs deployment/release-name-weatherapp-ui
```

## Dependencies
This deployment requires:
1. Authentication service running
2. Weather service running
3. Backend services accessible via service names

## User Experience
Provides complete web interface for:
- User account management
- Weather data visualization
- Responsive design for mobile/desktop
- Real-time weather updates
