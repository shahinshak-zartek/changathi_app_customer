import 'package:zartek_core/src/config/app_config.dart';

/// Defines the image, icon and file resources for the App
class Assets {
  Assets._();

  // Client-specific branding — resolved per-client from [AppConfig].
  static String get appLogo => AppConfigScope.instance.logoAsset;
  static String get appIcon => AppConfigScope.instance.appIconAsset;
  static const String whatsapp = 'assets/icons/whatsapp.svg';
  static const String camera = 'assets/icons/camera_icon.svg';
  static const String bonusContainer = 'assets/icons/bonus_container.png';
  static const String coin = 'assets/icons/coin.svg';
  static const String callHistory = 'assets/icons/call_history.svg';
  static const String notification = 'assets/icons/notification.svg';
  static const String sparkles = 'assets/icons/sparkles.svg';
  static const String profile = 'assets/icons/profile.svg';
  static const String refund = 'assets/icons/refund.svg';
  static const String term = 'assets/icons/term.svg';
  static const String wallet = 'assets/icons/wallet.svg';
  static const String privacy = 'assets/icons/privacy.svg';
  static const String logout = 'assets/icons/logout.svg';
  static const String language = 'assets/icons/language.svg';
  static const String help = 'assets/icons/help.svg';
  static const String delete = 'assets/icons/delete.svg';
  static const String email = 'assets/icons/email.svg';
  static const String phone = 'assets/icons/phone.svg';
  static const String balanceBanner = 'assets/icons/balance_banner.png';
  static const String message = 'assets/icons/message.svg';
  static const String reported = 'assets/icons/reported.png';
  static const String callerBackground = 'assets/icons/caller_background.png';
  static const String mic = 'assets/icons/mic.svg';
  static const String endCall = 'assets/icons/end_call.svg';
  static const String sound = 'assets/icons/sound.svg';
  static const String razorpay = 'assets/icons/razorpay.png';
  static const String cashfree = 'assets/icons/cashfree.png';
  static const String incoming = 'assets/icons/incoming.svg';
  static const String outgoing = 'assets/icons/outgoing.svg';
  static const String historyCall = 'assets/icons/historyCall.svg';
  static const String notificationGrey = 'assets/icons/notificationGrey.svg';
  static const String ringer = 'packages/zartek_core/assets/audio/ringer.mp3';



}
