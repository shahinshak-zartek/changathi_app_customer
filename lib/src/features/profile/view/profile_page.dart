import 'package:Changathi/src/features/profile/view/webview_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/features/profile/controller/profile_data_controller.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';
import 'package:zartek_core/src/features/profile/controller/legal_pages_controller.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../widget/drawer_item.dart';
import 'package:zartek_core/src/features/notification/controller/notification_controller.dart';

import '../widget/logout_dialogue.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/live_avatar.dart';
import '../../../widgets/update_gate.dart';
import '../widget/profile_delete_dialougue.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(profileDataControllerProvider);
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      backgroundColor: Palette.black,
      // Profile is a pushed route (AppRouter.profile) rather than a nav tab, so
      // it needs its own way back — matching wallet, recent activity and
      // support, which all carry this bar.
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: GradientItems(
            child: Icon(CupertinoIcons.back, color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: Text(
          strings.t(AppStringKey.profileTitle),
          style: AppTextStyle().bodyLarge,
        ),
      ),
      body: LayoutBuilder(
builder: (context, constraints) {
  return SingleChildScrollView(
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: IntrinsicHeight(
        child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Palette.deepRoyalPinkBegin,
                          Palette.deepRoyalVioletMid,
                          Palette.deepSkyBlueEnd,
                        ],
                      )
                  ),
                  child: LiveAvatar(
                    url: currentUser.data?.avatar_data?.image_url,
                    radius: 35.w,
                  ),
                ),
                verticalSpaceSmall,
                Text(
                  currentUser.data?.name??"",
                  style: AppTextStyle().titleMedium,
                ),
                verticalSpaceSmall,
                Text(
                  currentUser.data?.phone??"",
                  style: AppTextStyle().bodyMedium
                      .copyWith(fontWeight: FontWeight.w400),
                ),
                verticalSpaceMedium,
                Container(
                  decoration: BoxDecoration(
                    color: Palette.secondaryBlack,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                           await NavigationService.push(page: AppRoutes.profileEdit,arguments: currentUser.data);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.profileTitle), width: 12,image: Assets.profile),
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService.push(page: AppRoutes.wallet);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.walletTitle), width: 6,image: Assets.wallet),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final notifState = ref.watch(notificationControllerProvider);
                          int unreadCount = 0;
                          notifState.maybeWhen(
                            success: (notification, _) {
                              unreadCount = notification?.data?.unread_count ?? 0;
                            },
                            orElse: () {},
                          );
                          return InkWell(
                            onTap: () {
                              // ref.read(notificationControllerProvider.notifier).markAllReadOnOpen();
                              NavigationService.push(page: AppRoutes.notification);
                            },
                            child: DrawerItem(
                              title: strings.t(AppStringKey.notifications),
                              width: 6,
                              image: Assets.notificationGrey,
                              trailing: unreadCount > 0
                                  ? Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                          );
                        },
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService.push(page: AppRoutes.recentActivity);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.callHistory), width: 6,image: Assets.historyCall),
                      ),
                      InkWell(
                        onTap: () {
                          final langs = currentUser.data?.languages;
                          final currentLang = (langs != null && langs.isNotEmpty) ? langs.first : null;
                          NavigationService.push(
                            page: AppRoutes.languageEdit,
                            arguments: currentLang,
                          );
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.languages), width: 6,image: Assets.language),
                      ),
                    ],
                  ),
                ),
                verticalSpaceSX,
                Container(
                  decoration: BoxDecoration(
                    color: Palette.secondaryBlack,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          NavigationService.push(page: AppRoutes.help);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.helpAndSupport), width: 6,image: Assets.help),
                      ),
                      InkWell(
                        onTap: () async {
                          final controller =
                          ref.read(legalPagesControllerProvider.notifier);
                          final res = await controller.getLegalPagesData("customer-terms-and-conditions");
                          if (res?.data != null) {
                            NavigationService.push(
                              page: AppRoutes.webView,
                              arguments: WebViewModel(
                                title: res?.data?.title ?? "Terms & Conditions",
                                url: res?.data?.content ?? "",
                              ),
                            );
                          }
                        },
                        child: DrawerItem(title: strings.t(AppStringKey.termsAndConditions), width: 6, image: Assets.term,),
                      ),
                      InkWell(
                        onTap: () async {
                          final controller =
                          ref.read(legalPagesControllerProvider.notifier);
                          final res = await controller.getLegalPagesData("refund-cancellation-policy");
                          if (res?.data != null) {
                            NavigationService.push(
                              page: AppRoutes.webView,
                              arguments: WebViewModel(
                                title: res?.data?.title ?? "Refund and cancellation Policy",
                                url: res?.data?.content ?? "",
                              ),
                            );
                          }
                        },
                        child: DrawerItem(title: strings.t(AppStringKey.refundPolicy), width: 6, image: Assets.refund,),
                      ),
                      InkWell(
                        onTap: () async {
                          final controller =
                          ref.read(legalPagesControllerProvider.notifier);
                          final res = await controller.getLegalPagesData("customer-privacy-policy");
                          if (res?.data != null) {
                            NavigationService.push(
                              page: AppRoutes.webView,
                              arguments: WebViewModel(
                                title: res?.data?.title ?? "Privacy Policy",
                                url: res?.data?.content ?? "",
                              ),
                            );
                          }
                        },
                        child: DrawerItem(title: strings.t(AppStringKey.privacyPolicy), width: 6, image: Assets.privacy,),
                      ),
                    ],
                  ),
                ),
                verticalSpaceSX,


                Container(
                  decoration: BoxDecoration(
                    color: Palette.secondaryBlack,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          showDeleteAccountDialog(context);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.deleteAccount), width: 6,image: Assets.delete,iconEnable: false,),
                      ),
                      InkWell(
                        onTap: () {
                          showLogoutAccountDialog(context);
                        },
                        child:  DrawerItem(title: strings.t(AppStringKey.logout), width: 6,image: Assets.logout,iconEnable: false,),
                      ),
                    ],
                  ),
                ),
                // verticalSpaceLarge,
                // verticalSpaceLarge,
                verticalSpaceLarge,
                      // const Spacer(),
                      FutureBuilder<PackageInfo>(
                        future: _packageInfoFuture,
                        builder: (context, snapshot) {
                          final packageInfo = snapshot.data;
                          if (packageInfo == null) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 20.sp),
                            child: Text(
                              'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                              textAlign: TextAlign.center,
                              style: AppTextStyle().bodySmall.copyWith(
                                color: Palette.lightGrey,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
