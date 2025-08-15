#!/bin/bash

echo "========================================"
echo "Fixing Go.sum checksum mismatch"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "backend/go.mod" ]; then
    echo "❌ backend/go.mod not found. Please run this script from project root."
    exit 1
fi

echo "✅ Found backend/go.mod"

# Remove existing go.sum
if [ -f "backend/go.sum" ]; then
    echo "Removing existing go.sum..."
    rm backend/go.sum
fi

# Go to backend directory
cd backend

echo "Generating new go.sum..."
go mod tidy
go mod download

if [ $? -eq 0 ]; then
    echo "✅ go.sum generated successfully"
else
    echo "❌ Failed to generate go.sum"
    exit 1
fi

# Go back to root
cd ..

echo "✅ Go.sum checksum issue fixed!"
echo ""
echo "Now you can run:"
echo "docker-compose -f docker-compose.prod.yml build backend"
echo ""
