import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zartek_core/src/features/auth/controller/login_controller.dart';

import '../../../app/app_text_style.dart';
import '../../../app/theme.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';

void showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: Container(
          padding:  EdgeInsets.all(12.sp),
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
              Container(
               padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  color: Color(0x14ff5555),
                  borderRadius: BorderRadiusGeometry.circular(10.sp)
                ),
                child:  Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 32.sp,
                ),
              ),

             verticalSpaceMedium,

              // Title
               Text(
                'Delete Account?',
                style: AppTextStyle().titleMedium,
              ),

             verticalSpaceSmall,

              // Description
              Text(
                'This action cannot be undone. All your data will be permanently removed.',
                textAlign: TextAlign.center,
                style:AppTextStyle().bodyMedium
              ),

              verticalSpaceMedium,

              // Warning points
              Divider(color: Colors.grey.shade200,),
              Container(
                padding:  EdgeInsets.all(16.sp),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarningPoint('All personal data will be deleted'),
                    verticalSpaceSmall,
                    _buildWarningPoint('Chat history will be lost forever'),
                    verticalSpaceSmall,
                    _buildWarningPoint('You\'ll lose access to all services'),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade200,),
              verticalSpaceMedium,
              // Delete button
              Consumer(
                  builder: (context,ref,child) {
                    final state =
                    ref.watch(loginControllerProvider);
                    final isLoading = state is LoginStateLoading;
                    return CustomElevatedButton(
                      isLoading: isLoading,
                        color: AppColors.red,
                      onPressed: (){
                        ref.read(loginControllerProvider.notifier).deleteAccount();
                      },label: "Delete Account",
                    );
                  }
              )
              // Delete button
        //      CustomElevatedButton(
        //      onPressed: (){
        //        ref.read(loginControllerProvider.notifier).logout();
        // // NavigationService.pop(),color: AppColors.red
        //      },label: "Delete Account",)
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildWarningPoint(String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CircleAvatar(
        backgroundColor: Colors.black,
        radius: 3.sp,
      ),

      horizontalSpaceSX,
      Expanded(
        child: Text(
          text,
          style: AppTextStyle().bodyMedium
        ),
      ),
    ],
  );
}

// Usage example:
// Call this function from your Profile screen or wherever you need it
// showDeleteAccountDialog(context);