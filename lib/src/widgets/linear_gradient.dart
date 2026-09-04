
import 'package:flutter/cupertino.dart';

import '../app/palette.dart';

class CustomGradient extends StatelessWidget {
  const CustomGradient({super.key, this.child, this.showGradient2 = false,this.solid=false});
  final bool solid;
  final Widget? child;
  final bool showGradient2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: solid?null:showGradient2
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Palette.deepRoyalVioletBegin,
                  Palette.deepRoyalVioletMid,
                  Palette.deepRoyalVioletEnd,
                ],
              )
            : LinearGradient(
                colors: [
                  Palette.deepRoyalVioletBegin,
                  Palette.deepRoyalVioletMid,
                  Palette.deepRoyalVioletEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: solid?Color(0xFFFFCDB1):null
      ),
      child: child,
    );
  }
}
