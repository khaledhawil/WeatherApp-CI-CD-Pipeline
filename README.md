# Kubernetes Weather Application

A comprehensive microservices-based weather application deployed on Kubernetes, featuring user authentication, weather data retrieval, and a responsive web interface.

## Architecture Overview

This application consists of four main components:

1. **Authentication Service** (Go) - Handles user registration, login, and JWT token management
2. **Weather Service** (Python/Flask) - Fetches weather data from external APIs
3. **UI Service** (Node.js/Express) - Serves the web interface and handles user interactions
4. **MySQL Database** - Stores user authentication data

## Project Structure

```
k8s-course-lab/
├── auth/                           # Authentication service (Go)
│   ├── Dockerfile
│   ├── go.mod
│   ├── go.sum
│   ├── main/
│   │   └── main.go
│   └── authdb/
│       └── authdb.go
├── weather/                        # Weather service (Python)
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── UI/                            # Frontend service (Node.js)
│   ├── Dockerfile
│   ├── app.js
│   ├── package.json
│   └── public/
│       ├── index.html
│       ├── login.html
│       ├── signup.html
│       └── static/
├── mysql-init/
│   └── init.sql
└── kubernetes/                    # Kubernetes manifests
    ├── authentication/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── mysql/
    │       ├── statefulset.yaml
    │       ├── headless-service.yaml
    │       ├── secret.yaml
    │       ├── init-job.yaml
    │       └── deployment scripts
    ├── weather/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── secret.yaml
    └── ui/
        ├── deployment.yaml
        ├── service.yaml
        ├── ingress.yaml
        ├── tls.crt
        └── tls.key
```

## Prerequisites

- Kubernetes cluster (this project uses DigitalOcean Kubernetes, but any Kubernetes cluster will work with some configuration adjustments)
- kubectl configured to connect to your cluster
- Docker images built and pushed to a container registry
- OpenWeatherMap API key (for weather service)

**Note**: While this application can run on any Kubernetes cluster, you may need to modify certain configurations in the Kubernetes manifests based on your cluster setup:
- Storage class names (currently set to `do-block-storage` for DigitalOcean)
- Ingress controller configuration
- Load balancer service types
- Node selector requirements

## Services Overview

### Authentication Service (Go)
- **Port**: 8080
- **Endpoints**:
  - `POST /signup` - User registration
  - `POST /login` - User authentication
  - `GET /health` - Health check
- **Database**: MySQL
- **Authentication**: JWT tokens with MD5 password hashing

### Weather Service (Python)
- **Port**: 5000
- **Endpoints**:
  - `GET /` - Health check
  - `GET /weather/{city}` - Get weather data for a city
- **External API**: OpenWeatherMap API
- **Framework**: Flask with CORS support

### UI Service (Node.js)
- **Port**: 3000
- **Features**:
  - User registration and login forms
  - Weather dashboard
  - JWT token handling
  - Rate limiting and security middleware
- **Framework**: Express.js with EJS templating

### MySQL Database
- **Port**: 3306
- **Database**: weatherapp
- **User**: authuser
- **Storage**: Persistent volume (10Gi)

## Deployment Instructions

**Important**: Before deploying, review and adjust the Kubernetes manifests for your specific cluster:

### Cluster-Specific Configurations

1. **Storage Class**: Update `storageClassName` in MySQL StatefulSet
   ```bash
   # For AWS EKS
   storageClassName: "gp2"
   
   # For Google GKE
   storageClassName: "standard"
   
   # For DigitalOcean (current setting)
   storageClassName: "do-block-storage"
   ```

2. **Ingress Controller**: Modify ingress annotations based on your setup
   ```bash
   # For NGINX Ingress Controller
   kubernetes.io/ingress.class: "nginx"
   
   # For AWS ALB
   kubernetes.io/ingress.class: "alb"
   ```

3. **Service Types**: Adjust service types based on your cluster capabilities
   - LoadBalancer services may need different configurations
   - Some clusters may require NodePort instead

### 1. Setup MySQL Database

```bash
# Deploy MySQL components
cd kubernetes/authentication/mysql
./deploy-mysql.sh
```

The MySQL deployment includes:
- StatefulSet with persistent storage
- Headless service for internal communication
- Secrets for database credentials
- Initialization job for database setup

### 2. Deploy Authentication Service

