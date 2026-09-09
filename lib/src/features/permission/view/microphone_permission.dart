import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/permission/utils/microphone_permission_fun.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';


class MicrophonePermissionPage extends StatelessWidget {
  const MicrophonePermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                  width: 100.w,
                  height: 100.h,
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
                      color: Colors.black,
                    ),
                    child:  Center(
                      child: GradientItems(
                        child: Icon(
                          Icons.mic_none,
                          size: 60.sp,
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
                verticalSpaceSX,

                // Description
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Palette.containerBorder, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Image.asset(Assets.secureGreen, width: 50.w, height: 50.h),
                      Text(
                        'Your microphone is used only when you\n'
                            'are on call.',
                        textAlign: TextAlign.center,
                        style: AppTextStyle().bodyMedium.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                verticalSpaceMedium,
          
                // Allow Button (Gradient)
                CustomElevatedButton(onPressed: () {
                   requestMicrophonePermission(context);
                },
                  label: "Allow Microphone",
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
