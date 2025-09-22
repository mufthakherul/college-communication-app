#!/bin/bash

# Campus Mesh Deployment Script
# This script handles deployment to different environments

set -e

ENVIRONMENT=${1:-staging}
VALID_ENVIRONMENTS="staging production"

if [[ ! " $VALID_ENVIRONMENTS " =~ " $ENVIRONMENT " ]]; then
    echo "❌ Invalid environment. Use: staging or production"
    exit 1
fi

echo "🚀 Deploying Campus Mesh to $ENVIRONMENT..."

# Set Firebase project based on environment
firebase use $ENVIRONMENT

# Build and lint functions
echo "🔨 Building Firebase Functions..."
cd functions
npm run lint
npm run build
cd ..

# Deploy Firestore rules and indexes
echo "📊 Deploying Firestore rules and indexes..."
firebase deploy --only firestore

# Deploy Storage rules
echo "💾 Deploying Storage rules..."
firebase deploy --only storage

# Deploy Functions
echo "⚡ Deploying Firebase Functions..."
firebase deploy --only functions

# Deploy Remote Config
echo "⚙️ Deploying Remote Config..."
firebase deploy --only remoteconfig

echo "✅ Deployment to $ENVIRONMENT completed successfully!"

if [ "$ENVIRONMENT" = "production" ]; then
    echo "🎉 Campus Mesh is now live in production!"
    echo "📱 Don't forget to update the mobile app configuration for production"
else
    echo "🧪 Campus Mesh staging environment is ready for testing"
fi