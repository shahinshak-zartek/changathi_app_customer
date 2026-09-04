import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_text_style.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/oops_error.dart';
import '../../../widgets/update_gate.dart';
import 'package:zartek_core/src/features/home/controller/call_history_list_controller.dart';
import '../widget/recent_activity_tile.dart';

class RecentActivityScreen extends ConsumerStatefulWidget {
  const RecentActivityScreen({super.key});

  @override
  ConsumerState<RecentActivityScreen> createState() =>
      _RecentActivityScreenState();
}

class _RecentActivityScreenState extends ConsumerState<RecentActivityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(callHistoryListControllerProvider.notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final state = ref.watch(callHistoryListControllerProvider);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: GradientItems(
            child: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          strings.t(AppStringKey.recentActivity),
          style: AppTextStyle().bodyLarge,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: state.when(
            loading: () =>
                const Center(child: CupertinoActivityIndicator()),
            error: (error) => OopsError(error: error),
            success: (callHistoryList, isFetchingMore) {
              final items = callHistoryList?.data?.items ?? [];
              if (items.isEmpty) {
                // The list is scoped to today, so "No Activity History" would
                // read as "you have no history at all" to a user who simply
                // has not had a call yet today.
                return Center(
                  child: Text(strings.t(AppStringKey.noCallsToday)),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: items.length + (isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= items.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }
                  return RecentActivityTile(item: items[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
