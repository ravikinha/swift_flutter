#!/bin/bash

# Script to connect to Firebase project and deploy

echo "🔥 Connecting to Firebase Project"
echo "=================================="
echo ""

# Refresh project list
echo "📋 Fetching your Firebase projects..."
firebase projects:list

echo ""
echo "Please enter the exact Project ID for 'swiftflutter':"
echo "(It might be 'swiftflutter' or 'swiftflutter-xxxxx' format)"
read -p "Project ID: " project_id

if [ -z "$project_id" ]; then
    echo "❌ Project ID cannot be empty"
    exit 1
fi

echo ""
echo "🔗 Setting Firebase project to: $project_id"
firebase use "$project_id"

if [ $? -eq 0 ]; then
    echo "✅ Project set successfully!"
    echo ""
    echo "🚀 Ready to deploy!"
    echo "   Your app will be available at: https://$project_id.web.app"
    echo ""
    read -p "Deploy now? (y/n): " deploy_now
    
    if [ "$deploy_now" == "y" ] || [ "$deploy_now" == "Y" ]; then
        echo ""
        echo "📦 Building Flutter web app..."
        flutter build web --release
        
        if [ ! -d "build/web" ]; then
            echo "❌ Build failed!"
            exit 1
        fi
        
        echo "✅ Build successful!"
        echo ""
        echo "🔥 Deploying to Firebase Hosting..."
        firebase deploy --only hosting
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "🎉 Deployment successful!"
            echo "🌐 Your app is live at: https://$project_id.web.app"
            echo ""
            echo "Next steps:"
            echo "1. Go to Firebase Console → Hosting"
            echo "2. Click 'Add custom domain'"
            echo "3. Enter your GoDaddy domain"
            echo "4. Follow the DNS setup instructions"
        fi
    else
        echo ""
        echo "To deploy later, run:"
        echo "  flutter build web --release"
        echo "  firebase deploy --only hosting"
    fi
else
    echo "❌ Failed to set project. Please check the Project ID."
    echo ""
    echo "To find your Project ID:"
    echo "1. Go to https://console.firebase.google.com/"
    echo "2. Select your 'swiftflutter' project"
    echo "3. Go to Project Settings"
    echo "4. Copy the 'Project ID'"
fi

