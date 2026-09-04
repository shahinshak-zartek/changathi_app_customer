import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/wallet/controller/chat_plan_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/payment_gateway_controller.dart';
import '../../../app/app_text_style.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/oops_error.dart';
import '../widget/payment_proced_bottom_sheet.dart';
import '../widget/refer_and_earn_container.dart';
import '../widget/sms_balance_container.dart';
import '../widget/sms_plan_tile.dart';

class SmsWalletScreen extends StatelessWidget {
  const SmsWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: getWidth(context: context),
        height: getHeight(context: context),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpaceSmall,
                SmsBalanceContainer(),
                verticalSpaceMedium,
                ReferAndEarnContainer(),
                verticalSpaceMedium,
                SizedBox(
                    width: getWidth(context: context)*0.85,
                    child: Text("Recharge Chat Plans",style: AppTextStyle().titleMedium,)),
                verticalSpaceSmall,
              SizedBox(
                width: getWidth(context: context) * 0.85,
                child: Consumer(
                  builder: (context, ref, child) {
                    // Pre-fetch enabled gateways so they're ready when a plan is tapped.
                    ref.watch(activeGatewaysProvider);
                    final res = ref.watch(chatPlanControllerProvider);
                    return res.when(
                      loading: () => const Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      success: (chatPlan) {
                        final plans = chatPlan?.data?.plans ?? [];

                        if (plans.isEmpty) {
                          return const Center(
                            child: Text("No plans available"),
                          );
                        }
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: plans.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15.sp,
                            mainAxisSpacing: 15.sp,
                            childAspectRatio: 149 / 195,
                          ),
                          itemBuilder: (context, index) {
                            final plan = plans[index];
                            return SmsPlanTile(
                              priceInRupees: plan.price_in_rupees ?? 0,
                              durationDays: plan.duration_days ?? 0,
                              description: plan.description ?? "",
                              onTap: () {
                                proceedToPayment(context, ref, isSms: true, amount: plan.price_in_rupees ?? 0, planId: plan.id ?? "");
                              },
                            );
                          },
                        );
                      },
                      error: (error) => OopsError(error: error),
                    );
                  },
                ),
              ), verticalSpaceLarge,
              ]),
        ),
      ),
    );
  }
}