```bash
# Apply authentication service manifests
kubectl apply -f kubernetes/authentication/deployment.yaml
kubectl apply -f kubernetes/authentication/service.yaml
```

### 3. Deploy Weather Service

```bash
# Create weather service secret with API key
kubectl create secret generic weather-secret \
  --from-literal=api-key='your-openweathermap-api-key'

# Apply weather service manifests
kubectl apply -f kubernetes/weather/deployment.yaml
kubectl apply -f kubernetes/weather/service.yaml
```

### 4. Deploy UI Service

```bash
# Apply UI service manifests
kubectl apply -f kubernetes/ui/deployment.yaml
kubectl apply -f kubernetes/ui/service.yaml
kubectl apply -f kubernetes/ui/ingress.yaml
```

## Environment Variables

### Authentication Service
- `DB_HOST`: MySQL host (default: mysql-0.mysql)
- `DB_USER`: Database user (default: authuser)
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name (default: weatherapp)
- `SECRET_KEY`: JWT signing key

### Weather Service
- `API_KEY`: OpenWeatherMap API key
- `PORT`: Service port (default: 5000)

### UI Service
- `PORT`: Service port (default: 3000)
- `SECRET_KEY`: JWT secret key
- `WEATHER_HOST`: Weather service host
- `WEATHER_PORT`: Weather service port
- `AUTH_HOST`: Authentication service host
- `AUTH_PORT`: Authentication service port

## Secrets Management

The application uses Kubernetes secrets for sensitive data:

```bash
# MySQL credentials
kubectl create secret generic mysql-secret \
  --from-literal=root-password='secure-root-pw' \
  --from-literal=auth-password='my-secret-pw' \
  --from-literal=secret-key='xco0sr0fh4e52x03g9mv'

# Weather API key
kubectl create secret generic weather-secret \
  --from-literal=api-key='your-api-key'
```

## Networking

- **MySQL**: Internal communication via headless service `mysql`
- **Authentication**: Exposed via ClusterIP service `auth-service`
- **Weather**: Exposed via ClusterIP service `weather-service`
- **UI**: Exposed via LoadBalancer service and Ingress

## Persistence

- MySQL data is persisted using a PersistentVolumeClaim
- Storage class: `do-block-storage` (for DigitalOcean) - adjust for your cluster's storage class
- Volume size: 10Gi

## Monitoring and Health Checks

All services include:
- Liveness probes for container health
- Readiness probes for service availability
- Resource limits and requests
- Proper logging and error handling

## Security Features

- JWT-based authentication
- CORS configuration
- Rate limiting on UI service
- Secure secret management
- TLS termination at ingress

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Services
```bash
kubectl get services
kubectl describe service <service-name>
```

### Check Database Connection
```bash
kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- \
  mysql -h mysql-0.mysql -u authuser -p
```

### Common Issues

1. **MySQL Pod CrashLoopBackOff**
   - Check persistent volume data
   - Run cleanup job if needed
   - Verify secret values

2. **Authentication Service Connection Issues**
   - Verify MySQL service is running
   - Check database credentials
   - Ensure database initialization completed

3. **Weather Service API Errors**
   - Verify API key is correct
   - Check external network connectivity
   - Review rate limiting on API provider

## Scaling

The application supports horizontal scaling:

```bash
# Scale authentication service
kubectl scale deployment auth-service --replicas=3

# Scale weather service
kubectl scale deployment weather-service --replicas=2

# Scale UI service
kubectl scale deployment ui-service --replicas=2
```

## Cleanup

To remove all application components:

```bash
# Clean up UI components
kubectl delete -f kubernetes/ui/

# Clean up weather components
kubectl delete -f kubernetes/weather/

# Clean up authentication components
kubectl delete -f kubernetes/authentication/

# Clean up MySQL components
cd kubernetes/authentication/mysql
./cleanup-mysql.sh
```

## Development

### Building Docker Images

```bash
# Build authentication service
cd auth
docker build -t your-registry/weather-auth:latest .

# Build weather service
cd weather
docker build -t your-registry/weather-service:latest .

# Build UI service
cd UI
docker build -t your-registry/weather-ui:latest .
```

### Local Development

Each service can be run locally for development:

```bash
# Authentication service
cd auth
go run main/main.go

# Weather service
cd weather
python main.py

# UI service
cd UI
npm install
npm start
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions, please create an issue in the project repository.
