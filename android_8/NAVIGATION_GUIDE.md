# Navigation Guide - NanoSolve Hive

## 🗺️ Complete Navigation Flow

### User Journey Map

```
┌─────────────────────────────────────────────────────────────┐
│                    ONBOARDING (4 Pages)                      │
│  • Swipe left/right to navigate                             │
│  • "Skip" button (top-right) → Path Selection              │
│  • "Next" button → Next page                                │
│  • "Get Started" (page 4) → Path Selection                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              PATH SELECTION SCREEN                           │
│  • Back button: None (entry point after onboarding)         │
│  • Tap Human Body card → Category Detail (Body)            │
│  • Tap Planet Earth card → Category Detail (Earth)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              CATEGORY DETAIL SCREEN                          │
│  • Back button (top-left) → Path Selection                 │
│  • "Back to Path Selection" button → Path Selection        │
│  • "Continue to App" button → Main App (removes history)   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    MAIN APP                                  │
│  • Back button: Shows exit dialog                           │
│  • Bottom nav: Switch between 3 tabs                        │
│    - Library Tab (left)                                     │
│    - Ideas Tab (center FAB)                                 │
│    - Results Tab (right)                                    │
│  • Language selector (top-right header)                     │
└─────────────────────────────────────────────────────────────┘
```

## 📱 Navigation Controls

### 1. Hardware Back Button (Android)
- **Onboarding**: Goes back one page (native PageView behavior)
- **Path Selection**: No action (entry point)
- **Category Detail**: Returns to Path Selection
- **Main App**: Shows exit confirmation dialog

### 2. On-Screen Back Buttons
All screens with back buttons show them in the **top-left corner**:

#### Category Detail Screen
```dart
┌────────────────────────────────┐
│ ← [Back] Category Name    🌐 CS│ ← Header with back button
│                                │
│  [Category content]            │
└────────────────────────────────┘
```

#### Main App (Optional)
```dart
┌────────────────────────────────┐
│ NANOHIVE              🌐 CS    │ ← No back button (main screen)
│                                │
│  [Tab content]                 │
│                                │
│ ┌────┐  ┌────┐  ┌────┐       │
│ │ 📚 │  │  +  │  │ 📊 │       │ ← Bottom navigation
│ └────┘  └────┘  └────┘       │
└────────────────────────────────┘
```

### 3. Navigation Buttons

#### Onboarding Screen
- **Skip Button** (top-right): Available on pages 1-3
  - Action: Skip to Path Selection
  - Style: Text button, muted color

- **Next Button** (bottom): Available on all pages
  - Pages 1-3: "Next"
  - Page 4: "Get Started"
  - Style: Full-width primary button

#### Path Selection Screen
- **Path Cards**: Two large interactive cards
  - Action: Navigate to Category Detail
  - Visual: Gradient backgrounds with glow

#### Category Detail Screen
- **Back Icon** (top-left): iOS-style back arrow
  - Action: Return to Path Selection
  - Style: White arrow icon

- **Back to Path Selection** (bottom): Text link
  - Action: Same as back icon
  - Style: Text button with path color

- **Continue to App** (bottom): Primary CTA
  - Action: Navigate to Main App (clears navigation stack)
  - Style: Full-width button with path gradient color

#### Main App
- **Bottom Navigation**: 3 tabs
  - Tap any tab to switch views
  - Center tab has elevated FAB

- **Language Selector** (top-right): Dropdown
  - Shows current language with flag
  - Change language instantly

## 🔄 Navigation Stack Management

### Clear Navigation (No Back History)
When these actions occur, the navigation stack is cleared:

1. **"Continue to App"** from Category Detail
   ```dart
   Navigator.pushAndRemoveUntil(
     MaterialPageRoute(builder: (_) => MainScreen()),
     (route) => false,  // Removes all previous routes
   );
   ```

### Preserve Navigation (Can Go Back)
Normal navigation that preserves history:

1. **Path Selection → Category Detail**
   ```dart
   Navigator.push(
     MaterialPageRoute(builder: (_) => CategoryDetailScreen()),
   );
   ```

2. **Category Detail → Path Selection** (back button)
   ```dart
   Navigator.pop(context);
   ```

## ⚠️ Exit Confirmation

### Main App Exit Dialog
When pressing back button on Main App:

```
┌─────────────────────────────────┐
│         Exit App?                │
│                                  │
│  Are you sure you want to exit? │
│                                  │
│    [Cancel]        [Exit]        │
└─────────────────────────────────┘
```

- **Cancel**: Stays in app
- **Exit**: Closes app (Android) or goes to previous screen

## 🎯 Navigation Best Practices

### User Experience
✅ Always show back button on secondary screens
✅ Use exit dialog on main screen to prevent accidental exits
✅ Clear navigation stack when entering main app
✅ Provide multiple ways to go back (button + hardware back)
✅ Maintain consistent navigation patterns

### Implementation
✅ Use `PopScope` instead of deprecated `WillPopScope`
✅ Check `context.mounted` before navigation after async operations
✅ Use proper `pushAndRemoveUntil` to clear history
✅ Handle both hardware and on-screen back buttons

## 🔧 Customization

### Adding Back Button to Other Screens

1. Add parameters to screen widget:
```dart
class YourScreen extends StatelessWidget {
  final bool showBackButton;

  const YourScreen({this.showBackButton = true});
}
```

2. Pass to AppHeader:
```dart
AppHeader(
  selectedLanguage: localization.currentLanguage,
  onLanguageChanged: (lang) => setState(() {}),
  showBackButton: true,  // Enable back button
  onBackPressed: () => Navigator.pop(context),
)
```

### Customizing Navigation Behavior

Edit navigation logic in:
- [lib/screens/main_screen.dart](lib/screens/main_screen.dart) - Main app navigation
- [lib/screens/path_selection_screen.dart](lib/screens/path_selection_screen.dart) - Path navigation
- [lib/screens/category_detail_screen.dart](lib/screens/category_detail_screen.dart) - Category navigation

---

**Status**: ✅ All navigation controls implemented and tested
**Back Buttons**: Available on all secondary screens
**Exit Dialog**: Prevents accidental app closure
**Stack Management**: Proper history clearing on app entry
