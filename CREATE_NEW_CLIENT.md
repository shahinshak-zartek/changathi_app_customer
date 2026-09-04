# Create a New Client — Step by Step

A beginner-friendly guide to spinning up a **new client app** from this repo.
You'll copy this app, rebrand it, connect its own Firebase, and run it. ~30 min.

> This repo (`vibe_talk`) is the template. All the shared logic comes from the
> `zartek_core` package (pulled automatically). You only change **branding,
> identity, and Firebase** — plus the UI if you want a different look.

Throughout, the example new client is **Acme Talk** (`acme_talk`,
`com.acme.talk`). Replace those with your client's values.

---

## 0. Before you start

- Flutter installed — check with `flutter doctor`.
- GitHub CLI logged in (the repos are private):
  ```bash
  gh auth login        # GitHub.com → HTTPS → login with a browser
  ```
- Access to `anshif-zartek/zartek_core` and `anshif-zartek/vibe_talk`.

---

## 1. Copy this repo into a new project

```bash
git clone https://github.com/anshif-zartek/vibe_talk.git acme_talk
cd acme_talk
rm -rf .git            # detach from vibe_talk's history — this is a NEW app
git init -b main
git add -A
git commit -m "chore: start acme_talk from vibe_talk template"
```

## 2. Run it once, as-is (sanity check)

```bash
flutter pub get
flutter run
```

It will still look and behave like **Vibe Talk** — that's expected. You rebrand
it in the next steps. (If this runs, your setup is good.)

---

## 3. Rebrand — make it your client

### 3a. Config values — `lib/app_config.dart`

Change the values (keep the field names):

```dart
const AppConfig vibeTalkConfig = AppConfig(
  appName: 'Acme Talk',                              // shown in-app
  baseUrl: 'https://api.acme.com/api/v1/',           // backend REST url
  chatBaseUrl: 'https://chat.acme.com/',             // chat server url
  chatIosAppId: 'com.acme.talk',                     // usually = bundle id
  agoraAppId: '<acme-agora-app-id>',                 // from the Agora console
  colors: vibeTalkColors,
  logoAsset: vibeTalkLogoAsset,
  appIconAsset: vibeTalkAppIconAsset,
);
```

> The `vibeTalkConfig` / `vibeTalkColors` names are just Dart identifiers — you
> can leave them as-is to keep things simple. (If you rename them, also update
> the reference in `lib/main.dart`.)

### 3b. Brand colors — `lib/app_theme.dart`

```dart
const AppConfigColors vibeTalkColors = AppConfigColors(
  primary: Color(0xFF2D67B1),     // your brand primary
  secondary: Color(0xFF0F5DAB),   // your brand secondary
);
```

### 3c. Logo + app icon — `assets/icons/`

Replace these files with the client's artwork (keep the same file names so the
config paths still work):
- `assets/icons/app_logo.svg` — in-app logo
- `assets/icons/app_icon0.png` — launcher icon source
- `assets/icons/app_icon_with_bg.png` — iOS icon source

Then regenerate the native launcher icons:

```bash
dart run flutter_launcher_icons
```

### 3d. Display name (what users see under the icon)

- **Android:** `android/app/src/main/AndroidManifest.xml` → `android:label="Acme Talk"`
- **iOS:** `ios/Runner/Info.plist` → `CFBundleDisplayName` → `Acme Talk`

### 3e. Bundle id / package name (unique app id on the stores)

Currently `com.vibetalks.customer`. Change it to the client's:

- **Android** (automated):
  ```bash
  dart run change_app_package_name:main com.acme.talk
  ```
- **iOS:** open `ios/Runner.xcworkspace` in Xcode → **Runner** target →
  *Signing & Capabilities* → set **Bundle Identifier** to `com.acme.talk`.

---

## 4. Connect the client's Firebase (push, crash reporting)

```bash
flutterfire configure
```

Pick (or create) **this client's** Firebase project. This regenerates
`lib/firebase_options.dart` and drops `google-services.json` /
`GoogleService-Info.plist`. Never reuse another client's Firebase project.

---

## 5. Shared core — already wired (nothing to do)

`pubspec.yaml` already pulls the shared logic:

```yaml
zartek_core:
  git:
    url: https://github.com/anshif-zartek/zartek_core.git
    ref: v1.1.0
flutter_riverpod: 3.1.0   # keep this pin — it must match core
```

Only touch this if you want a newer core version (bump `ref:` to a newer tag).

---

## 6. Run and verify

```bash
flutter pub get
flutter analyze          # should say "No issues found"
flutter run
```

## 7. Push the new client to its own GitHub repo

```bash
git add -A
git commit -m "chore: rebrand to Acme Talk"
gh repo create anshif-zartek/acme_talk --private --source=. --remote=origin --push
```

---

## Want a different look?

The whole UI lives in **this repo** — you're free to change it:
- `lib/app/theme.dart` — the design system (`ThemeData`, colors, text styles).
- `lib/src/features/**/view` and `lib/src/widgets` — the screens and widgets.

Shared logic (login, calls, chat, wallet) stays in `zartek_core`; you build the
UI on top of it. You don't need to touch core to restyle or redesign screens.

---

## Quick checklist

- [ ] Copied repo, reset git history
- [ ] App name (`app_config.dart`, Android label, iOS display name)
- [ ] Bundle id / package name (Android + iOS)
- [ ] Backend + chat + Agora values (`app_config.dart`)
- [ ] Brand colors (`app_theme.dart`)
- [ ] Logo + icons replaced, `flutter_launcher_icons` run
- [ ] Firebase configured (`flutterfire configure`)
- [ ] `flutter run` works on a device
- [ ] Pushed to its own private repo
