import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_text_style.dart';
import '../../../util/ui_helper.dart';

class NotificationTile extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final String time;
  const NotificationTile({super.key,required this.message,required this.icon,required this.title,required this.time});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: getWidth(context: context)*0.85,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: SizedBox(
              width:45.w,
              height: 45.h ,
              child: (icon=="")
                  ? Icon(Icons.notifications_outlined,color: Colors.black,)
                  : CachedNetworkImage(
                imageUrl: icon,
                fit: BoxFit.cover,
              ),
            ),
          ),
          horizontalSpaceMedium,
          SizedBox(
            width: getWidth(context: context)*0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: AppTextStyle().titleMedium,),
                verticalSpaceTiny,
                Text(message,style: AppTextStyle().bodyMedium,),
                verticalSpaceTiny,
                Text(time,style: AppTextStyle().bodySmall,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
