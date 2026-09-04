import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxShape? boxShape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFE0E0E0), // light grey
    this.highlightColor = const Color(0xFFF5F5F5), // lighter grey
    this.margin,
    this.padding,
    this.boxShape,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          shape: boxShape??BoxShape.rectangle,
          color: baseColor,
          borderRadius: boxShape!=null?null:borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
