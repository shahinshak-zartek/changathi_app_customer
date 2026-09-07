import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/permission/utils/microphone_permission_fun.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';


class MicrophonePermissionPage extends StatelessWidget {
  const MicrophonePermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: getWidth(context: context),
          height: getHeight(context: context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Microphone Icon with Gradient Border
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                       Palette.deepRoyalPinkBegin,
                       Palette.deepRoyalVioletMid,
                       Palette.deepSkyBlueEnd,
                      ],
                    ),
                  ),
                  padding:  EdgeInsets.all(3.sp),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child:  Center(
                      child: GradientItems(
                        child: Icon(
                          Icons.mic_none,
                          size: 70.sp,
                          color:Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
          
               verticalSpaceMedium,
          
                // Title
                 Text(
                  'Allow Microphone\nAccess?',
                  textAlign: TextAlign.center,
                  style:AppTextStyle().titleLarge
                ),
          
               verticalSpaceSmall,
          
                // Description
                Text(
                  'We need microphone access to enable\n'
                      'voice calls and communication with\nyour contacts.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle().bodyMedium.copyWith(color: Colors.grey),
                ),
          
               verticalSpaceLarge,
          
                // Allow Button (Gradient)
                CustomElevatedButton(onPressed: () {
                   requestMicrophonePermission(context);
                },
                  label: "Continue",
                ),
              // verticalSpaceSmall,
              //   GradientItems(
              //     child: CustomElevatedButton(onPressed: () {
              //       NavigationService.pushReplacement(page: AppRoutes.home);
              //     },
              //       color: Colors.transparent,
              //       nosShadow: true,
              //       borderSide: BorderSide(color: Colors.white),
              //       label: "Not Now",
              //     ),
              //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
