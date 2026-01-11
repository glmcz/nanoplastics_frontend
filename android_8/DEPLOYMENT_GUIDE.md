# Deployment Guide - NanoSolve Hive

## 🚀 Quick Deploy to Vercel (Recommended)

### Step 1: Build Web Version
```bash
cd /Users/martindurak/Desktop/web_rust/nanoplastics/frontend/android_8

# Build for web
flutter build web
```

### Step 2: Deploy to Vercel
```bash
# Install Vercel CLI (one-time)
npm install -g vercel

# Navigate to build folder
cd build/web

# Deploy
vercel --prod
```

### Step 3: Share the URL
Vercel will output a URL like:
```
https://nanoplastics-xyz.vercel.app
```

Share this URL with anyone to view the app!

---

## 🌐 Alternative: GitHub Pages

### Step 1: Prepare Repository
```bash
cd /Users/martindurak/Desktop/web_rust/nanoplastics/frontend/android_8

# Create .gitignore if not exists
cat > .gitignore << 'EOF'
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
!build/web/

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws
EOF
```

### Step 2: Build for GitHub Pages
```bash
# Build with base href
flutter build web --base-href "/nanoplastics/"
```

### Step 3: Push to GitHub
```bash
git init
git add .
git commit -m "Deploy NanoSolve Hive prototype"
git branch -M main

# Create repository on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/nanoplastics.git
git push -u origin main
```

### Step 4: Enable GitHub Pages
1. Go to repository settings on GitHub
2. Navigate to **Pages** section
3. Source: Select **main** branch
4. Folder: Select **/ (root)**
5. Click **Save**

### Step 5: Access Your App
Wait 2-3 minutes, then visit:
```
https://YOUR_USERNAME.github.io/nanoplastics/
```

---

## 📱 Alternative: Android APK

### Step 1: Build APK
```bash
cd /Users/martindurak/Desktop/web_rust/nanoplastics/frontend/android_8

# Build release APK
flutter build apk --release
```

### Step 2: Locate APK
The APK file will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Share APK

#### Option A: Google Drive
1. Upload `app-release.apk` to Google Drive
2. Right-click → Get link → Change to "Anyone with the link"
3. Share the link

#### Option B: Firebase App Distribution
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (choose App Distribution)
firebase init

# Upload APK
firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups testers
```

#### Option C: Diawi (Quick Share)
1. Go to https://diawi.com
2. Upload `app-release.apk`
3. Get shareable link
4. Send link to testers

---

## 🔧 Quick Test Deployment

### Option 1: Local Network Share
```bash
# Run on local network
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

# Access from other devices on same WiFi:
# http://YOUR_LOCAL_IP:8080
```

### Option 2: ngrok Tunnel (Temporary)
```bash
# Terminal 1: Run Flutter
flutter run -d chrome --web-port=8080

# Terminal 2: Create public tunnel
brew install ngrok  # macOS
ngrok http 8080
```

ngrok provides temporary public URL like: `https://abc123.ngrok.io`

**⚠️ Warning:** ngrok link expires when you close the terminal!

---

## 📊 Deployment Comparison

| Method | Speed | Cost | Persistence | Best For |
|--------|-------|------|-------------|----------|
| **Vercel** | ⚡ Fastest | Free | Permanent | **Recommended** |
| **Netlify** | ⚡ Fast | Free | Permanent | Drag & drop |
| **GitHub Pages** | ⏱️ Medium | Free | Permanent | Open source |
| **Firebase** | ⏱️ Medium | Free tier | Permanent | Google ecosystem |
| **APK** | 📱 Medium | Free | Manual | Android only |
| **ngrok** | 🚀 Instant | Free | Temporary | Quick tests |

---

## 🎯 Recommended: Vercel Deployment

### Why Vercel?
- ✅ **Fastest** deployment (2 minutes)
- ✅ **Free** for personal projects
- ✅ **Automatic** HTTPS
- ✅ **Custom** domains supported
- ✅ **Global** CDN
- ✅ **No configuration** needed

### Complete Vercel Setup
```bash
# 1. Build
flutter build web

# 2. Deploy
cd build/web
vercel --prod

# Follow prompts:
# - Set up and deploy? Yes
# - Project name: nanoplastics
# - Directory: ./ (current)
# - Override settings? No

# 3. Done! Get your URL:
# https://nanoplastics.vercel.app
```

### Custom Domain (Optional)
If you have a domain:
```bash
vercel domains add yourdomain.com
```

---

## 🔒 Security Notes

### For Public Deployment:
- ✅ App uses only client-side code
- ✅ No API keys exposed
- ✅ No backend required
- ✅ Safe to deploy publicly

### For Production:
- [ ] Add backend API
- [ ] Implement authentication
- [ ] Add rate limiting
- [ ] Set up analytics

---

## 📝 Quick Reference

### Build Commands
```bash
# Web
flutter build web

# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

### Deploy Commands
```bash
# Vercel
vercel --prod

# Firebase
firebase deploy

# Netlify
netlify deploy --prod
```

---

## 🎉 Success Checklist

After deployment, verify:
- [ ] App loads correctly
- [ ] All images/fonts display
- [ ] Navigation works
- [ ] Language selector functions
- [ ] Onboarding flows properly
- [ ] Path selection works
- [ ] Categories filter correctly
- [ ] Mobile responsive design works

---

**Need Help?** Check the deployment platform's documentation:
- [Vercel Docs](https://vercel.com/docs)
- [Netlify Docs](https://docs.netlify.com)
- [GitHub Pages](https://pages.github.com)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
