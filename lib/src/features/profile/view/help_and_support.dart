
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
                    /// WhatsApp
                    if (chat?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.chatWithUs),
                        icon: Assets.whatsapp,
                        onPressed: () {
                          AppLauncher.openUrl(chat?.action_url ?? "");
                        },
                      ),
                    verticalSpaceSmall,
                    /// Call
                    if (call?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.callUs),
                        icon: Assets.phone,
                        onPressed: () {
                          AppLauncher.makePhoneCall(call?.value ?? "");
                        },
                      ),
                    verticalSpaceSmall,
                    /// Email
                    if (email?.enabled == true)
                      SupportButton(
                        text: strings.t(AppStringKey.mailUs),
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
  final String? icon;
  final double? iconHeight;
  const SupportButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.iconHeight = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  onPressed ,
      child: Center(
          child:  Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(

              children: [
                Container(
                  padding: EdgeInsets.all(14.sp),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10.sp)
                  ),
                  child: SvgPicture.asset(icon!,height:25.h,width: 25.w,
                  ),
                ),
                verticalSpaceTiny,
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyle().bodySmall,
                ),
              ],
            ),
          )

      ),
    );
  }
}