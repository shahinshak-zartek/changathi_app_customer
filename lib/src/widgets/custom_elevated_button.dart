

import '../app/theme.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/theme_x.dart';
import '../util/ui_helper.dart';
import '../app/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.label = '',
    this.width,
    this.height,
    this.color,
    this.textColor,
    this.shadowColor = Palette.white,
    this.borderRadius,
    this.labelTextStyle,
    this.icon,
    this.borderSide,
    this.isLoading = false,
    this.isEnabled = true,
    this.nosShadow=false,
  });

  final Color? color;
  final Color? textColor;
  final Color? shadowColor;
  final bool isLoading;
  final bool nosShadow;
  final bool isEnabled;
  final double? width;
  final double? height;
  final String label;
  final VoidCallback? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? labelTextStyle;
  final Widget? icon;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height??42.h,
      width: width??300.w,
      decoration: BoxDecoration(
        boxShadow:nosShadow?null:[BoxShadow(
          color: Colors.black.withOpacity(0.1), // Light shadow color
          spreadRadius: 1, // How wide the shadow spreads
          blurRadius: 4,   // How soft the shadow looks
          offset: Offset(0, 2), // Horizontal & vertical shadow position
        ),] ,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
       color: color,
        gradient: color==null? LinearGradient(

          colors: [
            // color ?? Palette.gradient2begin,
            // color ?? Palette.gradient2mid,
            // color ?? Palette.gradient2end,
            color ?? Palette.deepRoyalPinkBegin,
            color ?? Palette.deepRoyalVioletMid,
            color ?? Palette.deepSkyBlueEnd,

            // color ?? Palette.gradient2end,
          ],
        )
      :null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.zero,
          // Set this
          padding: EdgeInsets.zero,
          //
          elevation: 3,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(10),
              side: borderSide ??
                  const BorderSide(width: 0, color: AppColors.transparent)),
        ),
        /* style: ButtonStyle(
          backgroundColor: onPressed == null
              ? MaterialStateProperty.all<Color>(AppColors.white)
              : MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(8),
                side: borderSide ??
                    const BorderSide(width: 0, color: Colors.transparent)),
          ),
        ),*/
        onPressed: isLoading ? null : onPressed,
        child: icon!=null?Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(isLoading)
                  const SizedBox(
                height: 25,
                width: 25,
                child: CupertinoActivityIndicator(),
              ),

             icon ?? Container(),
              horizontalSpaceSmall,
              Text(
                textAlign: TextAlign.center,
                isLoading ? ' Loading' : label,
                style: labelTextStyle ??
                    context.labelLarge(
                        fontSize: 14.sp,
                        textColor: onPressed == null
                            ? Palette.fontLight
                            : textColor ?? Palette.white),
              ),

          ],
          ),
        ):Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CupertinoActivityIndicator(),
                  )
                : Container(),
            isLoading ? horizontalSpaceTiny : Container(),

            Text(
              textAlign: TextAlign.center,
              isLoading ? ' Loading' : label,
              style: labelTextStyle ??
                  context.labelLarge(
                      fontSize: 14.sp,
                      textColor: onPressed == null
                          ? Palette.fontLight
                          : textColor ?? Palette.white),
            ),
          ],
        ),
      ),
    );
  }
}
