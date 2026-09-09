import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/app_text_style.dart';
import '../../../app/theme.dart';
import '../../../util/ui_helper.dart';


class DrawerItem extends StatelessWidget {
  const DrawerItem({
    required this.image,
    Key? key,
    this.title = '',
    this.width = 12,
    this.iconEnable=true,
    this.trailing,
  }) : super(key: key);
  final String title;
  final double width;
  final String image;
  final bool iconEnable;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),

      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14,horizontal: 8),
      child: Row(
        children: [
          horizontalSpaceSmall,
          SizedBox(
            width: 20.w,
            child: SvgPicture.asset(image,width: 20.w,
            height: 20.h,),
          ),
          horizontalSpaceSmall,
          SizedBox(
              child: Text(title,style: AppTextStyle().bodyMedium,)),
          const Spacer(),
          if (trailing != null) trailing!,
          if(iconEnable)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Icon(Icons.arrow_forward_ios,color: AppColors.lightGray,size: 14.sp,),
            )
        ],
      ),
    );
  }
}
