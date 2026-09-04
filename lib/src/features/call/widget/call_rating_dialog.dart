import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/app_text_style.dart';
import '../../../widgets/custom_elevated_button.dart';

class CallRatingDialog extends StatefulWidget {
  final String agentName;
  final Function(int rating) onRatingSelected;

  const CallRatingDialog({
    super.key,
    required this.agentName,
    required this.onRatingSelected,
  });

  @override
  State<CallRatingDialog> createState() => _CallRatingDialogState();
}

class _CallRatingDialogState extends State<CallRatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.agentName,
              style: AppTextStyle().titleMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      index < _selectedRating ? Icons.star : Icons.star_border,
                      color: index < _selectedRating
                          ? const Color(0xFFFFD700)
                          : Colors.grey.shade300,
                      size: 36.sp,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 15.h),
            Text(
              "Please rate your call with ${widget.agentName}",
              textAlign: TextAlign.center,
              style: AppTextStyle().bodySmall.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 25.h),
            CustomElevatedButton(
              label: "Rate",
              isLoading: _isSubmitting,
              onPressed: _selectedRating > 0
                  ? () {
                      setState(() => _isSubmitting = true);
                      widget.onRatingSelected(_selectedRating);
                    }
                  : null,
              width: 120.w,
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}
