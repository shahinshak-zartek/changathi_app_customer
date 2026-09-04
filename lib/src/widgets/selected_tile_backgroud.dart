
import 'package:flutter/cupertino.dart';

import '../app/palette.dart';


class SelectedTileBackground extends StatefulWidget {
  final Widget? child;
  final bool selected;
  const SelectedTileBackground({super.key,this.child,required this.selected});

  @override
  State<SelectedTileBackground> createState() => _SelectedTileBackgroundState();
}

class _SelectedTileBackgroundState extends State<SelectedTileBackground> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        gradient: widget.selected?  LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [

          Palette.gradient3end,
          Palette.gradient3mid,
            Palette.gradient3begin,
          ],
        ):null,
        borderRadius: BorderRadius.circular(5)
      ),
      child: widget.child,
    );
  }
}
