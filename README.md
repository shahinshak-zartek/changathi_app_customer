# Vibe Talk

A Zartek Calling Platform client. This is a **standalone app repo**: all shared
platform logic (services, controllers, models, repositories, config) comes from
the [`zartek_core`](https://github.com/anshif-zartek/zartek_core) package, and
**this repo owns 100% of the UI** (theme, routing and screens under `lib/src`).

## How it fits together

```
zartek_core (separate repo)     vibe_talk (this repo)
  UI-free shared logic     <──   lib/main.dart          -> bootstrap(appBuilder: () => App())
  bootstrap(), AppConfig,        lib/app/app.dart       -> MaterialApp (theme, router, home)
  AppRoutes, controllers,        lib/app/app_router.dart-> route names -> this app's screens
  repositories, services         lib/src/**             -> this app's screens, widgets, theme
```

`zartek_core` is pulled via a **git ref** pinned in [`pubspec.yaml`](pubspec.yaml):

```yaml
dependencies:
  zartek_core:
    git:
      url: https://github.com/anshif-zartek/zartek_core.git
      ref: v1.1.0        # bump to adopt new core versions
```

## Local development against a local `zartek_core`

To work on core and this app together without pushing/tagging core each time,
check out `zartek_core` as a sibling directory and create a
`pubspec_overrides.yaml` (git-ignored):

```yaml
dependency_overrides:
  zartek_core:
    path: ../zartek_core
```

Then `flutter pub get` resolves core locally. Remove the override (or it is
simply ignored on CI / fresh clones) to build against the pinned git ref.

> **Riverpod version pin:** `flutter_riverpod` is pinned to the version
> `zartek_core`'s committed generated code (`*.g.dart`) targets. Keep it in sync
> with core when bumping the core git ref.

## Common commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build appbundle --release
```

## Branding / config

Client-specific values live in this repo:

- `lib/app_config.dart` — name, URLs, chat/agora ids, brand colors, logo paths.
- `lib/app_theme.dart` — brand colors + brand asset paths fed into `AppConfig`.
- `lib/app/theme.dart` — this client's full design system (`ThemeData`).
- `android/`, `ios/` — native ids, display name, `google-services.json` /
  `GoogleService-Info.plist`, launcher icons.
- `assets/icons/`, `assets/fonts/` — this client's UI assets.

CI: [`codemagic.yaml`](codemagic.yaml) builds the release app bundle. It must be
able to fetch the private `zartek_core` repo (deploy key / token).
