import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Messaging is out of scope for Changathi — see the commented nav pill below.
// These imports served only the pill and its chat guard; uncomment them together
// with it.
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:zartek_core/src/app/app_routes.dart';
// import 'package:zartek_core/src/core/localization/app_strings.dart';
// import 'package:zartek_core/src/features/home/controller/home_data_controller.dart';
// import 'package:zartek_core/src/util/alert.dart';
// import 'package:zartek_core/src/util/navigation_service.dart';
// import 'package:zartek_core/src/features/chat/controller/chat_access_controller.dart';
// import 'package:zartek_core/src/features/chat/controller/user_controller.dart';
// import '../../../app/app_text_style.dart';
// import '../../../constants/assets.dart';
// import '../../../util/ui_helper.dart';
// import '../../../widgets/gradient_iems.dart';
// import '../../chat/view/chat_list_screen.dart';
import '../../../app/route_observer.dart';
import '../../../widgets/update_gate.dart';
import '../../profile/view/profile_page.dart';
import 'home_page.dart';

final indexProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

final profileTabNavigationProvider = StateProvider<int>((ref) {
  return 0;
});

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar>
    with WidgetsBindingObserver, RouteAware {
  PageController? _pageController;
  // Only the chat-restriction guard used this.
  // int _lastAllowedIndex = 0;
  @override
  void initState() {
    _pageController = PageController(initialPage: 0);

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Returning from a pushed route is a chance to catch a maintenance toggle
    // flipped while the customer was inside a call, the wallet, a chat… The tab
    // screens below live in a PageView and are built only once, so without this
    // and onPageChanged the gate would only ever run at launch.
    UpdateGate.checkForUpdate(context);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _pageController?.dispose();
    WidgetsBinding.instance.removeObserver(this); // Reset when page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final selectIndex = ref.watch(indexProvider);
    // final isChatFeatureEnabled = ref.watch(isChatFeatureEnabledProvider);
    // final canChat = ref.watch(canChatProvider);
    // final totalUnreadChatCount = ref.watch(totalUnreadChatCountProvider);
    // final strings = ref.watch(appStringsProvider);
    // final showUnreadBadge =
    //     isChatFeatureEnabled && canChat && totalUnreadChatCount > 0;

    // The home app-bar avatar tap drives this — with the pill commented out it
    // is the only deliberate route to Profile, so the page index must match the
    // PageView children below (Profile is 1 while chat is out of scope, 2 if
    // ChatListScreen is restored).
    ref.listen<int>(profileTabNavigationProvider, (previous, next) {
      if (previous != next) {
        _pageController?.animateToPage(
          1,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeInOut,
        );
        ref.read(indexProvider.notifier).state = 1;
      }
    });
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),

          controller: _pageController,
          onPageChanged: (index) {
            // The chat-restriction guard lived here and bounced any swipe to
            // index 1. Index 1 is now Profile, so leaving it would have made
            // Profile unreachable. Restore it with ChatListScreen, not before.
            // if (index == 1 && !isChatFeatureEnabled) {
            //   Alert.showToast("admin restricted your chat action");
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     _pageController?.jumpToPage(_lastAllowedIndex);
            //     ref.read(indexProvider.notifier).state = _lastAllowedIndex;
            //   });
            //   return;
            // }
            // _lastAllowedIndex = index;
            ref.read(indexProvider.notifier).update((state) => state = index);
            // The tab screens are PageView children, built once, so their own
            // initState cannot catch a mid-session maintenance toggle — this
            // does. Placed after the chat-restriction guard so a bounced-back
            // switch is not treated as a tab entry. Coalesced in UpdateGateState,
            // so fast swiping does not stack Remote Config fetches.
            UpdateGate.checkForUpdate(context);
          },
          // Messaging is out of scope for Changathi, so ChatListScreen is not a
          // page here. Profile is therefore index 1, not 2 — if chat comes back,
          // restore ChatListScreen in the middle AND bump the Profile index in
          // the profileTabNavigationProvider listener above back to 2.
          // children: [HomePage(), ChatListScreen(), ProfilePage()],
          children: [HomePage(), ProfilePage()],
        ),
      ),
      bottomNavigationBar: null,
      // ── Nav pill: commented out ──────────────────────────────────────────
      // Changathi has no messaging feature, and with only Home and Profile in
      // scope a three-destination control has nothing left to switch between.
      // Profile is reached by tapping the avatar in the home app bar (which
      // drives profileTabNavigationProvider above) or by swiping.
      //
      // To restore: uncomment this block, the imports at the top of the file,
      // the watches in build(), the chat guard in onPageChanged, the
      // _messageIconWithBadge helper and the _UnreadBadge class below — then put
      // ChatListScreen back as PageView child 1 and change the Profile index in
      // the profileTabNavigationProvider listener from 1 back to 2.
