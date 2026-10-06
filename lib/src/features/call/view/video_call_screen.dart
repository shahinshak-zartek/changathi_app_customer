import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zartek_core/src/features/home/model/agent_model.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/src/features/call/controller/video_call_controller.dart';
import 'package:zartek_core/src/features/call/model/call_state_model.dart';
import 'package:zartek_core/src/features/call/service/call_media_service.dart';

import '../util/local_video_mirror_mode.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final Agent agent;

  const VideoCallScreen({super.key, required this.agent});

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen>
    with WidgetsBindingObserver {
  final CallMediaService _mediaService = CallMediaService();
  int? _remoteUid;
  StreamSubscription? _remoteUidSub;
  StreamSubscription? _videoTrackSub;
  bool _isPopped = false;
  bool _manualEndPending = false;
  bool _lowBalanceWarned = false;
  bool _showLowBalanceBanner = false;
  Timer? _lowBalanceBannerTimer;
  static const Duration _manualEndDelay = Duration(seconds: 5);

  void _safePop() {
    if (_isPopped || !mounted) return;
    _isPopped = true;
    Navigator.pop(context);
  }

  Future<void> _endCallAfterInitialDelay() async {
    if (_manualEndPending) return;
    _manualEndPending = true;
    try {
      final callState = ref.read(videoCallControllerProvider);
      final startTime = callState.startTime;
      final elapsed = startTime == null
          ? Duration.zero
          : DateTime.now().difference(startTime);
      final delay = elapsed >= _manualEndDelay
          ? Duration.zero
          : _manualEndDelay - elapsed;
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
      if (!mounted) return;

      final latestStatus = ref.read(videoCallControllerProvider).status;
      if (latestStatus == CallStatus.ended ||
          latestStatus == CallStatus.failed ||
          latestStatus == CallStatus.declined) {
        return;
      }

      await ref.read(videoCallControllerProvider.notifier).endCall();
    } finally {
      _manualEndPending = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    secureScreen();
    _remoteUidSub = _mediaService.remoteUidStream.listen((uid) {
      if (mounted) setState(() => _remoteUid = uid);
    });
    _videoTrackSub = _mediaService.videoTrackChangedStream.listen((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(videoCallControllerProvider.notifier)
          .initiateCall(
            agentId: widget.agent.id,
            agentName: widget.agent.name,
            agentAvatar: widget.agent.avatar_url,
          );
    });
  }

  @override
  void dispose() {
    _lowBalanceBannerTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    disableSecureScreen();
    _remoteUidSub?.cancel();
    _videoTrackSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(videoCallControllerProvider.notifier).recoverCallState();
    }
  }

  Future<void> secureScreen() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOn();
      } else if (Platform.isIOS) {
        await ScreenProtector.preventScreenshotOn();
        await ScreenProtector.protectDataLeakageWithBlur();
      }
    } catch (e) {
      debugPrint("Error securing screen: $e");
    }
  }

  Future<void> disableSecureScreen() async {
    try {
      if (Platform.isAndroid) {
        await ScreenProtector.protectDataLeakageOff();
      } else if (Platform.isIOS) {
        await ScreenProtector.preventScreenshotOff();
      }
    } catch (e) {
      debugPrint("Error disabling secure screen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(videoCallControllerProvider);
    ref.listen(videoCallControllerProvider, (previous, next) {
      _maybeShowLowBalanceWarning(next);
      if (previous?.status != next.status) {
        log(
          'UI VIDEO STATE: ${previous?.status} -> ${next.status} | callId=${next.callId} remoteUid=${next.remoteUid} error=${next.errorMessage}',
        );
      }

      if (next.status == CallStatus.ended &&
          previous?.status != CallStatus.ended) {
        log("🎥 Call ended → closing screen");

        Future.delayed(const Duration(milliseconds: 500), () {
          _safePop();
        });
      }
      ///  CASE 3: Failed / Declined → close
      else if (next.status == CallStatus.failed ||
          next.status == CallStatus.declined) {
        log("🎥 Failed/Declined → closing screen");

        Future.delayed(const Duration(seconds: 1), () {
          _safePop();
        });
      }
    }); // // Navigation Listener
    final isTerminalState =
        callState.status == CallStatus.ended ||
        callState.status == CallStatus.failed ||
        callState.status == CallStatus.declined;

    return PopScope(
      canPop: isTerminalState,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldEnd = await _showEndCallDialog(context);
        if (shouldEnd == true && mounted) {
          await _endCallAfterInitialDelay();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Stack(
          children: [
            /// 1. Remote Video (Full Screen)
            Positioned.fill(child: _buildRemoteVideo(callState)),

            /// 2. Top Info Overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              right: 16.w,
              child: _buildTopUserInfo(callState),
            ),

            /// 3. Floating Local Preview (Fixed Position)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80.h,
              right: 16.w,
              child: _buildLocalVideo(callState),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 180.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                children: [
                  _buildAvailableDuration(callState),
                  _buildLowBalanceBanner(),
                ],
              ),
            ),

            /// 4. Static Bottom Controls (No longer draggable)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildStaticControls(callState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo(CallStateModel callState) {
    if (callState.provider == 'livekit') {
      final track = _mediaService.liveKitRemoteVideoTrack;
      final isLiveKitVideoAvailable =
          track != null &&
          callState.status == CallStatus.connected &&
          callState.isRemoteVideoEnabled;
      return isLiveKitVideoAvailable
          ? lk.VideoTrackRenderer(track, fit: lk.VideoViewFit.cover)
          : _buildRemoteAudioUI(callState);
    }

    final isVideoAvailable =
        _mediaService.isInitialized &&
        _remoteUid != null &&
        callState.status == CallStatus.connected &&
        callState.isRemoteVideoEnabled;

    return isVideoAvailable
        ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _mediaService.agoraEngineSafe,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: callState.channelName),
            ),
          )
        : _buildRemoteAudioUI(callState);
  }

  Widget _buildTopUserInfo(CallStateModel callState) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16.w,
            backgroundImage: widget.agent.avatar_url.isNotEmpty
                ? CachedNetworkImageProvider(widget.agent.avatar_url)
                : null,
            child: widget.agent.avatar_url.isEmpty
                ? Text(widget.agent.name[0])
                : null,
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.agent.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                callState.status == CallStatus.connected
                    ? ref
                          .read(videoCallControllerProvider.notifier)
                          .formattedDuration
                    : _getStatusText(callState.status),
                style: TextStyle(color: Colors.white70, fontSize: 11.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalVideo(CallStateModel callState) {
    final isLiveKit = callState.provider == 'livekit';
    final liveKitLocalTrack = _mediaService.liveKitLocalVideoTrack;
    return Container(
      width: 100.w,
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child:
            (callState.isVideoEnabled && isLiveKit && liveKitLocalTrack != null)
            ? lk.VideoTrackRenderer(
                liveKitLocalTrack,
                fit: lk.VideoViewFit.cover,
                mirrorMode: liveKitLocalPreviewMirrorMode(
                  isFrontCamera: callState.isFrontCamera,
                ),
              )
            : (callState.isVideoEnabled &&
                  !isLiveKit &&
                  _mediaService.isInitialized)
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _mediaService.agoraEngineSafe,
                  canvas: VideoCanvas(
                    uid: 0,
                    mirrorMode: agoraLocalPreviewMirrorMode(
                      isFrontCamera: callState.isFrontCamera,
                    ),
                  ),
                ),
              )
            : Container(
                color: const Color(0xFF2D2D44),
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white24,
                  size: 28.sp,
                ),
              ),
      ),
    );
  }

  Widget _buildStaticControls(CallStateModel callState) {
    final controller = ref.read(videoCallControllerProvider.notifier);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            0.w,
            10.h,
            0.w,
            MediaQuery.of(context).padding.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleActionBtn(
                    icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                    onTap: () => controller.toggleMute(),
                    isActive: callState.isMuted,
                  ),
                  _circleActionBtn(
                    icon: Icons.flip_camera_ios,
                    onTap: () => controller.switchCamera(),
                  ),
                  _pillBtn(
                    icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: "",
                    onTap: () => controller.toggleSpeaker(),
                    active: callState.isSpeakerOn,
                  ),
                  _circleActionBtn(
                    icon: Icons.close,
                    onTap: () async {
                      await _endCallAfterInitialDelay();
                    },
                    color: Colors.red,
                    // size: 64,
                  ),
                ],
              ),
              // SizedBox(height: 20.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     SizedBox(
              //       width: 30.h,
              //       child: _pillBtn(
              //         icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              //         label: "s",
              //         onTap: () => controller.toggleSpeaker(),
              //         active: callState.isSpeakerOn,
              //       ),
              //     ),
              //   ],
              // ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: _pillBtn(
              //         icon: callState.isVideoEnabled
              //             ? Icons.videocam
              //             : Icons.videocam_off,
              //         label: "Video",
              //         onTap: () => controller.toggleVideo(),
              //         active: callState.isVideoEnabled,
              //       ),
              //     ),
              //     SizedBox(width: 12.w),
              //     Center(
              //       child: Row(
              //         children: [
              //           SizedBox(
              //             width: 120.h,
              //             child: Expanded(
              //               child: _pillBtn(
              //                 icon: callState.isSpeakerOn
              //                     ? Icons.volume_up
              //                     : Icons.volume_down,
              //                 label: "Speaker",
              //                 onTap: () => controller.toggleSpeaker(),
              //                 active: callState.isSpeakerOn,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    bool isActive = false,
    double size = 54,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (isActive ? Colors.white24 : Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: (size * 0.5).sp),
      ),
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: 54,
        decoration: ShapeDecoration(
          color: active ? Colors.white24 : Colors.white10,
          shape: StadiumBorder(
            side: BorderSide(
              color: active ? Colors.white24 : Colors.transparent,
            ),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 27.sp),
      ),
    );
  }
  // Widget _pillBtn({
  //   required IconData icon,
  //   required String label,
  //   required VoidCallback onTap,
  //   required bool active,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: EdgeInsets.all(15.h),
  //       decoration: BoxDecoration(
  //         color: active ? Colors.white24 : Colors.white10,
  //         borderRadius: BorderRadius.circular(180.r),
  //         border: Border.all(
  //           color: active ? Colors.white24 : Colors.transparent,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: Colors.white, size: 20.sp),
  //           SizedBox(width: 8.w),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 15.sp,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRemoteAudioUI(CallStateModel callState) {
    return Container(
      color: const Color(0xFF1A1A2E),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60.w,
            backgroundImage: widget.agent.avatar_url.isNotEmpty
                ? CachedNetworkImageProvider(widget.agent.avatar_url)
                : null,
            child: widget.agent.avatar_url.isEmpty
                ? Text(widget.agent.name[0], style: TextStyle(fontSize: 40.sp))
                : null,
          ),
          // SizedBox(height: 20.h),
          // Text(_getStatusText(callState.status), style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        ],
      ),
    );
  }

  void _maybeShowLowBalanceWarning(CallStateModel callState) {
    if (_lowBalanceWarned || !mounted) return;
    if (callState.status != CallStatus.connected) return;

    final walletState = ref.read(walletControllerProvider);
    final balance = walletState.maybeWhen(
      success: (wallet) => wallet?.data?.wallet_balance ?? 0,
      orElse: () => 0,
    );
    final rate = widget.agent.video_rate;
    if (rate <= 0 || balance <= 0) return;

    final totalSeconds = (balance / rate).floor();
    if (totalSeconds <= 10) return;
    final elapsed = callState.callDuration;
    if (elapsed >= totalSeconds - 10) {
      _lowBalanceWarned = true;
      if (!mounted) return;
      setState(() => _showLowBalanceBanner = true);
      _lowBalanceBannerTimer?.cancel();
      _lowBalanceBannerTimer = Timer(const Duration(seconds: 7), () {
        if (!mounted) return;
        setState(() => _showLowBalanceBanner = false);
      });
    }
  }

  Widget _buildLowBalanceBanner() {
    if (!_showLowBalanceBanner) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Only 10 seconds remaining in your balance. Please recharge after the call ends.',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDuration(CallStateModel callState) {
    const preConnectedStates = {
      CallStatus.idle,
      CallStatus.reserving,
      CallStatus.reserved,
      CallStatus.starting,
      CallStatus.ringing,
      CallStatus.connecting,
    };
    if (!preConnectedStates.contains(callState.status)) {
      return const SizedBox.shrink();
    }

    final walletState = ref.watch(walletControllerProvider);
    final balance = walletState.maybeWhen(
      success: (wallet) => wallet?.data?.wallet_balance ?? 0,
      orElse: () => 0,
    );
    final rate = widget.agent.video_rate;
    if (rate <= 0 || balance <= 0) {
      return const SizedBox.shrink();
    }

    final totalSeconds = (balance / rate).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'You can call '),
            TextSpan(
              text: widget.agent.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: ' for '),
            TextSpan(
              text: '$minutes min $seconds sec',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: ' with your wallet balance.'),
            TextSpan(text: '\nAny abuse, sexual Talk, or illegal activity\nwill lead to immediate and\npermanent account suspension.'),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white60),
      ),
    );
  }

  String _getStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.connecting:
        return 'Ringing...';
      case CallStatus.ended:
        return 'Disconnected';
      default:
        return 'Connecting...';
    }
  }

  Future<bool?> _showEndCallDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("End Call?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to hang up?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("End", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
