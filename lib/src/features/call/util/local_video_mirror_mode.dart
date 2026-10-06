import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

lk.VideoViewMirrorMode liveKitLocalPreviewMirrorMode({
  required bool isFrontCamera,
}) => isFrontCamera
    ? lk.VideoViewMirrorMode.mirror
    : lk.VideoViewMirrorMode.off;

VideoMirrorModeType agoraLocalPreviewMirrorMode({
  required bool isFrontCamera,
}) => isFrontCamera
    ? VideoMirrorModeType.videoMirrorModeEnabled
    : VideoMirrorModeType.videoMirrorModeDisabled;
