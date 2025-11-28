#!/bin/bash

# Deployment script for Firebase Hosting
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 Starting deployment process..."

# Navigate to project directory
cd "$(dirname "$0")"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "⚠️  Not logged in to Firebase. Please run: firebase login"
    exit 1
fi

echo "📦 Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

if [ ! -d "build/web" ]; then
    echo "❌ Build failed. build/web directory not found."
    exit 1
fi

echo "✅ Build successful!"

echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌐 Your app should be live at: https://$(firebase use | grep 'Now using' | awk '{print $3}').web.app"

