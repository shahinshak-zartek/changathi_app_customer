import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zartek_core/zartek_core.dart'
    show CallPermissionService, CallPermissionResult;
import 'package:zartek_core/src/app/app_routes.dart';
import 'package:zartek_core/src/features/chat/data/user_model.dart';
import 'package:zartek_core/src/features/chat/controller/chat_access_controller.dart';
import 'package:zartek_core/src/features/home/controller/home_data_controller.dart';
import 'package:zartek_core/src/util/alert.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/features/home/controller/agent_controller.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';

import '../../../constants/assets.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../widget/agent_tile.dart';

enum AgentFilterType { all, audio, video }

class AgentListScreen extends StatefulWidget {
  final AgentFilterType filterType;

  const AgentListScreen({super.key, this.filterType = AgentFilterType.all});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  final CallPermissionService _callPermissionService =
      const CallPermissionService();

  /// Guards against a second tap landing while the system permission sheet is
  /// still up.
  bool _permissionRequestInFlight = false;

  /// Returns `true` only when the call should start *now*.
  ///
  /// A permission the user has already granted starts the call on the first
  /// tap. A permission granted just now does **not**: the system sheet consumed
  /// that tap, so launching straight into a call would give the user no chance
  /// to change their mind, and on a slow device the call screen would appear
  /// from what felt like a tap on the permission dialog. We toast instead and
  /// let the next tap place the call.
  Future<bool> _confirmCallPermissions({required bool isVideoCall}) async {
    if (_permissionRequestInFlight) return false;
    _permissionRequestInFlight = true;
    try {
      final CallPermissionResult existing = await _callPermissionService.check(
        isVideoCall: isVideoCall,
      );
      if (existing.isGranted) return true;

      final CallPermissionResult result = await _callPermissionService
          .requestIfNeeded(isVideoCall: isVideoCall);
      if (!mounted) return false;

      if (result.isGranted) {
        // Read from `existing`, not `result`: now that everything is granted,
        // `result.missingPermissions` is empty and no longer names what was
        // asked for, so the message would degrade to "call permissions".
        Alert.showToast(existing.grantedNeedsSecondTapMessage);
        return false;
      }

      if (result.canOpenSettings) {
        // Permanently denied or restricted — the OS will not prompt again, so
        // "allow access" would be advice the user cannot act on from here.
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Call Permission Required'),
              content: Text(result.userMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            );
          },
        );
        if (shouldOpenSettings == true) {
          await _callPermissionService.openAppPermissionSettings();
        }
      } else {
        Alert.showErrorToast(result.userMessage, isLong: true);
      }

