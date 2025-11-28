# Firebase Hosting Deployment Guide

This guide will help you deploy the swift_flutter Learning Guide web app to Firebase Hosting and connect it to your GoDaddy domain.

## Prerequisites

1. **Firebase Account**: Create a free account at [Firebase Console](https://console.firebase.google.com/)
2. **Firebase CLI**: Already installed (if not, run `npm install -g firebase-tools`)
3. **GoDaddy Domain**: Your purchased domain ready for configuration

## Step 1: Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "swift-flutter-learning")
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

4. Once created, note your **Project ID** (you'll need this)

## Step 2: Configure Firebase Project

1. Open terminal and navigate to the project:
   ```bash
   cd mark/markdown
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```
   This will open a browser window for authentication.

3. Update `.firebaserc` with your actual Firebase Project ID:
   ```json
   {
     "projects": {
       "default": "your-actual-project-id"
     }
   }
   ```

## Step 3: Build and Deploy

1. Build the Flutter web app:
   ```bash
   flutter build web --release
   ```

2. Deploy to Firebase Hosting:
   ```bash
   firebase deploy --only hosting
   ```

3. Your app will be live at: `https://your-project-id.web.app`

## Step 4: Connect GoDaddy Domain

### Option A: Using Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Hosting** in the left sidebar
4. Click **"Add custom domain"**
5. Enter your domain name (e.g., `swiftflutter.com` or `learn.swiftflutter.com`)
6. Firebase will provide you with DNS records to add

### Option B: Manual DNS Configuration

1. In Firebase Console → Hosting → Custom domains, add your domain
2. Firebase will show you DNS records like:
   ```
   Type: A
   Name: @
   Value: 151.101.1.195 (example IP)
   
   Type: A
   Name: @
   Value: 151.101.65.195 (example IP)
   ```

3. **In GoDaddy DNS Settings:**
   - Log in to GoDaddy
   - Go to **My Products** → **DNS** (or **Manage DNS**)
   - Add the A records provided by Firebase
   - For subdomain (e.g., `learn.swiftflutter.com`), add:
     - Type: **CNAME**
     - Name: `learn` (or your subdomain)
     - Value: `your-project-id.web.app` (Firebase hosting URL)

### DNS Record Types:

- **A Records** (for root domain): Point to Firebase IP addresses
- **CNAME Record** (for subdomain): Point to `your-project-id.web.app`

## Step 5: SSL Certificate

Firebase automatically provisions SSL certificates for custom domains. This usually takes a few minutes to a few hours.

1. Wait for Firebase to verify your domain
2. SSL certificate will be automatically issued
3. Your site will be accessible via HTTPS

## Step 6: Verify Deployment

1. Visit your custom domain (e.g., `https://swiftflutter.com`)
2. Verify the app loads correctly
3. Test navigation and all features

## Troubleshooting

### DNS Propagation
- DNS changes can take 24-48 hours to propagate globally
- Use [whatsmydns.net](https://www.whatsmydns.net/) to check propagation status

### Firebase Hosting Not Working
- Ensure `firebase.json` points to `build/web`
- Verify the build completed successfully
- Check Firebase Console for deployment errors

### Domain Not Connecting
- Verify DNS records are correctly added in GoDaddy
- Wait for DNS propagation
- Check Firebase Console for domain verification status

## Quick Deploy Script

For future deployments, you can use:

```bash
#!/bin/bash
cd mark/markdown
flutter build web --release
firebase deploy --only hosting
```

## Continuous Deployment

To set up automatic deployments on git push:

1. Install GitHub Actions or similar CI/CD
2. Add workflow file (`.github/workflows/deploy.yml`)
3. Configure Firebase token: `firebase login:ci`
4. Add token as GitHub secret

## Support

For issues:
- Firebase Documentation: https://firebase.google.com/docs/hosting
- Flutter Web: https://flutter.dev/web

