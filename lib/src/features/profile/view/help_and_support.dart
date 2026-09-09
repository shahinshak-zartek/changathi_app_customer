
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/app_launcher.dart';
import 'package:zartek_core/src/features/profile/controller/help_and_support_controller.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';


class SupportPage extends ConsumerWidget {
  const SupportPage({super.key});

  static const routeName = '/support';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => NavigationService.pop(), icon: GradientItems(child: Icon(CupertinoIcons.back,color: Colors.white,))),
        centerTitle: true,
        title: Text(strings.t(AppStringKey.helpsAndSupportTitle),style: AppTextStyle().bodyLarge,),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              strings.t(AppStringKey.wereHereToHelp),
              style: AppTextStyle().titleLarge,
            ),
           verticalSpaceMedium,
        Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(helpAndSupportControllerProvider);
            return state.when(
              loading: () => const Center(child: CupertinoActivityIndicator(),),
              error: (error) => Center(child: Text(error),),
              success: (helpData) {
                final chat = helpData?.data?.chat;
                final call = helpData?.data?.phone;
                final email = helpData?.data?.email;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Chat
                    if (chat?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.chatWithUs),
                        subtitle: "Instant response usually",
                        icon: Assets.smsHelp,
                        onPressed: () {
                          AppLauncher.openUrl(chat?.action_url ?? "");
                        },
                      ),

                    verticalSpaceSmall,

                    /// Call
                    if (call?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.callUs),
                        subtitle: "Available 24/7 for urgent issues",
                        icon: Assets.phoneHelp,
                        onPressed: () {
                          AppLauncher.makePhoneCall(call?.value ?? "");
                        },
                      ),

                    verticalSpaceSmall,

                    /// Email
                    if (email?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.mailUs),
                        subtitle: "Expect a reply within 24 hours",
                        icon: Assets.email,
                        onPressed: () {
                          AppLauncher.openMail(email?.value ?? "");
                        },
                      ),
                  ],
                );
              },
            );
          },
        )
          ],
        ),
      ),
    );
  }
}

class SupportButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final String subtitle;
  final String? icon;

  const SupportButton({
    super.key,
    required this.text,
    required this.subtitle,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 20.h,
        ),
        decoration: BoxDecoration(
          color: Palette.secondaryBlack,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            /// Icon Circle
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: const Color(0xFF351A52),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon!,
                  width: 15.w,
                  height: 15.h,
                ),
              ),
            ),

            SizedBox(width: 20.w),

            /// Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyle().titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  Text(
                    subtitle,
                    style: AppTextStyle().bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            /// Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.white70,
              size: 25.sp,
            ),
          ],
        ),
      ),
    );
  }
}