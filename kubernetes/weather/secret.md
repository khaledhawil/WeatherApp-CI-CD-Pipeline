# Weather Service Secret Configuration

## Overview
This file defines a Kubernetes Secret that stores the API key for external weather service integration.

## File: `weather/secret.yaml`

## What it does
- Stores the OpenWeatherMap API key securely
- Provides base64 encoded storage for sensitive API credentials
- Enables weather service to authenticate with external APIs

## Configuration Details

### Secret Specifications
- **Name**: `weather`
- **Type**: `Opaque` (generic secret type)
- **Data**: Contains base64 encoded API key

### Stored Data
- **apikey**: OpenWeatherMap API key (base64 encoded)
- **Encoded Value**: `NmQ5MmM1MGJkYW1zaDgxMTM3ZjNiODdhY2UxZnAxZDUzZWVqc25mZTgxOGI5ZGJjODM=`

## API Key Usage
The weather service uses this API key to:
1. **Fetch Weather Data**: Query current weather conditions
2. **City Lookup**: Search weather by city name
3. **API Authentication**: Authenticate with OpenWeatherMap service
4. **Rate Limiting**: Manage API usage limits

## External Service Integration
This secret enables integration with:
- **OpenWeatherMap API**: Primary weather data provider
- **RESTful API**: HTTP-based weather queries
- **JSON Responses**: Structured weather data
- **Rate Limiting**: API key tracks usage limits

## Security Features
1. **Base64 Encoding**: API key is encoded for storage
2. **Secret Storage**: Kubernetes manages secret securely
3. **Access Control**: Only authorized pods can access
4. **Environment Injection**: Loaded as environment variable

## Usage Pattern
The weather deployment references this secret:
```yaml
env:
- name: APIKEY
  valueFrom:
    secretKeyRef:
      key: apikey
      name: weather
```

## API Key Management
To update the API key:
1. Encode new key: `echo -n "new-api-key" | base64`
2. Update secret data field
3. Restart weather service pods

## Deployment Command
```bash
kubectl apply -f weather/secret.yaml
```

## Verification
Check secret creation:
```bash
kubectl get secret weather
kubectl describe secret weather
```

## Security Notes
- Keep API keys confidential
- Rotate keys regularly
- Monitor API usage
- Use dedicated keys per environment
