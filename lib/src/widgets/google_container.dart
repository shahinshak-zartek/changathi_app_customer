import 'package:Changathi/src/util/ui_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/app_text_style.dart';
import '../constants/assets.dart';

class GoogleContainer extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  const GoogleContainer({
    super.key,
    required this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading || !isEnabled ? null : onTap,
      child: Container(
        width: 300.w,
        height: 42.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFd72ebe),
              Color(0xFF2a6dcc),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.google, width: 15.w),
              horizontalSpaceSmall,
              if (isLoading)
                const SizedBox(
                  height: 25,
                  width: 25,
                  child: CupertinoActivityIndicator(
                    color: Colors.black,
                  ),
                ),

              if (isLoading) SizedBox(width: 6.w),

              Text(
                isLoading ? 'Sending' : 'Continue with Google',
                style: AppTextStyle().bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
