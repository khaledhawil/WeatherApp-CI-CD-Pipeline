# Weather Service Configuration

## Overview
This file defines a Kubernetes Service that exposes the weather deployment within the cluster for internal communication.

## File: `weather/service.yaml`

## What it does
- Creates a ClusterIP service for the weather deployment
- Enables internal cluster communication on port 5000
- Provides stable network endpoint for weather API access
- Load balances traffic across weather service replicas

## Configuration Details

### Service Specifications
- **Name**: `weatherapp-weather`
- **Type**: `ClusterIP` (internal cluster access only)
- **Port**: 5000 (Flask application port)
- **Target Port**: `http` (named port from deployment)
- **Protocol**: TCP

### Service Discovery
Other services can access weather service using:
- **Service Name**: `weatherapp-weather`
- **Full DNS**: `weatherapp-weather.default.svc.cluster.local`
- **Port**: 5000
- **Example URL**: `http://weatherapp-weather:5000`

### Load Balancing Features
The service provides:
1. **Traffic Distribution**: Balances requests across 2 replicas
2. **Health Checking**: Routes only to healthy pods
3. **Service Discovery**: Stable endpoint for weather queries
4. **Automatic Failover**: Handles pod failures gracefully

## Why ClusterIP
ClusterIP is chosen because:
1. **Internal API**: Weather service is accessed by UI service only
2. **Security**: No direct external access required
3. **Performance**: Efficient cluster networking
4. **Simplicity**: Direct service-to-service communication

## Usage by UI Service
The UI service uses this weather service to:
- Fetch weather data for user requests
- Handle city-based weather queries
- Display current weather conditions
- Process weather API responses

## Network Flow
```
UI Service → weatherapp-weather:5000 → Weather Pod(s) → OpenWeatherMap API
```

## Service Selector
Uses label selector to find pods:
- **Label**: `app.kubernetes.io/name: weatherapp-weather`
- Matches pods created by the weather deployment

## Named Port Configuration
- **Port Name**: `http`
- **Container Port**: 5000
- **Service Port**: 5000
- Enables flexible port management

## High Availability
With 2 replicas behind the service:
- **Redundancy**: Service continues if one pod fails
- **Load Distribution**: Requests spread across instances
- **Zero Downtime**: Rolling updates without service interruption

## Deployment Command
```bash
kubectl apply -f weather/service.yaml
```

## Verification
Check service status:
```bash
kubectl get svc weatherapp-weather
kubectl describe svc weatherapp-weather
kubectl get endpoints weatherapp-weather
```

## Testing Connectivity
Test weather service from within cluster:
```bash
kubectl run test-pod --image=curlimages/curl -it --rm -- sh
curl http://weatherapp-weather:5000/
curl http://weatherapp-weather:5000/weather/London
```
