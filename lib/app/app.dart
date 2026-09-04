import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Shared logic/providers from the core package.
import 'package:zartek_core/src/config/app_config_provider.dart';
import 'package:zartek_core/src/core/localization/app_locale_controller.dart';
import 'package:zartek_core/src/app/providers.dart';
import 'package:zartek_core/src/util/navigation_service.dart';

import '../src/app/app_router.dart';
import '../src/app/route_observer.dart';
import '../src/app/theme.dart';
import '../src/features/splash/view/splash_page.dart';
import '../src/widgets/update_gate.dart';

// Client-owned UI (this app's design system, routing and screens).

/// Root widget for the Vibe Talk client. Owns the `MaterialApp`, theme, router
/// and the first screen. Bound to the shared providers set up by
/// `bootstrap()` in `zartek_core`.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final navigationKey = ref.watch(navigationProvider).navigationKey;
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    return ScreenUtilInit(
      designSize: const Size(360, 756),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: config.appName,
        themeMode: themeMode,
        theme: AppTheme(config.colors).theme,
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ml'),
          Locale('hi'),
          Locale('ta'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        navigatorKey: navigationKey,
        scaffoldMessengerKey: NavigationService.scaffoldMessengerKey,
        navigatorObservers: [appRouteObserver],
        home: const SplashPage(),
        // UpdateGate MUST live here, not in `home:`. `builder` wraps the
        // Navigator, so every route is a descendant and
        // UpdateGate.checkForUpdate() resolves from any screen. Mounted in
        // `home:` it only wrapped the initial route, and every other route was a
        // sibling — which is why the agent_tile checks silently did nothing.
        builder: (context, widget) =>
            UpdateGate(child: widget ?? const SizedBox.shrink()),
        onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
      ),
    );
  }
}
