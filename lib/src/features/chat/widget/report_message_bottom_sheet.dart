import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';
import 'package:zartek_core/src/features/chat/controller/chat_controller.dart';
import 'package:zartek_core/src/features/chat/data/message_model.dart';

class ReportMessageBottomSheet extends ConsumerStatefulWidget {
  final List<ChatMessage> contextMessages;
  final int reportedMessageId;
  final String reportedUserId;
  final String reportedUserMail;

  const ReportMessageBottomSheet({
    super.key,
    required this.contextMessages,
    required this.reportedMessageId,
    required this.reportedUserId,
    required this.reportedUserMail,
  });

  @override
  ConsumerState<ReportMessageBottomSheet> createState() => _ReportMessageBottomSheetState();
}

class _ReportMessageBottomSheetState extends ConsumerState<ReportMessageBottomSheet> {
  String selectedReport = 'Spam or Scams';

  final List<String> reports = [
    'Spam or Scams',
    'Hate Speech',
    'Found a better alternative',
    'Violence or Threats',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontalSpaceSmall,
              Text(
                'Reason for reporting',
                style: AppTextStyle().bodyLarge,
              ),
            ],
          ),

          verticalSpaceMedium,

          ...reports.map((lang) {
            // final isSelected = selectedReport == lang;

            return InkWell(
              onTap: () {
                setState(() => selectedReport = lang);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang,
                      style: AppTextStyle().bodyMedium.copyWith(fontSize: 14.sp),
                    ),
                    GradientItems(
                      child: Radio<String>(
                        value: lang,
                        groupValue: selectedReport,
                        onChanged: (value) {
                          setState(() => selectedReport = value!);
                        },
                        activeColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          verticalSpaceMedium,

          /// Submit Button
          CustomElevatedButton(
            onPressed: () async {
              // Prepare messages slice (chronologically ordered)
              final List<Map<String, dynamic>> messagePayload = 
                  widget.contextMessages.reversed.map((msg) {
                return {
                  "sender_user_id": msg.senderId.toString(),
                  "receiver_user_id": msg.recipientId.toString(),
                  // "reported_user_email": widget.reportedUserMail,
                  "message_text": msg.content,
                  "message_type": "text",
                  "sequence_order": msg.id,
                  "is_reported_message": msg.id == widget.reportedMessageId,
                  "sent_at": DateTime.fromMillisecondsSinceEpoch(msg.timestamp * 1000).toIso8601String(),
                };
              }).toList();
              final success = await ref.read(chatControllerProvider.notifier).reportMessage(
                    reason: selectedReport,
                    description: "customer reporting agent",
                    reportedUserMail: widget.reportedUserMail,
                    messages: messagePayload,
                  );

              if (success && mounted) {
                Navigator.pop(context);
                showReportedMsgDialog(context);
              }
            },
            label: "Submit",
          ),
        ],
      ),
    );
  }
}

void showReportMessageBottomSheet(
  BuildContext context, {
  required List<ChatMessage> contextMessages,
  required int reportedMessageId,
  required String reportedUserId,
  required String reportedUserMail,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ReportMessageBottomSheet(
        contextMessages: contextMessages,
        reportedMessageId: reportedMessageId,
        reportedUserId: reportedUserId,
        reportedUserMail: reportedUserMail,
      );
    },
  );
}

void showReportedMsgDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: Container(
          padding: EdgeInsets.all(24.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Assets.reported, width: 50.w, height: 50.h),
              verticalSpaceMedium,
              Text(
                'Report submitted successfully',
                style: AppTextStyle().titleSmall,
              ),
              verticalSpaceSmall,
              Text(
                'Our team will review it shortly',
                textAlign: TextAlign.center,
                style: AppTextStyle().bodyMedium,
              ),
              verticalSpaceMedium,
              CustomElevatedButton(
                onPressed: () => NavigationService.pop(),
                label: "OK",
              )
            ],
          ),
        ),
      );
    },
  );
}
