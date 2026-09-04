import 'package:flutter/material.dart';


import '../../../app/app_text_style.dart';
import '../../../app/theme.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';

class SmsPlanTile extends StatelessWidget {
  const SmsPlanTile({
    super.key,
    required this.priceInRupees,
    required this.durationDays,
    required this.description,
    this.onTap,

  });

  final int priceInRupees;
  final int durationDays;
  final String description;
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
              Text("₹ $priceInRupees",style:  AppTextStyle().titleLarge),
              Text(description,style:  AppTextStyle().titleSmall.copyWith(color: AppColors.lightGray)),
              Text("$durationDays days",style: AppTextStyle().bodyMedium,),
              CustomElevatedButton(onPressed: onTap,label: "Buy Now",
                width: getWidth(context: context)*0.25,)

            ],
          ),
        ),
      ),
    );
  }
}
