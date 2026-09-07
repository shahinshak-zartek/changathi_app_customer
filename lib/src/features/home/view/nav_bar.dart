import 'package:flutter/material.dart';
// StateProvider lives here — needed again if the two providers below come back.
// import 'package:flutter_riverpod/legacy.dart';
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
import 'home_page.dart';

// Both providers existed only to drive the PageView's tab index. Profile is a
// pushed route now (AppRouter.profile, from the home app-bar avatar), so nothing
// reads either one. Restore them with the pill below.
// final indexProvider = StateProvider.autoDispose<int>((ref) {
//   return 0;
// });
//
// final profileTabNavigationProvider = StateProvider<int>((ref) {
//   return 0;
// });

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar>
    with WidgetsBindingObserver, RouteAware {
  // The PageView is gone — Home is the only page, and Profile is pushed as a
  // route. Keeping a controller here would only re-enable the swipe.
  // PageController? _pageController;
  // Only the chat-restriction guard used this.
  // int _lastAllowedIndex = 0;
  @override
  void initState() {
    // _pageController = PageController(initialPage: 0);

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
    // flipped while the customer was inside a call, the wallet, Profile… Home is
    // built once and kept alive underneath, so without this the gate would only
    // ever run at launch.
    UpdateGate.checkForUpdate(context);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    // _pageController?.dispose();
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

    // The avatar-tap listener that animated the PageView to the Profile page is
    // gone. HomePage now pushes AppRouter.profile instead, so Profile sits on
    // the navigator and the back gesture pops it instead of exiting the app.
    // ref.listen<int>(profileTabNavigationProvider, (previous, next) {
    //   if (previous != next) {
    //     _pageController?.animateToPage(
    //       1,
    //       duration: const Duration(milliseconds: 10),
    //       curve: Curves.easeInOut,
    //     );
    //     ref.read(indexProvider.notifier).state = 1;
    //   }
    // });
    return Scaffold(
      // Home is the only page. It was a PageView of [HomePage, ChatListScreen,
      // ProfilePage]; chat is out of scope and Profile is a pushed route, so a
      // PageView would only have re-added the horizontal swipe.
      //
      // To restore the tabbed layout: bring back the PageView with its
      // controller, the onPageChanged handler (whose UpdateGate.checkForUpdate
      // caught mid-session maintenance toggles that PageView children, built
      // once, cannot), the two providers at the top of this file, and the pill
      // below — then point the avatar tap back at profileTabNavigationProvider.
      body: SafeArea(child: HomePage()),
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
