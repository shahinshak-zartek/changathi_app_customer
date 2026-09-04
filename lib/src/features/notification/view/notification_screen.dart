
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/app_text_style.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/update_gate.dart';
import 'package:zartek_core/src/features/notification/controller/notification_controller.dart';

import '../widget/notification_tile.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(notificationControllerProvider.notifier);
      controller.markAllReadOnOpen();
      controller.getNotificationData(reset: true, onlyUnread: false);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationControllerProvider.notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        return "${difference.inDays} days ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hours ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} min ago";
      } else {
        return "Just now";
      }
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
            onPressed: () => NavigationService.pop(),
            icon: GradientItems(
                child: Icon(CupertinoIcons.back, color: Colors.white))),
        centerTitle: true,
        title: Text(strings.t(AppStringKey.notifications), style: AppTextStyle().bodyLarge),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     ref.read(notificationControllerProvider.notifier).clearAll();
          //   },
          //   child: Text("Clear All", style: AppTextStyle().bodyMedium.copyWith(color: Colors.red)),
          // )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0.sp),
          child: state.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error) => Center(child: Text(error)),
            success: (notification, isFetchingMore) {
              final items = notification?.data?.items ?? [];

              if (items.isEmpty) {
                return Center(child: Text("No notifications", style: AppTextStyle().bodyLarge));
              }

              return ListView.separated(
                controller: _scrollController,
                separatorBuilder: (context, index) => verticalSpaceSmall,
                itemCount: items.length + (isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                  
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      // log("taped noti");
                      // if (item.is_read != true && item.id != null) {
                      //    ref.read(notificationControllerProvider.notifier).markAsRead(item.id!);
                      // }
                    },
                    child: Opacity(
                      opacity: item.is_read == true ? 0.6 : 1.0,
                      child: NotificationTile(
                        message: item.message ?? "",
                        icon: "",
                        title: item.title ?? "",
                        time: _formatTime(item.created_at),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
