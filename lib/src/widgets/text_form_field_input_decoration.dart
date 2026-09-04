
import 'package:flutter/material.dart';
import '../app/theme_x.dart';


InputDecoration buildInputDecoration(
  BuildContext context, {
  String? labelText,
  String? suffixText,
  String? hintText,
  Widget? prefixIcon,
  Widget? prefix,
  Widget? suffixIcon,
      bool?onfocus,
  bool showLabel = false,
  BorderRadius? borderRadius,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  Color borderColor = const Color(0xffECECEC),
  Color? fillColor ,
  Color? labelColor,
  double? borderThickness,
}) {
  return InputDecoration(
    suffixText: suffixText,
    labelText: labelText,
    hintText: hintText,
    floatingLabelBehavior:FloatingLabelBehavior.auto,
    //labelText: showLabel ? (labelText ?? '') : null,
    //hintText: showLabel ? null : (labelText ?? ''),
    counterText: '',

    hintStyle: hintStyle ??
        context.bodyMedium(textColor: labelColor ??  Colors.grey,),
    labelStyle:labelStyle??
        context.bodyMedium(textColor: labelColor ?? Colors.grey),
    contentPadding: const EdgeInsets.only(right: 5, left: 18, top: 15),
    prefix: prefix,
    prefixIcon: prefixIcon == null
        ? null
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: prefixIcon,
              )
            ],
          ),
    suffixIcon: suffixIcon,
    errorMaxLines: 3,
    border: InputBorder.none,
    filled: true,
    fillColor: fillColor??Colors.transparent,
    //fillColor: fillColor,
    focusedBorder: OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: onfocus==true?Colors.black:borderColor,
        width:borderThickness?? 2.0,
      ),
    ),
    enabledBorder:OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: borderColor,
        width:borderThickness?? 2.0,
      ),
    ),
    focusedErrorBorder:OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: borderColor,
        width: borderThickness?? 2.0,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: borderColor,
        width: borderThickness?? 2.0,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: borderColor,
        width: borderThickness?? 2.0,
      ),
    ),
  );
}
TextStyle formBuilderTextStyle(BuildContext context){
 return context.bodyMedium();
}