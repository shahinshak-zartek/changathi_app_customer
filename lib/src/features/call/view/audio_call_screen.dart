import 'dart:io';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:screen_protector/screen_protector.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/src/features/call/controller/audio_call_controller.dart';
import 'package:zartek_core/src/features/call/model/call_state_model.dart';
import '../widget/call_rating_dialog.dart';

class AudioCallScreen extends ConsumerStatefulWidget {
  final Agent agent;

  const AudioCallScreen({super.key, required this.agent});

  @override
  ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends ConsumerState<AudioCallScreen>
    with WidgetsBindingObserver {
  bool _isPopped = false;
  bool _manualEndPending = false;
  bool _lowBalanceWarned = false;
  bool _showLowBalanceBanner = false;
  Timer? _lowBalanceBannerTimer;
  static const Duration _manualEndDelay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    secureScreen();
  }

  @override
  void dispose() {
    _lowBalanceBannerTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    disableSecureScreen();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(audioCallControllerProvider.notifier).recoverCallState();
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

  void _safePop() {
    if (_isPopped || !mounted) return;
    _isPopped = true;
    Navigator.of(context).pop();
  }

  Future<void> _endCallAfterInitialDelay() async {
    if (_manualEndPending) return;
    _manualEndPending = true;
    try {
      final callState = ref.read(audioCallControllerProvider);
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

      final latestStatus = ref.read(audioCallControllerProvider).status;
      if (latestStatus == CallStatus.ended ||
          latestStatus == CallStatus.failed ||
          latestStatus == CallStatus.declined) {
        return;
      }

      await ref.read(audioCallControllerProvider.notifier).endCall();
    } finally {
      _manualEndPending = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(audioCallControllerProvider);

    // Auto-initiate call when screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(audioCallControllerProvider).status == CallStatus.idle) {
        ref
            .read(audioCallControllerProvider.notifier)
            .initiateCall(
              agentId: widget.agent.id,
              agentName: widget.agent.name,
              agentAvatar: widget.agent.avatar_url,
            );
      }
    });

