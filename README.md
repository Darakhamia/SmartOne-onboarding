# SmartOne Merchant Onboarding

A Flutter MVP mobile application for the SmartOne fintech POS merchant onboarding platform.

**Android-first** (Flutter compatible with iOS) | **Demo Prototype** | No backend integration

---

## Features

| Screen | Description |
|--------|-------------|
| Welcome | New merchant signup or demo login |
| Dashboard | Onboarding progress overview + current step |
| Application Form | Full merchant onboarding form (5 sections) |
| Documents | Upload 6 compliance documents with status tracking |
| KYC Verification | Mock iDenfy identity verification flow |
| Contract Signing | Merchant agreement review and e-signature |
| Progress | Full 11-step timeline view |
| Support | Mock live chat with SmartOne support |
| Profile | Merchant account details and settings |
| Admin Panel | Demo control panel to simulate any onboarding step |

### Onboarding Steps
1. Application Form Submitted
2. Documents Upload
3. KYC Verification (iDenfy)
4. AML Review
5. Submitted to Paynetics
6. Paynetics Approval
7. Contract Signing
8. Submitted to DNA
9. Terminal Preparation
10. Terminal Handover
11. Onboarding Complete

---

## Setup & Run

### Prerequisites

- Flutter SDK ≥ 3.0.0 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android device or emulator (Android 5.0+ / API 21+)

### Install

```bash
# Clone the repository
git clone <repo-url>
cd SmartOne-onboarding

# Install dependencies
flutter pub get
```

### Run

```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (unsigned)
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

---

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── merchant_model.dart          # Merchant application data
│   ├── onboarding_step_model.dart   # Step status model
│   ├── document_model.dart          # Document upload model
│   ├── outlet_model.dart            # Outlet detail model
│   └── chat_message_model.dart      # Support chat model
├── providers/
│   └── onboarding_provider.dart     # ChangeNotifier state management
├── screens/
│   ├── welcome_screen.dart          # Landing / login screen
│   ├── dashboard_screen.dart        # Main dashboard
│   ├── application_form_screen.dart # Multi-section form
│   ├── documents_screen.dart        # Document upload
│   ├── kyc_screen.dart              # KYC verification flow
│   ├── contract_screen.dart         # Contract signing
│   ├── progress_screen.dart         # Full timeline
│   ├── support_screen.dart          # Live chat support
│   ├── profile_screen.dart          # Merchant profile
│   └── admin_panel_screen.dart      # Demo admin control
├── navigation/
│   └── main_navigation.dart         # Bottom nav bar
├── widgets/
│   ├── custom_button.dart           # Reusable buttons
│   ├── step_card.dart               # Onboarding step card
│   ├── progress_header.dart         # Progress indicator header
│   ├── document_item_widget.dart    # Document upload item
│   ├── chat_bubble.dart             # Chat message bubble
│   ├── section_header.dart          # Section headers
│   └── info_card.dart               # Info/stat cards
└── utils/
    ├── theme.dart                   # App theme (colors, fonts)
    └── constants.dart               # App-wide constants
```

---

## Design

- **Primary color**: `#5A19B5` (Purple)
- **Background**: White
- **Font**: Inter (Google Fonts)
- **Style**: Minimal fintech, rounded cards, clean layout
- **Icons**: Material Icons

---

## Demo Admin Panel

Access via the gear icon on Dashboard or Profile → **Demo Admin Panel**.

Use it to:
- Jump to any onboarding step instantly
- Mark documents as uploaded
- Complete KYC verification
- Sign the contract
- Test pre-configured scenarios (Reset, AML Review, Contract, Terminal Prep, All Complete)

---

## Tech Stack

- **Flutter** 3.x
- **Provider** – state management
- **Google Fonts** – Inter typeface
- **Material 3** UI
- All data is **mock / in-memory** — no backend required
