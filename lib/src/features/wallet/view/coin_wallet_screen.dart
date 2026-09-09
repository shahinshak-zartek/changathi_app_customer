import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/recharge_plan_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/payment_gateway_controller.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/oops_error.dart';
import '../widget/coin_balance_container.dart';
import '../widget/payment_proced_bottom_sheet.dart';
import '../widget/plan_tile.dart';
import '../widget/refer_and_earn_container.dart';

class CoinWalletScreen extends StatelessWidget {
  const CoinWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.black,
      body: SizedBox(
        width: getWidth(context: context),
        height: getHeight(context: context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpaceSmall,
                Consumer(builder: (context,ref,child) {
                  var res = ref.watch(walletControllerProvider);
                  return res.when(
                    loading: () => SizedBox(),
                    // loading: () => CupertinoActivityIndicator(),
                    success: (wallet) {
                      return CoinBalanceContainer(balance: (wallet?.data?.wallet_balance??0).toString());
                      }, error: (error) {
                      return OopsError(error: error);
                      },);
                  },
                ),
                verticalSpaceSX,
                ReferAndEarnContainer(),
                verticalSpaceMedium,
                SizedBox(
                  width: getWidth(context: context)*0.85,
                    child: Text("Recharge Coin Plans",style: AppTextStyle().titleMedium,)),
                verticalSpaceSmall,
                SizedBox(
                  width: getWidth(context: context)*0.85,
                  child: Consumer(builder: (context,ref,child) {
                    // Pre-fetch enabled gateways so they're ready when a plan is tapped.
                    ref.watch(activeGatewaysProvider);
                    var res = ref.watch(rechargePlanControllerProvider);
                    return res.when(
                      loading: () => Center(child: CupertinoActivityIndicator(),),
                        success: (rechargePlan) {
                          final plans = rechargePlan?.data?.plans ?? [];

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
                              return PlanTile(
                                plan: plan,
                                onTap: () {
                                  proceedToPayment(context, ref, amount: plan.price_in_rupees ?? 0, planId: plan.id ?? "");
                                },
                              );
                            },
                          );
                        }, error: (error) {
                      return OopsError(error: error);
                    },
                    );
                  }
                  ),
                ),
                verticalSpaceLarge,
              ]),
        ),
      ),
    );
  }
}
