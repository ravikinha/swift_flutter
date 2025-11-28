# GoDaddy Domain Setup for swift_flutter Learning Guide

Your app is now live at: **https://swiftflutter-5f86b.web.app**

## Step 1: Add Custom Domain in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/project/swiftflutter-5f86b/hosting)
2. Click **"Add custom domain"** button
3. Enter your domain name (e.g., `swiftflutter.com` or `learn.swiftflutter.com`)
4. Click **"Continue"**

## Step 2: Get DNS Records from Firebase

Firebase will show you DNS records that need to be added. You'll see something like:

**For Root Domain (swiftflutter.com):**
```
Type: A
Name: @
Value: 151.101.1.195
TTL: 3600

Type: A
Name: @
Value: 151.101.65.195
TTL: 3600
```

**For Subdomain (learn.swiftflutter.com):**
```
Type: CNAME
Name: learn
Value: swiftflutter-5f86b.web.app
TTL: 3600
```

## Step 3: Add DNS Records in GoDaddy

1. **Log in to GoDaddy**
   - Go to https://www.godaddy.com/
   - Sign in to your account

2. **Navigate to DNS Management**
   - Go to **"My Products"**
   - Find your domain and click **"DNS"** or **"Manage DNS"**

3. **Add A Records (for root domain)**
   - Click **"Add"** to create a new record
   - Select **Type: A**
   - **Name/Host:** `@` (or leave blank for root domain)
   - **Value/Points to:** Enter the first IP address from Firebase
   - **TTL:** 3600 (or 1 hour)
   - Click **"Save"**
   - Repeat for the second A record with the second IP address

4. **Add CNAME Record (for subdomain)**
   - Click **"Add"** to create a new record
   - Select **Type: CNAME**
   - **Name/Host:** `learn` (or your desired subdomain)
   - **Value/Points to:** `swiftflutter-5f86b.web.app`
   - **TTL:** 3600
   - Click **"Save"**

## Step 4: Verify Domain in Firebase

1. Go back to Firebase Console → Hosting → Custom domains
2. Firebase will automatically verify your domain
3. This process can take a few minutes to a few hours

## Step 5: SSL Certificate

Firebase automatically provisions SSL certificates for custom domains. This usually takes:
- **Verification:** 5-30 minutes
- **SSL Certificate:** 1-24 hours

You'll receive an email when the SSL certificate is ready.

## Step 6: Verify Your Domain is Live

Once DNS has propagated and SSL is ready:
- Visit your custom domain (e.g., `https://swiftflutter.com`)
- The app should load correctly

## Troubleshooting

### DNS Not Propagating
- DNS changes can take 24-48 hours to propagate globally
- Check propagation status: https://www.whatsmydns.net/
- Use Google's DNS (8.8.8.8) or Cloudflare (1.1.1.1) for faster updates

### Domain Not Connecting
- Verify DNS records are correctly added in GoDaddy
- Ensure TTL is set correctly
- Wait for DNS propagation
- Check Firebase Console for any error messages

### SSL Certificate Issues
- Wait for Firebase to automatically provision SSL
- Check Firebase Console → Hosting → Custom domains for status
- Ensure DNS records are correct before SSL provisioning

## Quick Reference

- **Firebase Project ID:** `swiftflutter-5f86b`
- **Firebase Hosting URL:** `https://swiftflutter-5f86b.web.app`
- **Firebase Console:** https://console.firebase.google.com/project/swiftflutter-5f86b/hosting

## Need Help?

- Firebase Hosting Docs: https://firebase.google.com/docs/hosting
- GoDaddy DNS Help: https://www.godaddy.com/help/manage-dns-680

