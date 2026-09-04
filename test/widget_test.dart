// Smoke test for the Vibe Talk client configuration.

import 'package:Changathi/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zartek_core/zartek_core.dart';

void main() {
  test('vibeTalkConfig exposes the expected client values', () {
    expect(vibeTalkConfig.appName, 'Vibe Talk');
    expect(vibeTalkConfig.baseUrl, 'https://prod.vibetalksapp.com/api/v1/');
    expect(vibeTalkConfig.chatBaseUrl, 'https://vibecall-prod.chat.zartek.in/');
  });

  test('AppConfigScope exposes the config after it is set', () {
    AppConfigScope.set(vibeTalkConfig);
    expect(AppConfigScope.instance.agoraAppId, isNotEmpty);
    expect(AppConfigScope.instance.colors.primary, isNotNull);
  });
}
