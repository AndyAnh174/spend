#!/bin/bash

# Test script for Ubuntu server
echo "========================================"
echo "Testing Spend Management App on Server"
echo "========================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi

echo "✅ Docker is running"

# Check if files exist
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ docker-compose.prod.yml not found"
    exit 1
fi

if [ ! -f "backend/go.mod" ]; then
    echo "❌ backend/go.mod not found"
    exit 1
fi

if [ ! -f "backend/go.sum" ]; then
    echo "❌ backend/go.sum not found"
    exit 1
fi

if [ ! -f "backend/main.go" ]; then
    echo "❌ backend/main.go not found"
    exit 1
fi

if [ ! -f "ai-service/main.py" ]; then
    echo "❌ ai-service/main.py not found"
    exit 1
fi

echo "✅ All required files found"

# Test Ollama connection
echo "Testing Ollama connection..."
if curl -s http://olla.hcmutertic.com/api/tags > /dev/null; then
    echo "✅ Ollama connection successful"
else
    echo "❌ Ollama connection failed"
    exit 1
fi

# Build and test backend
echo "Building backend..."
cd backend
if docker build -t spend-backend-test .; then
    echo "✅ Backend build successful"
else
    echo "❌ Backend build failed"
    exit 1
fi
cd ..

# Build and test AI service
echo "Building AI service..."
cd ai-service
if docker build -t spend-ai-test .; then
    echo "✅ AI service build successful"
else
    echo "❌ AI service build failed"
    exit 1
fi
cd ..

# Test with docker-compose
echo "Testing with docker-compose..."
if docker-compose -f docker-compose.prod.yml up -d mongodb; then
    echo "✅ MongoDB started successfully"
    sleep 5
    
    # Test MongoDB connection
    if docker exec spend-mongodb-prod mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
        echo "✅ MongoDB connection successful"
    else
        echo "❌ MongoDB connection failed"
    fi
    
    # Stop MongoDB
    docker-compose -f docker-compose.prod.yml down
else
    echo "❌ MongoDB start failed"
    exit 1
fi

echo ""
echo "========================================"
echo "✅ All tests passed!"
echo "========================================"
echo ""
echo "Your server is ready for deployment!"
echo "Run: ./deploy.sh your-domain.com your-email@domain.com"
echo ""
