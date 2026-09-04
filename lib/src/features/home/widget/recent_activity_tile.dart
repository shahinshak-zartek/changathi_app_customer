
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import 'package:zartek_core/src/features/home/model/call_history_model.dart';

class RecentActivityTile extends StatelessWidget {

  final CallHistoryItem item;

  const RecentActivityTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 12.sp),
      margin: EdgeInsets.symmetric(vertical: 6.sp),
      child: Row(
          children: [
            Column(
              children: [
                Icon(
                  item.callMode == "audio" ? CupertinoIcons.phone :  Icons.videocam_outlined,
                  color: Colors.black,
                  size: 15.w,
                ),
                SvgPicture.asset(
                  item.callOutcome == "cancelled" ? Assets.endCall : Assets.incoming, width: 20.w, height: 20.h,
                ),
              ],
            ),
            // SvgPicture.asset(Assets.incoming, width: 25.w, height: 25.h,),
            horizontalSpaceSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.peerName ?? "",
                    style: AppTextStyle().titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalSpaceTiny,
                  Text(
                    item.startedAt != null
                        ? DateFormat('dd/MM/yyyy \'at\' hh:mm a').format(item.startedAt!.toLocal())
                        : "",
                    style: AppTextStyle().bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            item.callOutcome == "cancelled"
                ? Text("Cancelled",style: AppTextStyle().bodyMedium.copyWith(color: Colors.red),)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      "-${item.coinsSpent ?? 0} Coins",
                      style: AppTextStyle().bodyMedium.copyWith(color: Colors.green),
                    ),
                  ],
                ),
                // Text(DurationFormatter.format(item.durationSeconds ?? 0), style: AppTextStyle().bodyMedium,),
              ],
            )
          ],
        ),
      );
  }
}
