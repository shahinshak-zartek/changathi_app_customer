
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/palette.dart';
import '../app/theme.dart';
import '../app/theme_x.dart';
import '../util/ui_helper.dart';
import 'custom_elevated_button.dart';

showActionDialog(
  BuildContext context, {
  required VoidCallback? onPressed,
  String? title,
  String? subTitle,
  bool disableNonActionButton = false,
  String actionButton = 'Accept',
  String nonActionButton = 'Cancel',
  bool isLoading = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: !isLoading,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Palette.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: isLoading
            ? null
            : Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: context.titleMedium(),
              ),
        content: isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(),
                  verticalSpaceSX,
                  Text(
                    'Please wait..',
                    textAlign: TextAlign.center,
                    style: context.bodyMedium(),
                  )
                ],
              )
            : Text(
                subTitle ?? '',
                textAlign: TextAlign.center,
                style: context.bodyMedium(),
              ),
        actions: <Widget>[
          isLoading
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    disableNonActionButton
                        ? const Spacer()
                        : CustomElevatedButton(
                            //isLoading: isLoading,
                            height: 40.h,
                            width: 100.w,
                            color: AppColors.gray1,
                            shadowColor: AppColors.gray1,
                            borderRadius: BorderRadius.circular(23),
                            label: nonActionButton,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                    CustomElevatedButton(
                      //isLoading: isLoading,
                      height: 40.h,
                      width: 110.w,
                      borderRadius: BorderRadius.circular(23),
                      label: actionButton,
                      onPressed: onPressed,
                    ),
                  ],
                ),
        ],
      );
    },
  );
}
