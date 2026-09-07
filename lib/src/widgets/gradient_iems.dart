import 'package:flutter/material.dart';
import '../app/palette.dart';

class GradientItems extends StatelessWidget {
  final Widget child;
  final bool gradient;
  const GradientItems({super.key,required this.child,this.gradient=false});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (bounds) => gradient?LinearGradient(colors: [
          Color(0xff9095A1),
          Color(0xff9095A1),
          Color(0xff9095A1),

        ]).createShader(bounds): LinearGradient(
          colors: [
            Palette.deepRoyalPinkBegin,
            Palette.deepRoyalVioletMid,
            Palette.deepSkyBlueEnd,
          ],
        ).createShader(bounds),
        child: child);
  }
}
