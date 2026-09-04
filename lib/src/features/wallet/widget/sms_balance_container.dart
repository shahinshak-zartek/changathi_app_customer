import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import 'package:zartek_core/src/features/wallet/controller/subscription_controller.dart';

import '../../../util/ui_helper.dart';

class SmsBalanceContainer extends ConsumerWidget {
  const SmsBalanceContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionControllerProvider);

    return Container(
      width: getWidth(context: context) * 0.85,
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: subState.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error) => Center(child: Text("Error: $error")),
        success: (chatSubModel) {
          final subscription = chatSubModel?.data;

          if (subscription == null || subscription.expires_at == null || subscription.starts_at == null || subscription.status != "ACTIVE") {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat Plan Info', style: AppTextStyle().titleSmall),
                verticalSpaceSmall,
                Text('No active plan', style: AppTextStyle().titleMedium),
              ],
            );
          }

          final startDate = subscription.starts_at!;
          final endDate = subscription.expires_at!;
          final now = DateTime.now();

          final totalDuration = endDate.difference(startDate).inMilliseconds;
          final remainingDuration = endDate.difference(now).inMilliseconds;

          final validTotal = totalDuration <= 0 ? 1 : totalDuration;
          final validRemaining = remainingDuration.clamp(0, validTotal);

          double fraction = validRemaining / validTotal;
          fraction = fraction.clamp(0.0, 1.0);

          final expiryDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(endDate.toLocal());

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat Plan Info', style: AppTextStyle().titleSmall),
              verticalSpaceSmall,
              RichText(
                text: TextSpan(
                  children: [
                    // TextSpan(
                    //   text: '$validRemaining Days ',
                    //   style: AppTextStyle().titleMedium,
                    // ),
                    TextSpan(
                      text: 'Your chat plan is active',
                      style: AppTextStyle().bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.sp),
                child: SizedBox(
                  height: 5.h,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.sp),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Palette.deepRoyalVioletBegin,
                                Palette.deepRoyalVioletMid,
                                Palette.deepRoyalVioletEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpaceSmall,
              Text(
                'Expiry Date: $expiryDateStr',
                style: AppTextStyle().bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
