#!/bin/bash

# GitHub Actions CI/CD Workflow Test Script
# This script helps test the workflow setup and verify secrets

set -e

echo "🔍 GitHub Actions CI/CD Setup Verification"
echo "============================================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Check if GitHub Actions workflow exists
if [ -f ".github/workflows/ci-cd.yml" ]; then
    echo "✅ GitHub Actions workflow found"
else
    echo "❌ GitHub Actions workflow not found"
    exit 1
fi

# Check if service directories exist
services=("auth" "weather" "UI")
for service in "${services[@]}"; do
    if [ -d "$service" ]; then
        echo "✅ $service directory found"
    else
        echo "❌ $service directory not found"
    fi
done

# Check if Dockerfiles exist
for service in "${services[@]}"; do
    if [ -f "$service/Dockerfile" ]; then
        echo "✅ $service/Dockerfile found"
    else
        echo "❌ $service/Dockerfile not found"
    fi
done

# Check if deployment manifests exist
deployments=(
    "kubernetes/authentication/deployment.yaml"
    "kubernetes/weather/deployment.yaml"
    "kubernetes/ui/deployment.yaml"
)

for deployment in "${deployments[@]}"; do
    if [ -f "$deployment" ]; then
        echo "✅ $deployment found"
    else
        echo "❌ $deployment not found"
    fi
done

echo ""
echo "📋 Required GitHub Secrets:"
echo "DOCKERHUB_USERNAME=khaledhawil"
echo "DOCKERHUB_TOKEN=<your_dockerhub_access_token>"
echo ""
echo "🔧 Setup Instructions:"
echo "1. Go to your GitHub repository"
echo "2. Navigate to Settings → Secrets and variables → Actions"
echo "3. Add the required secrets listed above"
echo "4. Generate DockerHub token at: https://hub.docker.com/settings/security"
echo ""
echo "📖 Documentation:"
echo "- Complete guide: docs/ci-cd-workflow.md"
echo "- Secrets setup: docs/github-secrets.md"
echo ""
echo "🧪 Test the workflow:"
echo "1. Make a small change to any service (auth/, weather/, UI/)"
echo "2. Commit and push to main/master branch"
echo "3. Check GitHub Actions tab for workflow execution"
echo ""
echo "🎯 Workflow Features:"
echo "- Selective building (only changed services)"
echo "- Automatic Docker image tagging"
echo "- Kubernetes manifest updates"
echo "- CI loop prevention with [skip ci]"
echo ""
echo "✅ Setup verification complete!"
