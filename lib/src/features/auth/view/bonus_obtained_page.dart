import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import 'package:zartek_core/src/util/navigation_service.dart';

import 'package:zartek_core/src/features/auth/controller/login_controller.dart';

import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';

class BonusObtainedPage extends StatelessWidget {
  const BonusObtainedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: getWidth(context: context) * 0.8,
                height: getHeight(context: context) * 0.45,
                child: AspectRatio(
                  aspectRatio: 320 / 396,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp),
                      image: DecorationImage(
                        image: AssetImage(Assets.bonusContainer),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        /// Claim Button
                        Consumer(
                          builder: (context, ref, child) {
                            final state = ref.watch(loginControllerProvider);
                            final isLoading = state is LoginStateLoading;

                            return GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () {
                                /// call claim reward API
                                ref
                                    .read(loginControllerProvider.notifier)
                                    .claimSignupReward();

                                NavigationService.pushReplacementAll(
                                  page: AppRoutes.microphonePermission,
                                );
                              },
                              child: Container(
                                width: getWidth(context: context) * 0.4,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(10.sp),
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const CupertinoActivityIndicator()
                                      : GradientItems(
                                    child: Text(
                                      "Claim Now",
                                      style: AppTextStyle()
                                          .labelSmall
                                          .copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        verticalSpaceMedium,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
