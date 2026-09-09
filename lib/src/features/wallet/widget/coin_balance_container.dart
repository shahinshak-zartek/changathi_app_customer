import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../util/ui_helper.dart';

class CoinBalanceContainer extends StatelessWidget {
  final String balance;
  const CoinBalanceContainer({super.key,required this.balance});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(context: context)*0.85,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          height: 120.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Palette.deepRoyalPinkBegin,
                Palette.deepRoyalVioletMid,
                Palette.deepSkyBlueEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpaceMedium,
                  Text(
                    "Current Balance",
                    style: AppTextStyle().bodyLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  verticalSpaceTinyS,
                  Text(
                    balance,
                    style: AppTextStyle().displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