      return false;
    } finally {
      _permissionRequestInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final agentState = ref.watch(agentProvider);
        final isVideoCallEnabled = ref.watch(isVideoCallFeatureEnabledProvider);
        final isAudioCallEnabled = ref.watch(isAudioCallFeatureEnabledProvider);
        final isChatEnabled = ref.watch(isChatFeatureEnabledProvider);
        final strings = ref.watch(appStringsProvider);

        return agentState.when((agents, isConnected, error) {
          List<Agent> filteredAgents = agents.where((a) {
            if (widget.filterType == AgentFilterType.all) {
              return true;
            }

            bool isVisibleStatus =
                a.status == 'online' ||
                a.status == 'in_call' ||
                a.status == 'reserved';
            if (!isVisibleStatus) {
              return false;
            }

            if (widget.filterType == AgentFilterType.audio &&
                !a.audio_enabled) {
              return false;
            }
            if (widget.filterType == AgentFilterType.video &&
                !a.video_enabled) {
              return false;
            }

            return true;
          }).toList();

          // Status group → most recently online (`online_since`) → name.
          // The comparator lives in zartek_core so every clone lists agents the
          // same way; its edge cases are covered by the core's tests.
          filteredAgents.sort(compareAgentsForListing);

          precacheAvatarUrls(
            context,
            filteredAgents.map((agent) => agent.avatar_url),
          );

          if (filteredAgents.isEmpty) {
            if (!isConnected && agents.isEmpty) {
              return Center(child: CupertinoActivityIndicator());
            }
            return Center(child: Text(_emptyMessage()));
          }

          return SizedBox(
            child: ListView.builder(
              itemCount: filteredAgents.length,
              itemBuilder: (context, index) {
                final agent = filteredAgents[index];

                Widget tile = AgentTile(
                  agent: agent,
                  agentIsOnline: agent.status == "online",
                  isVideoCallFeatureEnabled: isVideoCallEnabled,
                  isAudioCallFeatureEnabled: isAudioCallEnabled,
                  isChatFeatureEnabled: isChatEnabled,
                  onTapChat: () {
                    if (!isChatEnabled) {
                      Alert.showToast("admin restricted your chat action");
                      return;
                    }
                    final chatAccess = ref.read(chatAccessControllerProvider);
                    if (chatAccess.isLoading) {
                      Alert.showToast(
                        "Checking chat access. Please try again.",
                      );
                      return;
                    }

                    final bootstrap = chatAccess.value;
                    if (chatAccess.hasError || bootstrap == null) {
                      Alert.showToast(
                        "Chat access is currently unavailable. Please try again.",
                      );
                      return;
                    }

                    // Opening the thread is gated on can_view; can_chat still
                    // gates *sending* inside ChatScreen, so a view-only user is
                    // not given a way to send.
                    final canView = ref.read(canViewProvider);
                    final rawReason = ref.read(chatReasonProvider);
                    final reason = rawReason ?? "don't have access";
                    // Only offer Purchase when buying a plan is actually the
                    // fix — an admin block is not solved by spending money.
                    final showPurchase = chatReasonNeedsPurchase(rawReason);

                    if (!canView) {
                      Alert.showToast(
                        strings.tf(AppStringKey.cannotProceedBecause, {
                          'reason': reason,
                        }),
                        isLong: true,
                        actionLabel: showPurchase ? 'Purchase' : null,
                        actionIcon: showPurchase ? Assets.coin : null,
                        onActionPressed: showPurchase
                            ? () {
                                NavigationService.push(
                                  page: AppRoutes.wallet,
                                  arguments: 1, // chat-plan tab
                                );
                              }
                            : null,
                      );
                      return;
                    }

                    final user = ChatUser(
                      userId: 0,
                      email: agent.email,
                      fullName: agent.name,
                      isActive: agent.status == "online",
                      isPinned: false,
                      unreadMessages: 0,
                      avatarUrl: agent.avatar_url,
                      lastMessage: null,
                    );
                    NavigationService.push(page: AppRoutes.singleChat, arguments: user,);
                  },
                  onTapVoiceCall: () async {
                    if (!isAudioCallEnabled) {
                      Alert.showToast(
                        "admin restricted your audio call action",
                      );
                      return;
                    }
                    if (!agent.audio_allowed) {
                      Alert.showToast(
                        strings.t(AppStringKey.adminRestrictedAction),
                      );
                      return;
                    }
                    // After the admin checks, so a restricted agent gets its
                    // own toast rather than a permission sheet it cannot use.
                    if (!await _confirmCallPermissions(isVideoCall: false)) {
                      return;
                    }
                    NavigationService.push(page: AppRoutes.audioCall, arguments: agent,);
                  },
                  onTapVideoCall: () async {
                    if (!isVideoCallEnabled) {
                      Alert.showToast(
                        "admin restricted your video call action",
                      );
                      return;
                    }
                    if (!agent.video_allowed) {
                      Alert.showToast(
                        strings.t(AppStringKey.adminRestrictedAction),
                      );
                      return;
                    }
                    // Asks for microphone *and* camera; granting only one does
                    // not start the call.
                    if (!await _confirmCallPermissions(isVideoCall: true)) {
                      return;
                    }
                    NavigationService.push(page: AppRoutes.videoCall, arguments: agent,);
                  },
                );

                if (index == filteredAgents.length - 1) {
                  return Column(
                    children: [tile, verticalSpaceLarge, verticalSpaceLarge],
                  );
                }
                return tile;
              },
            ),
          );
        });
      },
    );
  }

  String _emptyMessage() {
    switch (widget.filterType) {
      case AgentFilterType.audio:
        return 'No agents available for Audio call';
      case AgentFilterType.video:
        return 'No agents available for video call';
      case AgentFilterType.all:
        return 'No agents available';
    }
  }
}
