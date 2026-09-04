import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import 'package:zartek_core/src/core/api_service/chat_api_service.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/alert.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/update_gate.dart';
import 'package:zartek_core/src/features/home/controller/agent_controller.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';
import 'package:zartek_core/src/features/chat/controller/chat_access_controller.dart';
import 'package:zartek_core/src/features/chat/controller/user_controller.dart';
import 'package:zartek_core/src/features/chat/data/user_model.dart';
import 'package:zartek_core/src/features/chat/providers.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Note: this is a PageView child in nav_bar, so it is built once and this
    // fires only on first entry. Repeat coverage comes from nav_bar's
    // onPageChanged / didPopNext.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userListControllerProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          strings.t(AppStringKey.messages),
          style: AppTextStyle().titleMedium,
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (e, _) => Center(child: Text("Error: 'Chat session expired. Please reopen the app and try again.'")),
        data: (users) {
          precacheAvatarUrls(
            context,
            users.expand((user) => [user.mainAvatarUrl, user.avatarUrl]),
          );
          if (users.isEmpty) {
            return Center(child: Text(strings.t(AppStringKey.noMessagesYet)));
          }
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 100.h),
                itemCount: users.length,
                separatorBuilder: (_, __) => verticalSpaceMedium,
                itemBuilder: (_, index) => _chatTile(context, users[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chatTile(BuildContext context, ChatUser user) {
    final last = user.lastMessage;
    final strings = ref.watch(appStringsProvider);
    final agentState = ref.watch(agentProvider);
    final agent = agentState.agents.cast<Agent?>().firstWhere(
      (a) => a?.email == user.email,
      orElse: () => null,
    );
    final avatarUrl =
        normalizeAvatarUrl(
          agent?.avatar_url,
          baseUrl: ChatApiService().rootBaseUrl,
        ) ??
        user.resolvedAvatarUrl;

    return InkWell(
      onTap: () async {
        // final canChat = ref.read(canChatProvider);
        final canView = ref.read(canViewProvider);
        final reason = ref.read(chatReasonProvider) ?? "don't have access";

        if (!canView) {
          Alert.showToast(
            strings.tf(AppStringKey.cannotProceedBecause, {'reason': reason}),
            isLong: true,
          );
          return;
        }

        ref.read(activeChatPeerEmailProvider.notifier).state =
            normalizeChatPeerEmail(user.email);
        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => ChatScreen(user: user),
          ),
        );
        if (!mounted) return;
        ref.read(activeChatPeerEmailProvider.notifier).state = null;
        ref.read(userListControllerProvider.notifier).resetUnreadCount(user.userId);
      },
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 28.sp,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: cachedAvatarProvider(avatarUrl),
                child: avatarUrl == null
                    ? Icon(Icons.person, color: Colors.grey.shade600)
                    : null,
              ),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 7.sp,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 6.sp,
                    backgroundColor: user.isActive
                        ? const Color(0xFF549A44)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          horizontalSpaceMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle().titleSmall,
                ),
                verticalSpaceSmall,
                Text(
                  last?.content ?? strings.t(AppStringKey.noMessages),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle().bodyMedium.copyWith(
                    fontWeight: user.unreadMessages > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          horizontalSpaceSmall,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                last != null ? _formatTime(last.timestamp) : "",
                style: AppTextStyle().bodySmall.copyWith(color: Palette.grey),
              ),
              verticalSpaceSmall,
              user.unreadMessages > 0
             ? Container(
                width: 20.sp,
                height: 20.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Palette.deepRoyalVioletBegin,
                      Palette.deepRoyalVioletMid,
                      Palette.deepRoyalVioletEnd,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    user.unreadMessages.toString(),
                    style: AppTextStyle().bodySmall.copyWith(
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              )
                  : SizedBox(height: 20.sp),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
