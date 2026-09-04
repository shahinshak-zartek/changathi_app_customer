import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';

class CoinBalanceContainer extends StatelessWidget {
  final String balance;
  const CoinBalanceContainer({super.key,required this.balance});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getWidth(context: context)*0.85,
      child: AspectRatio(
        aspectRatio: 666/327,
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 40.sp),
          height: 153,
          decoration:  BoxDecoration(
              image: DecorationImage(image: AssetImage(Assets.balanceBanner),fit: BoxFit.fitWidth)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 verticalSpaceMedium,
                   Text("Current Balance", style: AppTextStyle().bodyLarge.copyWith(color: Colors.white), textAlign: TextAlign.center),
                  verticalSpaceTinyS,
                  Text(balance,
                      style: AppTextStyle().displayMedium.copyWith(color: Colors.white), textAlign: TextAlign.center),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
