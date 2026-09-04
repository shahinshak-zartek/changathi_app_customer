import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zartek_core/src/features/auth/controller/login_controller.dart';
import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';

void showLogoutAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: Container(
          padding:  EdgeInsets.all(24.sp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:  Icon(
                    Icons.close,
                    size: 24.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Warning icon
              GradientItems(
                child: Container(
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                
                      borderRadius: BorderRadiusGeometry.circular(15.sp),
                    border: Border.all(color: Colors.white)
                  ),
                  child:SvgPicture.asset(Assets.logout,color: Colors.white,width: 45.w,height: 45.h,)
                ),
              ),
              verticalSpaceMedium,
              // Title
              Text('Logout', style: AppTextStyle().titleLarge,),
              verticalSpaceSmall,
              // Description
              Text(
                  'Are you sure you want to logout from your account?',
                  textAlign: TextAlign.center,
                  style:AppTextStyle().bodyMedium
              ),
              verticalSpaceMedium,
              // Logout button
              Consumer(
                builder: (context,ref,child) {
                  final state =
                  ref.watch(loginControllerProvider);
                  final isLoading = state is LoginStateLoading;
                  return CustomElevatedButton(
                    isLoading: isLoading,
                    onPressed: (){
                      ref.read(loginControllerProvider.notifier).logout();
                  },label: "Logout",);
                }
              )
            ],
          ),
        ),
      );
    },
  );
}
