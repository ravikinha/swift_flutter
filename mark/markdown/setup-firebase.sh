#!/bin/bash

# Firebase Setup Script for swift_flutter Learning Guide
# This script helps you set up Firebase Hosting

set -e

echo "🔥 Firebase Hosting Setup for swift_flutter Learning Guide"
echo "=========================================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "   Installing Firebase CLI..."
    npm install -g firebase-tools
fi

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "⚠️  Not logged in to Firebase."
    echo "   Please run: firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready!"
echo ""

# Show available projects
echo "📋 Your Firebase Projects:"
firebase projects:list
echo ""

# Ask user to select or create project
echo "Choose an option:"
echo "1. Use an existing project"
echo "2. Create a new project"
read -p "Enter choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    read -p "Enter the Project ID (e.g., chats-7bfac): " project_id
    firebase use "$project_id"
    echo "✅ Project set to: $project_id"
elif [ "$choice" == "2" ]; then
    echo "🌐 Opening Firebase Console to create a new project..."
    echo "   After creating the project, run: firebase use <project-id>"
    open "https://console.firebase.google.com/"
    read -p "Enter the new Project ID: " project_id
    firebase use "$project_id"
    echo "✅ Project set to: $project_id"
else
    echo "❌ Invalid choice"
    exit 1
fi

echo ""
echo "📦 Building Flutter web app..."
flutter clean
flutter pub get
flutter build web --release

if [ ! -d "build/web" ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""
echo "🚀 Ready to deploy!"
echo "   Run: firebase deploy --only hosting"
echo ""

