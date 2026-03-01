# NanoSolve Hive

> **Science-backed intelligence on nanoplastic pollution — and a community platform to fight it.**

A mobile application that gives you research-grade information about how nanoplastics affect human health and the environment, lets you explore scientific sources, and invites you to contribute your own solution ideas.

Available on **Android** (APK) · Built with **Flutter** · Supports **5 languages**

---

## Download

| Variant | Size | Languages | Link |
|---------|------|-----------|------|
| Full | ~85 MB | EN · CS · ES · FR · RU | [nanoplastics_app.apk](https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app.apk) |
| Lite | ~45 MB | EN only | [nanoplastics_app_lite.apk](https://github.com/glmcz/nanoplastics_frontend/releases/latest/download/nanoplastics_app_lite.apk) |

All releases (including older versions): **[GitHub Releases](https://github.com/glmcz/nanoplastics_frontend/releases)**
Download page with version history: **[GitHub Pages](https://glmcz.github.io/nanoplastics_frontend/)**

---

## What the App Does

NanoSolve Hive is organized around two core questions:

- **What are nanoplastics doing to us?** — human health impacts across 6 body systems
- **What are they doing to the planet?** — environmental damage across 6 ecosystem domains

Beyond reading, you can submit your own ideas for solving the nanoplastics crisis, browse the scientific papers behind every claim, and track which solver community members are making the biggest impact.

---

## App Walkthrough

### Onboarding

On first launch you will see a 3-slide introduction:

1. **The Problem** — scale of nanoplastic pollution
2. **The Mission** — what NanoSolve Hive is trying to achieve
3. **The Community** — how solvers collaborate

On the first slide you can pick your language (English, Czech, Spanish, French, Russian). Your choice is saved and you will not see onboarding again on subsequent launches.

---

### Main Hub

The central screen after onboarding. A control-panel–style layout with:

**Two impact tabs (top)**

| Tab | Covers |
|-----|--------|
| Human | How nanoplastics enter and damage the human body |
| Planet | How nanoplastics damage oceans, atmosphere, and ecosystems |

**Category grid (center)** — 6 cards per tab. Tap any card to open its detail screen.

*Human categories:* Central Systems · Filtration & Detox · Vitality & Tissue · Reproduction · Entry Gates · Ways of Destruction

*Planet categories:* World Ocean · Atmosphere · Flora & Fauna · Magnetic Field · Entry Gates · Physical Properties

**Control hub (bottom)**

| Button | Action |
|--------|--------|
| Human / Planet | Switch active tab |
| Sources | Open the full resource library |
| Results | See idea statistics and the leaderboard |
| Center gear | Open Settings |

**Interactive tour** — on first launch a 6-step guided tour walks you through every control. You can skip it at any time. To replay it, there is no setting yet (planned).

---

### Category Detail

Tap any category card to open its detail page.

**What you will find:**

- **Headline highlight** — the key finding for this category, with a direct link to the relevant page in the research report
- **Bullet points** — supporting evidence and mechanisms
- **Sources** (collapsible panel) — numbered list of scientific references; tap any to open the source

**Brainstorm Box** (bottom of every category)

This is where you contribute. Type your idea for tackling nanoplastic pollution in this domain. You can optionally attach files (images, video, audio). Tap **Submit** to send it to the community backend. All submissions are anonymous by default.

---

### Sources

A centralized library of all scientific materials used in the app.

**Main Report card** — tap to open the full Nanoplastics Global Report (198 pages) in the built-in PDF viewer.

**Web Links tab** — three collapsible sections:

| Section | Contents |
|---------|----------|
| Human Health | Research papers on health impacts |
| Earth Pollution | Environmental studies |
| Water Abilities | Water-specific research |

Each entry shows the page range it corresponds to in the main report. Tap to open in the PDF viewer at that exact page.

**Video tab** — curated YouTube reports and video studies. Tap to open in your browser.

Language filtering is applied automatically — you will see sources in your chosen language where available, with English as fallback.

---

### PDF Viewer

Opens automatically when you tap a source or the main report card.

**Controls:**

| Control | Action |
|---------|--------|
| Page number field (header) | Jump to any page — type a number and confirm |
| ← / → buttons (footer) | Previous / next page |
| + / − buttons | Zoom in / out (1× to 5×) |
| Pinch gesture | Free zoom |
| Share icon | Share the PDF via any installed app |
| Download icon | Save the PDF to your device |

Rotating your phone to landscape reflows the layout and preserves your current page.

---

### Results

An overview of community activity:

- **Total Ideas** — number of solutions submitted across all categories
- **Active Solvers** — total registered participants (tap to open the Leaderboard)
- **Evaluation info panel** — explains how the AI ranks submitted ideas

---

### Leaderboard

A ranked list of the most active solution contributors.

**Access requirement:** you must register a display name and email first. Tap **Register Now** and fill in the quick form. Your nickname is hashed before storage — your real identity is never exposed.

Once registered you will see:

- Rank badge (gold · silver · bronze for top 3)
- Solver name and specialty
- Number of accepted solutions

The list refreshes automatically. Pull down to force a refresh.

---

### Settings

Accessible via the gear icon in the hub center.

| Option | What it does |
|--------|-------------|
| User Profile | Edit your display name, email, and specialty bio |
| Language | Switch between EN / CS / ES / FR / RU — app restarts to apply |
| Privacy & Security | View Privacy Policy and Terms of Service, manage data consent |
| About | App version, build variant (Lite / Full), and update checker |

**Updates (About screen)**

The app checks for updates automatically 5 seconds after launch. You can also check manually via the gear icon at the top of the Settings screen. If a newer version is available you can download and install the APK directly from within the app — with a progress bar and pause/cancel controls.

---

## Language Support

| Code | Language | PDFs bundled (Full) |
|------|----------|---------------------|
| EN | English | Yes |
| CS | Czech | Yes |
| ES | Spanish | Yes |
| FR | French | Yes |
| RU | Russian | Yes |

In the **Lite** build only English PDFs are bundled. PDFs for other languages are downloaded on demand from the server when you switch language and open a report.

Switching language triggers a full app restart so all text updates correctly.

---

## Privacy

- **No account required** to read content or submit ideas
- Leaderboard access requires an email + display name — nickname is stored as a SHA-256 hash
- User ID is a randomly generated UUID stored in encrypted on-device storage (Android EncryptedSharedPreferences / iOS Keychain)
- Language and tour preferences are stored in standard SharedPreferences (not sensitive)
- No data is sold or shared with third parties

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push and open a Pull Request

All contributions are reviewed before merging. By submitting you agree your changes become part of this project under the same license terms.

### Local setup

```bash
git clone <your-fork>
cd nanoplastics_frontend

# Configure Firebase (required for analytics/crashlytics)
flutterfire configure

flutter pub get
flutter run                          # debug on connected device
flutter build apk --flavor full      # release full build
flutter build apk --flavor lite      # release lite build
```

### UX Design System

The goal is responsive behavior via tokens, not per-widget scaling. All screens pull from `AppSpacing`, `AppSizing`, and `AppTypography`, which derive from `ResponsiveConfig` scales. This means every screen adapts consistently across different widths, heights, and orientations without duplicating scaling logic.

To adjust layout for a new screen size: adjust tokens (or add variant logic inside token classes) and every screen updates automatically. No per-screen magic numbers.

### App Update Flow

```
backend /release endpoint → GitHub Actions hook → app checks backend on startup
```

---

## License

Copyright (c) 2024 Martin Durak. All rights reserved.

This source code is made available for viewing and contribution purposes only. No permission is granted to use, copy, modify, merge, publish, distribute, sublicense, or sell copies of this software, in whole or in part, without explicit written permission from the author.

Unauthorized use, reproduction, or distribution of this software is strictly prohibited.
