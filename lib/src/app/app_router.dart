import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import 'package:zartek_core/src/core/model/auth_user.dart';
import 'package:zartek_core/src/features/auth/model/language_model.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';
import 'package:zartek_core/src/features/auth/model/login_add_body_model.dart';
import '../features/auth/view/bonus_obtained_page.dart';
import '../features/auth/view/language_selection_page.dart';
import '../features/auth/view/login_page.dart';
import '../features/auth/view/otp_verification_page.dart';
import 'package:zartek_core/src/features/chat/data/user_model.dart';
import '../features/auth/view/profile_add_page.dart';
import '../features/call/view/audio_call_screen.dart';
import '../features/call/view/video_call_screen.dart';
import '../features/chat/view/chat_screen.dart';
import '../features/home/view/nav_bar.dart';
import '../features/home/view/recent_activity_screen.dart';
import '../features/notification/view/notification_screen.dart';
import '../features/permission/view/microphone_permission.dart';
import '../features/profile/view/blocked_user_page.dart';
import '../features/profile/view/help_and_support.dart';
import '../features/profile/view/language_edit.dart';
import '../features/profile/view/profile_avatar_update.dart';
import '../features/profile/view/webview_page.dart';
import '../features/splash/view/splash_page.dart';
import '../features/wallet/view/wallet_screen.dart';

/// [AppRouter] - A view router class which holds all the routes used in the app
/// It can be used to navigating routes using `pushNamed` method of `Navigator` class
class AppRouter {
  AppRouter._();

  static const splash = '/splash';
  static const login = '/login';
  static const verify = '/verify';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const profileAdd = '/profileAdd';
  static const languageSelection = '/languageSelection';
  static const bonusShowPage = '/bonusShowPage';
  static const microphonePermission = '/microphonePermission';
  static const webView = '/webView';
  static const help = '/help';
  static const blockedUser = '/blockedUser';
  static const profileEdit = '/profileEdit';
  static const languageEdit = '/languageEdit';
  static const wallet = '/wallet';
  static const singleChat = '/singleChat';
  static const notification = '/notification';

  static const locationPermission = '/locationPermission';
  static const locationSelection = '/locationSelection';
  static const postAdCategory = '/postAdCategory';
  static const postAdSubCategory = '/postAdSubCategory';
  static const postAdType = '/postAdType';
  static const postAdDetailForm = '/postAdDetailForm';
  static const postAdReview = '/postAdReview';
  static const filter = '/filter';
  static const allAdView = '/allAdView';
  static const singleAdView = '/singleAdView';
  // static const profile = '/profile';
  static const webviewPage = '/webviewPage';
  static const userInterest = '/userInterest';
  static const notifications = '/notifications';
  static const editAd = '/editAd';
  static const chatProfile = '/chatProfile';
  static const chatBox = '/chatBox';
  static const audioCall = '/audioCall';
  static const videoCall = '/videoCall';
  static const recentActivity = '/recentActivity';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return getMaterialRoute(const SplashPage());
      case AppRoutes.login:
        return getMaterialRoute(const LoginPage());
      case AppRoutes.verify:
        final args = settings.arguments;
        final loginArgs = args is Map
            ? args['loginAddBodyModel'] as LoginAddBodyModel
            : args as LoginAddBodyModel;
        return getMaterialRoute(
          OtpVerificationPage(
            loginAddBodyModel: loginArgs,
            initialResendAvailableInSeconds: args is Map
                ? (args['resendAvailableInSeconds'] as int? ?? 0)
                : 0,
          ),
        );
      case AppRoutes.profileAdd:
        return getMaterialRoute(
          ProfileAddPage(phoneNumber: settings.arguments as String),
        );
      case AppRoutes.languageSelection:
        return getMaterialRoute(LanguageSelectionPage());
      case AppRoutes.bonusShowPage:
        return getMaterialRoute(BonusObtainedPage());
      case AppRoutes.microphonePermission:
        return getMaterialRoute(MicrophonePermissionPage());
      case AppRoutes.home:
        return getMaterialRoute(NavBar());
      case AppRoutes.help:
        return getMaterialRoute(SupportPage());
      case AppRoutes.blockedUser:
        return getMaterialRoute(
          BlockedUserPage(message: settings.arguments as String),
        );
      case AppRoutes.profileEdit:
        return getMaterialRoute(
          ProfileAvatarUpdate(userData: settings.arguments as UserData),
        );
      case AppRoutes.languageEdit:
        return getMaterialRoute(
          LanguageEdit(currentLanguage: settings.arguments as LanguageData?),
        );
      case AppRoutes.wallet:
        return getMaterialRoute(
          WalletScreen(initialIndex: (settings.arguments as int?) ?? 0),
        );
      case AppRoutes.singleChat:
        return getMaterialRoute(
          ChatScreen(user: settings.arguments as ChatUser),
        );
      case AppRoutes.audioCall:
        return getMaterialRoute(
          AudioCallScreen(agent: settings.arguments as Agent),
        );
      case AppRoutes.videoCall:
        return getMaterialRoute(
          VideoCallScreen(agent: settings.arguments as Agent),
        );
      case AppRoutes.notification:
        return getMaterialRoute(NotificationScreen());
      case AppRoutes.webView:
        return getMaterialRoute(
          WebviewPage(webViewModel: settings.arguments as WebViewModel),
        );
      case AppRoutes.recentActivity:
        return getMaterialRoute(RecentActivityScreen());
      // case notificationsPage:
      //   return getMaterialRoute(const NotificationsPage());
      // case userProfile:
      //   return getMaterialRoute(const UserProfile());
      // case userSupport:
      //   return getMaterialRoute(const UserSupport());
      // case aboutPage:
      //   return getMaterialRoute(const AboutPage());
      // case deleteProfile:
      //   return getMaterialRoute(const DeletePage());

      default:
        return getMaterialRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute getMaterialRoute(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }

  static CupertinoPageRoute getCupertinoRoute(Widget child) {
    return CupertinoPageRoute(builder: (_) => child);
  }
}
