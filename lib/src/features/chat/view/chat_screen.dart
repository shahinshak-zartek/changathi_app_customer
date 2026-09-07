import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';
import 'package:zartek_core/src/core/api_service/chat_api_service.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import 'package:zartek_core/src/util/alert.dart';
import 'package:zartek_core/src/features/home/controller/agent_controller.dart';
import 'package:zartek_core/src/features/home/model/agent_model.dart';
import 'package:zartek_core/src/features/chat/controller/chat_access_controller.dart';
import 'package:zartek_core/src/features/chat/controller/chat_controller.dart';
import 'package:zartek_core/src/features/chat/controller/event_controller.dart';
import 'package:zartek_core/src/features/chat/controller/user_controller.dart';
import 'package:zartek_core/src/features/chat/data/user_model.dart';
import 'package:zartek_core/src/features/chat/providers.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';
import '../widget/chat_bubble.dart';
import '../widget/report_message_bottom_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final text = TextEditingController();
  bool _isSending = false;
  ProviderContainer? _providerContainer;

  @override
  void initState() {
    super.initState();
    _providerContainer = ProviderScope.containerOf(context, listen: false);
    final peerEmail = normalizeChatPeerEmail(widget.user.email);

    Future<void>(() {
      if (!mounted) return;
      ref.read(activeChatPeerEmailProvider.notifier).state = peerEmail;
      ref.read(eventControllerProvider.notifier).start();
      ref.read(chatControllerProvider.notifier).loadMessages(widget.user.email);
      ref.read(userListControllerProvider.notifier).resetUnreadCount(widget.user.userId);
    });
  }

  @override
  void dispose() {
    final peerEmail = normalizeChatPeerEmail(widget.user.email);
    final container = _providerContainer;
    Future<void>(() {
      if (container?.read(activeChatPeerEmailProvider) == peerEmail) {
        container?.read(activeChatPeerEmailProvider.notifier).state = null;
      }
    });
    text.dispose();
    super.dispose();
  }

  Widget _composer() {
    final strings = ref.read(appStringsProvider);
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(20.sp),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: text,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: strings.t(AppStringKey.typeYourMessage),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Palette.deepRoyalVioletMid),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Palette.deepRoyalVioletMid),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Palette.deepRoyalVioletMid, width: 2.0,),
                  ),
                ),
              ),
            ),
            horizontalSpaceSmall,
            GestureDetector(
              onTap: _isSending
                  ? null
                  : () async {
                final msg = text.text.trim();
                if (msg.isEmpty) return;

                final canChat = ref.read(canChatProvider);
                final reason = ref.read(chatReasonProvider) ?? "check your chat plan in wallet";

                if (!canChat) {
                  Alert.showToast(
                    strings.tf(AppStringKey.cannotProceedBecause, {
                      'reason': reason,
                    }),
                    isLong: true,
                    actionLabel: 'Purchase',
                    onActionPressed: () {
                      NavigationService.push(
                        page: AppRoutes.wallet,
                        arguments: 1,
                      );
                    },
                  );
                  return;
                }
                //
                // final bootstrap = ref.read(chatAccessControllerProvider).value;
                // final canChat = bootstrap?.data?.can_chat ?? false;
                // final activePlan = bootstrap?.data?.active_chat_plan;
                // final reason = bootstrap?.data?.reason ?? "don't have access";
                //
                // if (!canChat) {
                //   Alert.showToast("you can't proceed, because $reason", isLong: true);
                //   return;
                // }
                //
                // if (activePlan == null) {
                //   Alert.showToast("you don't have any chat subscription plan", isLong: true);
                //   return;
                // }
                setState(() {
                  _isSending = true;
                });
                text.clear();
                try {
                  await ref.read(chatControllerProvider.notifier).send(
                        widget.user.email,
                        msg,
                      );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSending = false;
                    });
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Palette.deepRoyalPinkBegin,
                      Palette.deepRoyalVioletMid,
                      Palette.deepSkyBlueEnd,
                    ],
                  ),
                ),
                child: SizedBox(
                  width: 25.w,
                  height: 25.h,
                  child: _isSending
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : SvgPicture.asset(Assets.message),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);
    final strings = ref.watch(appStringsProvider);
    final agentState = ref.watch(agentProvider);
    final agent = agentState.agents.cast<Agent?>().firstWhere(
      (a) => a?.email == widget.user.email,
      orElse: () => null,
    );
    final avatarUrl =
        normalizeAvatarUrl(
          agent?.avatar_url,
          baseUrl: ChatApiService().rootBaseUrl,
        ) ??
        widget.user.resolvedAvatarUrl;
    final avatarProvider = cachedAvatarProvider(avatarUrl);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: GradientItems(
            child: Icon(CupertinoIcons.back, color: Colors.white, size: 22.sp),
          ),
        ),
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: getWidth(context: context) * 0.9 / 8,
                  height: getWidth(context: context) * 0.9 / 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: avatarProvider != null
                        ? DecorationImage(
                            image: avatarProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: avatarProvider == null
                        ? Colors.grey.shade200
                        : null,
                  ),
                  child: avatarProvider == null
                      ? Icon(Icons.person, color: Colors.grey.shade600)
                      : null,
                ),
                // Positioned(
                //   right: 0,
                //   child: CircleAvatar(
                //     radius: 5.sp,
                //     backgroundColor: Colors.white,
                //     child: CircleAvatar(
                //       radius: 4.sp,
                //       backgroundColor: widget.user.isActive
                //           ? const Color(0xFF549A44)
                //           : Colors.grey.shade300,
                //     ),
                //   ),
                // ),
              ],
            ),
            horizontalSpaceSmall,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: AppTextStyle().bodyMedium.copyWith(fontSize: 15.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Text(
                //   widget.user.email,
                //   style: AppTextStyle().bodySmall,
                // ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: chat.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(child: Text(strings.t(AppStringKey.noMessagesYet)));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    return ChatBubble(
                      content: m.content,
                      isMe: m.isMe,
                      timestamp: m.timestamp,
                      onLongPress: () {
                        // reported message + 9 preceding (older) messages
                        final end = (i + 10).clamp(0, messages.length);
                        final slice = messages.sublist(i, end);

                        showReportMessageBottomSheet(
                          context,
                          contextMessages: slice,
                          reportedMessageId: m.id,
                          reportedUserId: widget.user.userId.toString(),
                          reportedUserMail: widget.user.email.toString(),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
          _composer(),
        ],
      ),
    );
  }
}
