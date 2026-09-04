import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../app/palette.dart';
import '../app/theme_x.dart';
import '../constants/assets.dart';

class WhatsappContainer extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;
  final bool isEnabled;

  const WhatsappContainer({
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
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2e0287),
              Color(0xFF9751f8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(1.5), // Border width
          decoration: BoxDecoration(
            color: Palette.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Assets.whatsapp,width: 20.sp,height: 20.sp,
                  ),
                  const SizedBox(width: 12),
                  if (isLoading)
                    const SizedBox(
                      height: 25,
                      width: 25,
                      child: CupertinoActivityIndicator(),
                    ),
                  if (isLoading) SizedBox(width: 6.w),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF2e0287),
                        Color(0xFF9751f8),
                      ],
                    ).createShader(bounds),
                    child:  Text(
                      isLoading ? 'Sending' : 'Send OTP via WhatsApp',
                      style: context.labelLarge(
                        fontSize: 14.sp,
                        textColor: Palette.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
