import 'package:zartek_core/zartek_core.dart';

import 'app_theme.dart';

const bool _isDev = true;

/// Changathi App client configuration.
const AppConfig vibeTalkConfig = AppConfig(
  appName: 'Changathi',
  baseUrl: _isDev
      ? 'https://dev.changathiapp.com/api/v1/'
      : 'https://prod.changathiapp.com/api/v1/',

  /// maintenance mode key
  // FLIP THIS WITH baseUrl ABOVE. It selects which maintenance flag the update
  // gate reads — dev_customer_app_in_maintenance vs customer_app_in_maintenance
  // — so a mismatch points the maintenance switch at the wrong environment. The
  // core logs a warning if this disagrees with baseUrl.
  isDev: _isDev,

  /// chat server credentials
  // chatBaseUrl: _isDev
  //            ? 'https://nizhal.chat.zartek.in'
  //            : 'https://nizhal.chat.zartek.in',
  chatIosAppId: 'com.changathi.customer',

  /// agora credentials
  agoraAppId: _isDev
      ? '84b1f54d3d7b45fca956fc1c1fb5ea53'
      : '6327c9a29fbe4c6882cc9ddf998038ef',

  colors: vibeTalkColors,
  logoAsset: vibeTalkLogoAsset,
  appIconAsset: vibeTalkAppIconAsset,
);
