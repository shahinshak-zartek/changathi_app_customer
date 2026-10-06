import 'package:Changathi/src/features/call/util/local_video_mirror_mode.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

void main() {
  group('local video mirror mode', () {
    test('mirrors the LiveKit front-camera preview', () {
      expect(
        liveKitLocalPreviewMirrorMode(isFrontCamera: true),
        lk.VideoViewMirrorMode.mirror,
      );
    });

    test('does not mirror the LiveKit rear-camera preview', () {
      expect(
        liveKitLocalPreviewMirrorMode(isFrontCamera: false),
        lk.VideoViewMirrorMode.off,
      );
    });

    test('mirrors the Agora front-camera preview', () {
      expect(
        agoraLocalPreviewMirrorMode(isFrontCamera: true),
        VideoMirrorModeType.videoMirrorModeEnabled,
      );
    });

    test('does not mirror the Agora rear-camera preview', () {
      expect(
        agoraLocalPreviewMirrorMode(isFrontCamera: false),
        VideoMirrorModeType.videoMirrorModeDisabled,
      );
    });
  });
}