    ref.listen(audioCallControllerProvider, (previous, next) {
      _maybeShowLowBalanceWarning(next);
      if (previous?.status != next.status) {
        log(
          'UI AUDIO STATE: ${previous?.status} -> ${next.status} | callId=${next.callId} remoteUid=${next.remoteUid} error=${next.errorMessage}',
        );
      }

      /// Check if call was actually connected
      final wasConnected =
          next.callDuration > 0 ||
          next.remoteUid != null ||
          next.remoteParticipantIdentity != null;

      /// CASE 1: Show rating ONLY for real calls
      if (next.status == CallStatus.ended &&
          previous?.status != CallStatus.ended &&
          wasConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CallRatingDialog(
              agentName: widget.agent.name,
              onRatingSelected: (rating) async {
                await ref
                    .read(audioCallControllerProvider.notifier)
                    .rateCall(rating);
                if (mounted) {
                  Navigator.of(context).pop();
                  _safePop();
                }
              },
            ),
          );
        });
      }
      /// CASE 2: Ended but NOT connected → just close screen
      else if (next.status == CallStatus.ended && !wasConnected) {
        log("Call ended without connection → closing screen");

        Future.delayed(const Duration(milliseconds: 500), () {
          _safePop();
        });
      }
      /// CASE 3: Failed / Declined → close
      else if (next.status == CallStatus.failed ||
          next.status == CallStatus.declined) {
        log(" Failed/Declined → closing screen");
        Future.delayed(const Duration(seconds: 1), () {
          _safePop();
        });
      }
    });

    final isTerminalState =
        callState.status == CallStatus.ended ||
        callState.status == CallStatus.failed ||
        callState.status == CallStatus.declined;

    return PopScope(
      canPop: isTerminalState,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Show confirmation dialog before ending call
        final shouldEnd = await _showEndCallDialog(context);
        if (shouldEnd == true && mounted) {
          await _endCallAfterInitialDelay();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF12086F),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, callState),
              SizedBox(height: 10.h),
              _buildStatusText(callState),
              SizedBox(height: 20.h),
              _buildAgentInfo(callState),
              SizedBox(height: 10.h),
              if (callState.status == CallStatus.connected)
                _buildDuration(callState),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Any abuse, sexual Talk, or illegal activity\nwill lead to immediate and\npermanent account suspension.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                ],
              ),
              const Spacer(),
              _buildLowBalanceBanner(),
              _buildAvailableDuration(callState),
              SizedBox(height: 20.h),
              _buildCallControls(context, ref, callState),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, CallStateModel callState) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.white70, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            'End-to-end encrypted',
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          const Spacer(),
          if (callState.status == CallStatus.reconnecting)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.h,
                    child: const CupertinoActivityIndicator(),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Reconnecting...',
                    style: TextStyle(color: Colors.orange, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgentInfo(CallStateModel callState) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 150.w,
          height: 150.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [const Color(0xFF6C63FF), const Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: (callState.agentAvatar ?? widget.agent.avatar_url).isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: callState.agentAvatar ?? widget.agent.avatar_url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CupertinoActivityIndicator()),
                    errorWidget: (context, url, error) => _buildDefaultAvatar(
                      callState.agentName ?? widget.agent.name,
                    ),
                  ),
                )
              : _buildDefaultAvatar(callState.agentName ?? widget.agent.name),
        ),

        SizedBox(height: 20.h),

        // Agent name
        Text(
          callState.agentName ?? widget.agent.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String? name) {
    return Center(
      child: Text(
        name?.isNotEmpty == true ? name![0].toUpperCase() : 'A',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusText(CallStateModel callState) {
    String statusText;
    Color statusColor;

    switch (callState.status) {
      case CallStatus.reserving:
        statusText = 'Reserving call...';
        statusColor = Colors.white70;
        break;
      case CallStatus.reserved:
        statusText = 'Call reserved';
        statusColor = Colors.white70;
        break;
      case CallStatus.starting:
        statusText = 'Starting...';
        statusColor = Colors.white70;
        break;
      case CallStatus.ringing:
        statusText = 'Ringing...';
        statusColor = Colors.white70;
        break;
      case CallStatus.connecting:
        statusText = 'Ringing...';
        statusColor = Colors.white70;
        break;
      case CallStatus.connected:
        statusText = 'Connected';
        statusColor = Colors.green;
        break;
      case CallStatus.reconnecting:
        statusText = 'Reconnecting...';
        statusColor = Colors.orange;
        break;
      case CallStatus.disconnected:
        statusText = 'Disconnected';
        statusColor = Colors.red;
        break;
      case CallStatus.ended:
        statusText = 'Call ended';
        statusColor = Colors.white70;
        break;
      case CallStatus.failed:
        statusText = callState.errorMessage ?? 'Call failed';
        statusColor = Colors.red;
        break;
      case CallStatus.missed:
        statusText = 'Call missed';
        statusColor = Colors.red;
        break;
      case CallStatus.declined:
        statusText = 'Declined';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Initiating...';
        statusColor = Colors.white70;
    }

    return Text(
      statusText,
      style: TextStyle(color: statusColor, fontSize: 16.sp),
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
    final rate = widget.agent.audio_rate;
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red..withValues(alpha: 0.8),
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
    final rate = widget.agent.audio_rate;
    if (rate <= 0 || balance <= 0) {
      return const SizedBox.shrink();
    }

    final totalSeconds = (balance / rate).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
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
              TextSpan(text: ' with your wallet balance'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildDuration(CallStateModel callState) {
    final duration = callState.callDuration;
    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');

    return Container(
      width: 140.w,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '$minutes:$seconds',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(
    BuildContext context,
    WidgetRef ref,
    CallStateModel callState,
  ) {
    final controller = ref.read(audioCallControllerProvider.notifier);
    final isCallActive =
        callState.status == CallStatus.connected ||
        callState.status == CallStatus.connecting ||
        callState.status == CallStatus.reconnecting;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _buildControlButton(
            icon: callState.isMuted ? Icons.mic_off : Icons.mic,
            label: callState.isMuted ? 'Unmute' : 'Mute',
            isActive: callState.isMuted,
            onTap: isCallActive ? () => controller.toggleMute() : null,
          ),

          // End call button
          _buildEndCallButton(
            onTap: () async {
              await _endCallAfterInitialDelay();
            },
          ),

          // Speaker button
          _buildControlButton(
            icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: callState.isSpeakerOn ? 'Speaker' : 'Earpiece',
            isActive: callState.isSpeakerOn,
            onTap: isCallActive ? () => controller.toggleSpeaker() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF6C63FF)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28
                  .sp, // Note: You might need to change to .sp manually if formatting breaks
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildEndCallButton({required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.call_end, color: Colors.white, size: 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'End Call',
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
      ],
    );
  }

  Future<bool?> _showEndCallDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D44),
        title: const Text('End Call?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to end this call?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}
