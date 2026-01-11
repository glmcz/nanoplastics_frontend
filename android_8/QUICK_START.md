# 🚀 Quick Start Guide

## Prerequisites

Make sure you have Flutter installed:
```bash
flutter --version
```

Should show Flutter 3.0+ and Dart 3.0+.

## Installation & Run

```bash
# Navigate to the project
cd /Users/martindurak/Desktop/web_rust/nanoplastics/frontend/android_8

# Get dependencies
flutter pub get

# Run on your connected device/emulator
flutter run

# Or run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# For web (if enabled)
flutter run -d chrome
```

## What You'll See

### 1. Onboarding (4 Screens)
- **Screen 1**: Welcome with blue→purple gradient and 🧬 icon
- **Screen 2**: Problem explanation with red→orange gradient and ⚠️ icon
- **Screen 3**: Solution approach with green→cyan gradient and 💡 icon
- **Screen 4**: Two paths preview with purple→blue gradient and 🌍 icon

**Interaction**: Swipe left or tap "Next" button. Skip available in top-right.

### 2. Path Selection
- Animated holistic circle showing unity of Body & Earth
- 8 particles rotating around the circle
- Two gradient cards:
  - 🧬 **Human Body** (purple→red gradient)
  - 🌍 **Planet Earth** (cyan→yellow gradient)

**Interaction**: Tap either card to select your path.

### 3. Category Details
Shows 2 categories per path with:
- Category icon and description
- 3 real-world examples
- Color-coded by category type
- "Continue to App" button at bottom

**Interaction**: Scroll to read examples, tap button to proceed.

### 4. Main App (3 Tabs)
- **Tab 1 - Library** 📚: Scientific resources and reports
- **Tab 2 - Ideas** 💡: Center FAB for submitting ideas (active by default)
- **Tab 3 - Results** 📊: AI-ranked leaderboard

**Interaction**:
- Tap bottom nav icons to switch tabs
- Tap language selector (top-right) to change language
- Tap resource cards to open (currently prints to console)

## Testing Different Languages

In the app header, tap the language dropdown:
- 🇺🇸 EN - English
- 🇨🇿 CS - Czech (default)
- 🇫🇷 FR - French
- 🇪🇸 ES - Spanish
- 🇷🇺 RU - Russian

All text will update immediately!

## Development Tips

### Hot Reload
After making changes to `.dart` files:
- Press `r` in the terminal running Flutter
- Or save the file (if using IDE with hot reload enabled)

### Restart App
To restart from onboarding:
- Press `R` in the terminal (capital R)
- Or stop and run again

### Debug Console
Open with `` ` `` (backtick) in the terminal to see debug prints.

## Common Issues

### "No devices found"
```bash
# For Android
flutter emulators
flutter emulators --launch <emulator-id>

# For iOS (macOS only)
open -a Simulator
```

### Dependencies not found
```bash
flutter clean
flutter pub get
flutter run
```

### Gradle issues (Android)
```bash
cd android
./gradlew clean
cd ..
flutter run
```

## File Structure Overview

```
lib/
├── main.dart              ← App entry point (starts onboarding)
├── config/                ← Colors, constants, theme
├── data/                  ← Static data for UI
├── models/                ← Data structures
├── screens/               ← Full-screen pages
│   ├── onboarding_screen.dart
│   ├── path_selection_screen.dart
│   ├── category_detail_screen.dart
│   ├── main_screen.dart
│   └── views/             ← Tab views
├── services/              ← Business logic
└── widgets/               ← Reusable components
```

## Next Steps

1. **Customize Colors**: Edit `lib/config/app_colors.dart`
2. **Add Categories**: Edit `lib/data/solution_paths_data.dart`
3. **Change Translations**: Edit `lib/services/localization_service.dart`
4. **Add Screens**: Create new files in `lib/screens/`

## Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

---

**Need Help?** Check the [README.md](README.md) and [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md) for detailed documentation.

**Ready?** Run `flutter run` and enjoy your prototype! 🎉
