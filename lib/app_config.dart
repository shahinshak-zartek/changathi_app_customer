import 'package:zartek_core/zartek_core.dart';

import 'app_theme.dart';

/// Vibe Talk client configuration.
const AppConfig vibeTalkConfig = AppConfig(
  appName: 'Changathi',
  baseUrl: 'https://dev.changathiapp.com/api/v1/',
  // baseUrl: 'https://prod.nizhal.co/api/v1/',

  // FLIP THIS WITH baseUrl ABOVE. It selects which maintenance flag the update
  // gate reads — dev_customer_app_in_maintenance vs customer_app_in_maintenance
  // — so a mismatch points the maintenance switch at the wrong environment. The
  // core logs a warning if this disagrees with baseUrl.
  isDev: true,
  /// chat server credentials
  // chatBaseUrl: 'https://nizhal.chat.zartek.in',
  // chatBaseUrl: 'https://nizhal-prod.chat.zartek.in',
  // chatIosAppId: 'com.changathi.customer',

  // agoraAppId: '6327c9a29fbe4c6882cc9ddf998038ef', prod
  agoraAppId: '84b1f54d3d7b45fca956fc1c1fb5ea53',

  colors: vibeTalkColors,
  logoAsset: vibeTalkLogoAsset,
  appIconAsset: vibeTalkAppIconAsset,
);
