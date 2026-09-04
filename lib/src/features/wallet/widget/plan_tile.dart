import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';


import '../../../app/app_text_style.dart';
import '../../../app/theme.dart';
import '../../../constants/assets.dart';
import 'package:zartek_core/src/features/wallet/model/recharge_plan_model.dart';

import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';

class PlanTile extends StatelessWidget {
  const PlanTile({
    super.key,
    required this.plan,
    this.onTap,

  });

  final PlanData plan;
  final VoidCallback? onTap;


  @override
  Widget build(BuildContext context) {
    return SizedBox(

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),

          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text("Price",style: AppTextStyle().bodySmall),
              Text("₹ ${plan.price_in_rupees}",style:  AppTextStyle().titleLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(Assets.coin,width: 22.w,height: 22.h,),
                  Text(" ${plan.amount} Coins",style: AppTextStyle().bodyMedium,)
                ],
              ),
              Text("${plan.description}",style: AppTextStyle().bodySmall),
              CustomElevatedButton(onPressed: onTap,label: "Buy Now",
              width: getWidth(context: context)*0.25,)

            ],
          ),
        ),
      ),
    );
  }
}
