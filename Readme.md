# NanoSolve Hive

A mobile application providing science-backed information about nanoplastics and their impact on human health and the environment. Built with Flutter, supporting multiple languages (English, Czech, Spanish, French, Russian).

## Features

- Categorized educational content on nanoplastics effects
- Interactive brainstorm/idea submission
- Source-linked scientific references with PDF viewer
- Configurable user profile and settings
- Multi-language support

## 📥 Downloads

**Latest Release:**
- [nanoplastics_app.apk](https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app.apk) - Full (All languages)
- [nanoplastics_app_lite.apk](https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app_lite.apk) - Lite (English only)

**All Versions:**
- **[GitHub Releases](https://github.com/glmcz/nanoplastics_frontend/releases)** - Full & Lite variants
- **[GitHub Pages](https://glmcz.github.io/nanoplastics_frontend/)** - Organized by version

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

All contributions are subject to review. By submitting a contribution, you agree that your changes become part of this project under the same license terms.

### Local setup:
- git clone repo...
- use own flutterfire configure
- flutter pub get
- flutter run your target

### UX Design system
The goal is responsive behavior via tokens, not per-widget scaling. Each screen now pulls from AppSpacing, AppSizing, and AppTypography, which all derive from ResponsiveConfig scales. That means all screens adapt consistently to different widths/heights/landscape without duplicating scaling logic in widgets.

For other screen variants, you adjust tokens (or add variant-aware logic inside the token classes), and every screen updates automatically. This avoids per-screen magic numbers and keeps behavior consistent across small/normal/large devices.

## License

Copyright (c) 2024 Martin Durak. All rights reserved.

This source code is made available for viewing and contribution purposes only. No permission is granted to use, copy, modify, merge, publish, distribute, sublicense, or sell copies of this software, in whole or in part, without explicit written permission from the author.

Unauthorized use, reproduction, or distribution of this software is strictly prohibited.
