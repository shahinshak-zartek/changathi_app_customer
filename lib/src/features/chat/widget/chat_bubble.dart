import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../util/ui_helper.dart';
import 'message_parser.dart';

class ChatBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final int timestamp;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isMe ? Colors.white : Colors.black;

    return GestureDetector(
      onLongPress: isMe ? null : onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
            padding: EdgeInsets.fromLTRB(14.sp, 10.sp, 14.sp, 10.sp),
            decoration: BoxDecoration(
              color: isMe ? null : Colors.white,
              borderRadius: BorderRadius.circular(15.sp),
              gradient: isMe
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Palette.deepRoyalVioletBegin,
                        Palette.deepRoyalVioletMid,
                        Palette.deepRoyalVioletEnd,
                      ],
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                VibetalkMessageParser.parse(
                  content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16.sp,
                  ),
                ),

                verticalSpaceSmall,

                /// Time
                Text(
                  DateFormat("hh:mm a").format(
                    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
                  ),
                  style: AppTextStyle()
                      .bodySmall
                      .copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ],
      )
    );
  }
}
