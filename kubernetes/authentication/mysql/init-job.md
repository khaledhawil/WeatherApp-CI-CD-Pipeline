# MySQL Initialization Job Configuration

## Overview
This file defines a Kubernetes Job that initializes the MySQL database with required schema and user permissions.

## File: `authentication/mysql/init-job.yaml`

## What it does
- Waits for MySQL to be ready and accepting connections
- Creates the application database and user
- Sets up proper permissions for the authentication service
- Runs as a one-time initialization task

## Configuration Details

### Job Specifications
- **Name**: `mysql-init-job`
- **Image**: `mysql:5.7` (same as MySQL server)
- **Restart Policy**: `Never` (job runs once)
- **Backoff Limit**: 3 (retry up to 3 times if failed)

### Environment Variables
1. **MYSQL_ROOT_PASSWORD**: Root password from secret
2. **MYSQL_AUTH_PASSWORD**: Application user password from secret
3. **MYSQL_USER**: Application username (`authuser`)
4. **MYSQL_HOST**: MySQL server hostname (`mysql-0.mysql`)
5. **MYSQL_PORT**: MySQL port (`3306`)

### Initialization Process
The job performs these steps:
1. **Wait for MySQL**: Checks if MySQL is ready to accept connections
2. **Connect as Root**: Uses root credentials to perform admin tasks
3. **Create Database**: Creates `weatherapp` database if it doesn't exist
4. **Create User**: Creates application user with proper permissions
5. **Grant Permissions**: Gives full access to the weatherapp database
6. **Flush Privileges**: Applies the permission changes

### SQL Commands Executed
```sql
CREATE DATABASE IF NOT EXISTS weatherapp;
CREATE USER IF NOT EXISTS 'authuser'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON weatherapp.* TO 'authuser'@'%';
FLUSH PRIVILEGES;
```

### Resource Management
- **Requests**: 128Mi memory, 100m CPU
- **Limits**: 256Mi memory, 200m CPU
- Lightweight resources for initialization task

## Why Use a Job
Jobs are perfect for initialization tasks because:
1. **One-time Execution**: Runs until completion then stops
2. **Completion Tracking**: Kubernetes tracks success/failure
3. **Retry Logic**: Automatically retries on failure
4. **Clean Shutdown**: Removes completed pods automatically

## Wait Logic
The job includes intelligent waiting:
- Continuously checks MySQL availability before proceeding
- Uses `mysql` client to test connection
- Prevents race conditions with MySQL startup
- Shows progress messages for debugging

## Deployment Command
```bash
kubectl apply -f authentication/mysql/init-job.yaml
```

## Monitoring
Check job progress:
```bash
kubectl get jobs
kubectl logs job/mysql-init-job
kubectl describe job mysql-init-job
```

## Success Indicators
- Job status shows `Complete`
- Logs show "Database initialization completed!"
- Authentication service can connect to database
