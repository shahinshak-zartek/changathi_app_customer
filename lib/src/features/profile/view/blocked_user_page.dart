import 'package:flutter/material.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';

class BlockedUserPage extends StatelessWidget {
  const BlockedUserPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Palette.deepRoyalVioletBegin,
        Palette.deepRoyalVioletMid,
        Palette.deepRoyalVioletEnd,
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 28.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyle().bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
