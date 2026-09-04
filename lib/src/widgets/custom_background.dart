import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zartek_core/src/app/providers.dart';
import '../app/theme.dart';

class CustomBackGround extends ConsumerStatefulWidget {
  const CustomBackGround({this.child, super.key});

  final Widget? child;

  @override
  ConsumerState<CustomBackGround> createState() => _CustomBackGroundState();
}

class _CustomBackGroundState extends ConsumerState<CustomBackGround> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(darkAppThemeModeProvider);
    return Container(
      decoration: BoxDecoration(
        gradient: !isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.linearTop,
                  AppColors.linearMiddle,
                  AppColors.linearBottom,
                ],
              ),
      ),
      child: widget.child,
    );
  }
}