//       floatingActionButton: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 5.sp),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
// 
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(30.sp),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.4),
//                 spreadRadius: 2, // How wide the shadow spreads
//                 blurRadius: 30, // How soft the shadow looks
//                 offset: Offset(0, 2), // Horizontal & vertical shadow position
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               IconButton(
//                 hoverColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
//                 icon: GradientItems(
//                   gradient: selectIndex != 0,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.home_outlined,
//                         color: Colors.white,
//                         size: 25.sp,
//                       ),
//                       verticalSpaceTinyS,
//                       Text(
//                         strings.t(AppStringKey.navHome),
//                         style: AppTextStyle().bodyMedium.copyWith(
//                           color: Colors.white,
//                           fontWeight: selectIndex == 0 ? FontWeight.bold : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 onPressed: () {
//                   ref
//                       .read(resetHomeAgentFilterProvider.notifier)
//                       .update((state) => state + 1);
//                   _pageController?.animateToPage(
//                     0,
//                     duration: const Duration(milliseconds: 10),
//                     curve: Curves.easeInOut,
//                   );
//                   ref.read(indexProvider.notifier).update((state) => state = 0);
//                 },
//               ),
//               IconButton(
//                 hoverColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
//                 onPressed: () {
//                   if (!isChatFeatureEnabled) {
//                     Alert.showToast("admin restricted your chat action");
//                     return;
//                   }
//                   final canChat = ref.read(canChatProvider);
//                   final rawReason = ref.read(chatReasonProvider);
//                   final reason = rawReason ?? "don't have access";
//                   // Only offer Purchase when buying a plan is actually the fix —
//                   // an admin block is not lifted by spending money.
//                   final showPurchase = chatReasonNeedsPurchase(rawReason);
// 
//                   if (!canChat) {
//                     Alert.showToast(
//                       strings.tf(AppStringKey.cannotProceedBecause, {
//                         'reason': reason,
//                       }),
//                       isLong: true,
//                       actionLabel: showPurchase ? 'Purchase' : null,
//                       actionIcon: showPurchase ? Assets.coin : null,
//                       onActionPressed: showPurchase
//                           ? () {
//                               NavigationService.push(
//                                 page: AppRoutes.wallet,
//                                 arguments: 1, // chat-plan tab
//                               );
//                             }
//                           : null,
//                     );
//                     return;
//                   }
// 
//                   _pageController?.animateToPage(
//                     1,
//                     duration: const Duration(milliseconds: 10),
//                     curve: Curves.easeInOut,
//                   );
//                   ref.read(indexProvider.notifier).update((state) => state = 1);
//                 },
//                 icon: GradientItems(
//                   gradient: selectIndex != 1 || !isChatFeatureEnabled,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _messageIconWithBadge(
//                         iconColor: isChatFeatureEnabled
//                             ? Colors.white
//                             : Colors.red.shade200,
//                         showBadge: showUnreadBadge,
//                         unreadCount: totalUnreadChatCount,
//                       ),
//                       verticalSpaceTinyS,
//                       Text(
//                         strings.t(AppStringKey.navMessages),
//                         style: AppTextStyle().bodyMedium.copyWith(
//                           color: isChatFeatureEnabled
//                               ? Colors.white
//                               : Colors.red.shade300,
//                           fontWeight: selectIndex == 1 ? FontWeight.bold : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               IconButton(
//                 hoverColor: Colors.transparent,
//                 highlightColor: Colors.transparent,
// 
//                 onPressed: () {
//                   _pageController?.animateToPage(
//                     2,
//                     duration: const Duration(milliseconds: 10),
//                     curve: Curves.easeInOut,
//                   );
//                   ref.read(indexProvider.notifier).update((state) => state = 2);
//                 },
//                 icon: GradientItems(
//                   gradient: selectIndex != 2,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.person_outline,
//                         color: Colors.white,
//                         size: 25.sp,
//                       ),
//                       verticalSpaceTinyS,
//                       Text(
//                         strings.t(AppStringKey.navProfile),
//                         style: AppTextStyle().bodyMedium.copyWith(
//                           color: Colors.white,
//                           fontWeight: selectIndex == 2 ? FontWeight.bold : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

//   Widget _messageIconWithBadge({
//     required Color iconColor,
//     required bool showBadge,
//     required int unreadCount,
//   }) {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Icon(
//           Icons.messenger_outline_rounded,
//           color: iconColor,
//           size: 25.sp,
//         ),
//         if (showBadge)
//           Positioned(
//             top: -20.sp,
//             child: _UnreadBadge(count: unreadCount),
//           ),
//       ],
//     );
//   }
}

// class _UnreadBadge extends StatelessWidget {
//   const _UnreadBadge({required this.count});
// 
//   final int count;
// 
//   @override
//   Widget build(BuildContext context) {
//     final label = count > 99 ? '99+' : count.toString();
//     return Container(
//       constraints: BoxConstraints(
//         minWidth: 18.sp,
//         minHeight: 18.sp,
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 4.sp),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: Colors.red,
//         border: Border.all(color: Colors.white, width: 1.sp),
//         borderRadius: BorderRadius.circular(10.sp),
//       ),
//       child: Text(
//         label,
//         style: AppTextStyle().bodySmall.copyWith(
//           color: Colors.white,
//           fontSize: 9.sp,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 0,
//         ),
//       ),
//     );
//   }
// }
