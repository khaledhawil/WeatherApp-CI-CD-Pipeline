# Weather Service Deployment Configuration

## Overview
This file defines a Kubernetes Deployment for the weather service written in Python Flask, which fetches weather data from external APIs.

## File: `weather/deployment.yaml`

## What it does
- Deploys a Python Flask application for weather data retrieval
- Integrates with OpenWeatherMap API for real-time weather information
- Provides scalable weather service with multiple replicas
- Handles weather queries for various cities worldwide

## Configuration Details

### Deployment Specifications
- **Name**: `weatherapp-weather`
- **Replicas**: 2 (two instances for availability)
- **Image**: `khaledhawil/weather:1.0.0`
- **Port**: 5000 (Flask default port)

### Environment Variables
- **APIKEY**: OpenWeatherMap API key from Kubernetes secret
- Retrieved from `weather` secret using `secretKeyRef`

### Application Features
The weather service provides:
1. **Weather Lookup**: Get current weather by city name
2. **API Integration**: Real-time data from OpenWeatherMap
3. **JSON Responses**: Structured weather data output
4. **Error Handling**: Graceful handling of API failures
5. **CORS Support**: Cross-origin requests from web frontend

### Health Checks
1. **Liveness Probe**: HTTP GET request to `/` endpoint
2. **Readiness Probe**: HTTP GET request to `/` endpoint
3. **Probe Configuration**:
   - Initial delay for service startup
   - Periodic checks for service health
   - Timeout and failure thresholds

### Technology Stack
- **Language**: Python 3
- **Framework**: Flask web framework
- **HTTP Client**: Requests library for API calls
- **CORS**: Flask-CORS for cross-origin support

## API Endpoints
- **GET /**: Health check endpoint
- **GET /weather/{city}**: Retrieve weather data for specified city

## External API Integration
Connects to OpenWeatherMap API:
- **Base URL**: `api.openweathermap.org`
- **Authentication**: API key in request parameters
- **Data Format**: JSON response with weather details
- **Rate Limits**: Managed by API key quotas

## Scaling Features
- **Multiple Replicas**: 2 instances for high availability
- **Load Balancing**: Traffic distributed across replicas
- **Horizontal Scaling**: Can increase replicas as needed
- **Resource Efficiency**: Lightweight Python containers

## Container Configuration
- **Image Pull Policy**: `IfNotPresent`
- **Port Mapping**: Container port 5000 exposed
- **Named Port**: `http` for service discovery

## Deployment Command
```bash
kubectl apply -f weather/deployment.yaml
```

## Verification
Check deployment status:
```bash
kubectl get deployment weatherapp-weather
kubectl get pods -l app.kubernetes.io/name=weatherapp-weather
kubectl logs deployment/weatherapp-weather
```

## Dependencies
This deployment requires:
1. Weather secret with API key
2. OpenWeatherMap API access
3. Internet connectivity for external API calls

## Scaling
Increase replicas for higher load:
```bash
kubectl scale deployment weatherapp-weather --replicas=3
```
