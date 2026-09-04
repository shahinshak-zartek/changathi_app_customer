import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zartek_core/zartek_core.dart';

import 'app/app.dart';
import 'app_config.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) =>
    firebaseBackgroundMessageHandler(
      message,
      DefaultFirebaseOptions.currentPlatform,
    );

Future<void> main() => bootstrap(
  config: vibeTalkConfig,
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  backgroundHandler: _firebaseMessagingBackgroundHandler,
  appBuilder: () => const App(),
);
