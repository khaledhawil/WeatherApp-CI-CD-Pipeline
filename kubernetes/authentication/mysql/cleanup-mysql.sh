#!/bin/bash

# MySQL Cleanup Script
echo "=== Cleaning up MySQL components ==="

echo "1. Deleting MySQL Init Job..."
kubectl delete job mysql-init-job --ignore-not-found=true

echo "2. Deleting MySQL StatefulSet..."
kubectl delete statefulset mysql --ignore-not-found=true

echo "3. Deleting MySQL Service..."
kubectl delete service mysql --ignore-not-found=true

echo "4. Deleting MySQL Secret..."
kubectl delete secret mysql-secret --ignore-not-found=true

echo "5. Deleting MySQL PVC..."
kubectl delete pvc mysql-persistent-storage-mysql-0 --ignore-not-found=true

echo "✅ MySQL cleanup completed!"
