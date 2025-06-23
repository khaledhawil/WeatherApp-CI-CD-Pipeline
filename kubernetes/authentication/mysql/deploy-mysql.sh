#!/bin/bash

# MySQL Deployment Scr# 4. Wait for MySQL to be ready
echo "4. Waiting for MySQL pod to be ready..."
kubectl wait --for=condition=ready pod/mysql-0 --timeout=30s
if [ $? -eq 0 ]; thenfor DigitalOcean Kubernetes
echo "=== Deploying MySQL components to DigitalOcean Kubernetes ==="

# 1. Apply Secret first
echo "1. Creating MySQL Secret..."
kubectl apply -f authentication/mysql/secret.yaml
if [ $? -eq 0 ]; then
    echo "✅ MySQL Secret created successfully"
else
    echo "❌ Failed to create MySQL Secret"
    exit 1
fi

# 2. Apply Headless Service
echo "2. Creating MySQL Headless Service..."
kubectl apply -f authentication/mysql/headless-service.yaml
if [ $? -eq 0 ]; then
    echo "✅ MySQL Headless Service created successfully"
else
    echo "❌ Failed to create MySQL Headless Service"
    exit 1
fi

# 3. Apply StatefulSet
echo "3. Creating MySQL StatefulSet..."
kubectl apply -f authentication/mysql/statefulset.yaml
if [ $? -eq 0 ]; then
    echo "✅ MySQL StatefulSet created successfully"
else
    echo "❌ Failed to create MySQL StatefulSet"
    exit 1
fi

# 4. Wait for MySQL to be ready
echo "4. Waiting for MySQL pod to be ready..."
kubectl wait --for=condition=ready pod/mysql-0 --timeout=30s
if [ $? -eq 0 ]; then
    echo "✅ MySQL pod is ready"
else
    echo "❌ MySQL pod failed to become ready within 5 minutes"
    echo "Checking pod status:"
    kubectl get pods -l app=mysql
    kubectl describe pod mysql-0
    exit 1
fi

# 5. Apply Init Job
echo "5. Running MySQL initialization job..."
kubectl apply -f authentication/mysql/init-job.yaml
if [ $? -eq 0 ]; then
    echo "✅ MySQL initialization job created successfully"
else
    echo "❌ Failed to create MySQL initialization job"
    exit 1
fi

# 6. Wait for Init Job to complete
echo "6. Waiting for MySQL initialization job to complete..."
kubectl wait --for=condition=complete job/mysql-init-job --timeout=120s
if [ $? -eq 0 ]; then
    echo "✅ MySQL initialization completed successfully"
else
    echo "❌ MySQL initialization job failed"
    echo "Checking job status:"
    kubectl get jobs
    kubectl logs job/mysql-init-job
    exit 1
fi

echo ""
echo "=== MySQL Deployment Summary ==="
kubectl get pods -l app=mysql
kubectl get svc mysql
kubectl get pvc
kubectl get job mysql-init-job

echo ""
echo "🎉 MySQL deployment completed successfully!"
echo ""
echo "To test the connection:"
echo "kubectl run mysql-client --image=mysql:5.7 -it --rm --restart=Never -- mysql -h mysql-0.mysql -u authuser -p"
