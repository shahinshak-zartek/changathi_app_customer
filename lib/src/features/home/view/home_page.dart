import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import 'package:zartek_core/src/features/chat/controller/chat_access_controller.dart';
import 'package:zartek_core/src/features/home/controller/banner_list_controller.dart';
import 'package:zartek_core/src/features/home/controller/home_data_controller.dart';
import 'package:zartek_core/src/features/profile/controller/profile_data_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/route_observer.dart';
import '../../../app/theme.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../app/app_router.dart';
import '../../../widgets/live_avatar.dart';
import '../../../widgets/oops_error.dart';
import '../../../widgets/update_gate.dart';
import '../widget/scroll_banner_widget.dart';
import 'agent_list_screen.dart';
// nav_bar.dart is no longer imported: its indexProvider and
// profileTabNavigationProvider went away with the PageView.
final homeIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final resetHomeAgentFilterProvider = StateProvider<int>((ref) {
  return 0;
});

class HomeNotificationButton extends StatelessWidget {
  const HomeNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Palette.containerBorder,
            width: 0.8,
          ),
        ),
        child: Center(
          child: IconButton(
            iconSize: 18.w,
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRouter.notification),
          ),
        ),
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  TabController? tabs;
  @override
  void initState() {
    // Audio/Video filter tabs are hidden for now — length must equal the
    // number of TabBarView children below (restore to 3 when re-enabling).
    tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runHomeInit();
    });
    // Always reset to first tab when entering screen
    Future.microtask(() {
      ref.read(homeIndexProvider.notifier).state = 0;
      tabs?.index = 0;
    });
    tabs?.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref
            .read(homeIndexProvider.notifier)
            .update((state) => state = tabs?.index ?? 0);
      });
    });
    super.initState();
  }

  void _runHomeInit() {
    if (!mounted) return;
    // Runs on first open, pop-back, resume and home-tab switch — so one call
    // here covers every way the customer arrives at home.
    UpdateGate.checkForUpdate(context);
    _resetAgentFilterToAll();
    // Refresh all home-related data on every entrance (first open, pop-back,
    // resume from background, switch to home tab).
    ref.invalidate(homeDataProvider);
    ref.read(walletControllerProvider.notifier).getWalletData();
    ref.read(bannerListControllerProvider.notifier).getBanner();
    _bootstrapChatOnHomeInit();
  }

  void _resetAgentFilterToAll() {
    ref.read(homeIndexProvider.notifier).state = 0;
    final tabController = tabs;
    if (tabController != null && tabController.index != 0) {
      tabController.animateTo(0);
    }
  }

  Future<void> _bootstrapChatOnHomeInit() async {
    try {
      ref.invalidate(chatAccessControllerProvider);
      await ref.read(chatAccessControllerProvider.future);
    } catch (_) {}
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
    _runHomeInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isOnHomeTab()) {
      _runHomeInit();
    }
  }

  /// Whether Home is the screen the customer is actually looking at.
  ///
  /// Guards the resume refresh so returning to the app while Profile (or any
  /// pushed screen) is on top does not rebuild Home underneath. This used to ask
  /// the PageView's tab index; Profile is a pushed route now, so the navigator
  /// is the thing to ask.
  bool _isOnHomeTab() => ModalRoute.of(context)?.isCurrent ?? true;

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    tabs?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectIndex = ref.watch(homeIndexProvider);
    ref.listen<int>(resetHomeAgentFilterProvider, (previous, next) {
      if (previous != next) {
        _resetAgentFilterToAll();
      }
    });
    final homeData = ref
        .watch(homeDataProvider)
        .maybeWhen(data: (homeData) => homeData?.data, orElse: () => null);
    // The tab-index listener that used to re-init Home on tab switch is gone
    // with the PageView — didPopNext() below covers returning from Profile.
    // Watch the controller, not the storage service. `preferenceStorageProvider`
    // holds a single instance installed by bootstrap and never replaced, so
    // watching it never fires a rebuild — the avatar here only refreshed when
    // something else happened to rebuild this widget.
    final currentUser = ref.watch(profileDataControllerProvider);
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      backgroundColor: Palette.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: kToolbarHeight + 15.h,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              var res = ref.watch(walletControllerProvider);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(width: 1, color: Palette.containerBorder,),
                ),
                child: res.when(
                  loading: () => SizedBox(
                    height: 30.h,
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                  success: (wallet) => _walletContent(wallet),
                  error: (error) => Icon(Icons.warning_outlined, color: Colors.grey.shade800),
                ),
              );
            },
          ),
          HomeNotificationButton(),
          horizontalSpaceSmall,
        ],
        title: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Pushed as a real route (like the wallet below) rather than
              // switched to as a tab — a page switch puts nothing on the
              // navigator, so back from Profile used to exit the app.
              onTap: () => NavigationService.push(page: AppRouter.profile),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Palette.deepRoyalPinkBegin,
                      Palette.deepRoyalVioletMid,
                      Palette.deepSkyBlueEnd    ,
                    ],
                  ),
                ),
                child: LiveAvatar(
                  url: currentUser.data?.avatar_data?.image_url,
                  radius: 22.w,
                ),
              ),
            ),

            horizontalSpaceTiny,
            Flexible(
              child: Text(
                strings.tf(AppStringKey.hiName, {
                  'name': currentUser.data?.name ?? '',
                }),
                style: AppTextStyle().titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 120.h,
              child: Consumer(
                builder: (context, ref, child) {
                  var res = ref.watch(bannerListControllerProvider);
                  return res.when(
                    loading: () => const Center(
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                    error: (error) => OopsError(error: error),
                    success: (bannerList) {
                      final items = bannerList?.data?.items ?? [];
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            strings.t(AppStringKey.noBannersAvailable),
                          ),
                        );
                      }
                      return AutoScrollBanner(items: items);
                    },
                  );
                },
              ),
            ),
            verticalSpaceSmall,
            SizedBox(
              height: 50.h,
              child: TabBar(
                controller: tabs,
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                dividerColor: Colors.transparent,
                indicator: const BoxDecoration(),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  _buildTab(
                    strings.t(AppStringKey.tabAll),
                    selectIndex == 0,
                  ),
                  _buildTab(
                    strings.t(AppStringKey.tabAudio),
                    selectIndex == 1,
                  ),
                  _buildTab(
                    strings.t(AppStringKey.tabVideo),
                    selectIndex == 2,
                  ),
                ],
              ),
            ),
            verticalSpaceSmall,
            if (homeData?.defaultAudioCoinsPerSecond != null &&
                homeData?.defaultVideoCoinsPerSecond != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyle().bodyMediumRate.copyWith(
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text:
                        'Audio call rate: ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Image.asset(
                          Assets.dollar,
                          height: 15.h,
                        ),
                      ),
                      TextSpan(
                        text:
                        '${homeData!.defaultAudioCoinsPerSecond}/sec',
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text:
                        'Video call rate: ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Image.asset(
                          Assets.dollar,
                          height: 15.h,
                        ),
                      ),
                      TextSpan(
                        text:
                        '${homeData.defaultVideoCoinsPerSecond}/sec ',
                      ),
                    ],
                  ),
                ),
              ),
            verticalSpaceSmall,
            Expanded(
              child: TabBarView(
                controller: tabs,
                children: const [
                  AgentListScreen(filterType: AgentFilterType.all),
                  AgentListScreen(filterType: AgentFilterType.audio),
                  AgentListScreen(filterType: AgentFilterType.video),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    return Tab(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 10.h,
        ),
        decoration: BoxDecoration(
          color: Palette.secondaryBlack,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              Container(
                width: 6.w,
                height: 6.w,
                decoration: const BoxDecoration(
                  color: Palette.deepRoyalPinkBegin,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle().bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletContent(wallet) {
    // final strings = ref.read(appStringsProvider);
    return GestureDetector(
      onTap: () => NavigationService.push(page: AppRoutes.wallet),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.dollar, height: 25.h,),
              // SvgPicture.asset(Assets.coin, width: 22.w, height: 22.h),
              horizontalSpaceTiny,
              Text(
                (wallet?.data?.wallet_balance ?? "-").toString(),
                style: AppTextStyle().bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
