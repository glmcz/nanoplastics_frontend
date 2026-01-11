# NanoSolve Hive - Flutter Application

A mobile application designed to bridge the gap between the public and scientific community for crowdsourcing R&D solutions to nanoplastic pollution.


# after sdk Andoird setup and launch of emulator
flutter create --platforms=android .
flutter run -d emulator-5554

## 🌟 App Flow

The app follows a holistic, user-centric design:

1. **Onboarding (4 screens)** - Introduction to the nanoplastic crisis and app purpose
2. **Path Selection** - Choose between two solution domains:
   - 🧬 **Human Body** - Protection and detoxification
   - 🌍 **Planet Earth** - Environmental cleaning and prevention
3. **Category Details** - Dive deep into specific solution categories
4. **Main App** - Library, Ideas submission, and AI-ranked Results

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── config/                        # Configuration files
│   ├── app_colors.dart           # Color constants
│   ├── app_constants.dart        # General constants
│   └── app_theme.dart            # Theme configuration
├── data/                          # Static data and data providers
│   ├── app_data.dart             # Application static data
│   ├── onboarding_data.dart      # Onboarding content
│   └── solution_paths_data.dart  # Solution paths & categories
├── models/                        # Data models
│   ├── category_item.dart        # Category model
│   ├── leaderboard_item.dart     # Leaderboard entry model
│   ├── resource_item.dart        # Resource item model
│   ├── onboarding_page.dart      # Onboarding page model
│   └── solution_path.dart        # Solution path & category models
├── screens/                       # Screen-level widgets
│   ├── onboarding_screen.dart    # 4-page onboarding flow
│   ├── path_selection_screen.dart # Holistic path chooser
│   ├── category_detail_screen.dart # Category deep-dive
│   ├── main_screen.dart          # Main scaffold with navigation
│   ├── views/                    # Individual view screens
│   │   ├── brainstorm_view.dart
│   │   ├── library_view.dart
│   │   └── results_view.dart
│   └── widgets/                  # Screen-specific widgets
│       ├── app_header.dart
│       └── bottom_navigation.dart
├── services/                      # Business logic and services
│   └── localization_service.dart # i18n with 5 languages
└── widgets/                       # Reusable widgets
    ├── animated_gradient_background.dart
    ├── category_card.dart
    ├── glow_icon.dart
    ├── leaderboard_row.dart
    ├── resource_card.dart
    └── section_header.dart
```

## Architecture

The application follows a **clean architecture** pattern with clear separation of concerns:

- **Models**: Pure data classes representing domain entities
- **Services**: Business logic and utilities (localization, API calls, etc.)
- **Widgets**: Reusable UI components
- **Screens**: Page-level compositions using widgets
- **Config**: Application-wide constants and theming

## Features

### 1. Holistic Onboarding Experience
- 4 beautifully animated screens introducing the nanoplastic crisis
- Gradient backgrounds with glowing icons
- Smooth page transitions and indicators
- Skip option for returning users

### 2. Dual-Path Architecture
Users choose their focus area with a visually striking interface:

#### 🧬 Human Body Path
- **Body Detoxification** - Removing nanoplastics from the organism
  - Examples: Toxin-binding foods, chelation therapy, immune support
- **Barrier Protection** - Preventing penetration into the body
  - Examples: Placental protection, next-gen respirators, blood-brain barrier

#### 🌍 Planet Earth Path
- **Water Filtration** - Capturing nanoplastics in water sources
  - Examples: Drinking water purifiers, ocean cleaning, washing machine filters
- **Energy from Plastics** - Using nanoplastic properties for energy
  - Examples: Triboelectric effect, static charge harvesting, magnetic separation

### 3. Multi-language Support
- Supports 5 languages: English, Czech, French, Spanish, Russian
- Implemented through singleton `LocalizationService`
- Easy to extend with new languages

### 4. Three Main Sections (After Path Selection)

#### Library (Zdroje)
- Official research reports (Allatra Global Research Center)
- Scientific databases (PubMed, ScienceDirect)
- Educational resources

#### Brainstorm (Nápady)
- Submit ideas within chosen solution categories
- Community stats showing global participation

#### Results (Výsledky)
- AI-ranked leaderboard of solutions
- Sorted by feasibility and health impact
- Community voting system
- Color-coded by category

## Design Principles

### Visual Design
- **Dark Theme** - Optimized for readability and modern aesthetics
- **Gradient Backgrounds** - Dynamic, animated gradients throughout
- **Glowing Effects** - Icon glows and shadows for depth
- **Smooth Animations** - PageView transitions, indicator animations, rotating particles
- **Custom Painters** - Hand-drawn holistic circle visualization showing unity of Body & Earth

### Color Scheme
Domain-based color system:
- 🧬 **Human Body**: Purple (#A855F7) to Red (#EF4444)
  - Purple for placenta/barrier protection
  - Red for blood/circulatory system
- 🌍 **Planet Earth**: Cyan (#06B6D4) to Yellow (#EAB308)
  - Cyan for water/ocean
  - Yellow for energy/physics
- 🔵 **Accent**: Blue (#3B82F6) - Primary actions and highlights

### Best Practices Applied

1. **Separation of Concerns**
   - Business logic separated from UI
   - Data models independent of widgets
   - Services isolated from presentation

2. **Reusability**
   - Component-based architecture
   - Reusable widgets with clear props
   - Shared constants and themes

3. **Maintainability**
   - Clear folder structure
   - Consistent naming conventions
   - Single responsibility principle

4. **Scalability**
   - Easy to add new languages
   - Simple to extend with new categories
   - Modular design for feature additions

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

```bash
# Navigate to project directory
cd frontend/android_8

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Configuration

### Adding a New Language

1. Open `lib/services/localization_service.dart`
2. Add language to `availableLanguages` list
3. Add translations to `_translations` map

### Customizing Colors

Edit `lib/config/app_colors.dart` to modify the color scheme.

### Adding New Categories

1. Add category data to `lib/data/app_data.dart`
2. Category will automatically appear in the UI

## Future Enhancements

- [ ] Add URL launcher for external resources
- [ ] Implement idea submission flow
- [ ] Add backend API integration
- [ ] Implement state management (Provider/Riverpod)
- [ ] Add unit and widget tests
- [ ] Implement offline mode
- [ ] Add analytics tracking

## License

This project is part of the NanoPlastics research initiative.
