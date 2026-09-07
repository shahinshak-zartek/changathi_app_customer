
import 'package:Changathi/src/app/palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/widgets.dart';

import 'app_font_weight.dart';

/// Text Style Definitions
class AppTextStyle {
  final _baseTextStyle = TextStyle(
    letterSpacing: 3,
    // Font is declared in the zartek_core package pubspec, so it must be
    // referenced with the package-qualified family name.
    fontFamily: 'packages/zartek_core/Poppins',
    // color: Palette.lightModeText,
    color: Palette.white,
    // letterSpacing: 1.5,
    fontWeight: AppFontWeight.regular,
  );

  /// Headline 1 Text Style
  TextStyle get displayLarge {
    return _baseTextStyle.copyWith(
      fontSize: 64.sp,
      fontWeight: AppFontWeight.bold,
      color: Palette.white,
    );
  }

  /// Headline 2 Text Style
  TextStyle get displayMedium {
    return _baseTextStyle.copyWith(
      fontSize: 32.sp,
      fontWeight: AppFontWeight.bold,
      color: Palette.white,
    );
  }

  /// Headline 3 Text Style
  TextStyle get displaySmall {
    return _baseTextStyle.copyWith(
      fontSize: 24.sp,
      fontWeight: AppFontWeight.bold,
      color: Palette.white,
    );
  }

  /// Headline 4 Text Style
  TextStyle get headlineMedium {
    return _baseTextStyle.copyWith(
      fontSize: 14.sp,
      fontWeight: AppFontWeight.bold,
      color: Palette.white,
    );
  }

  /// Headline 5 Text Style
  TextStyle get headlineSmall {
    return _baseTextStyle.copyWith(
      fontSize: 24.sp,
      fontWeight: FontWeight.w500,
      color: Palette.white,
    );
  }

  /// Headline 6 Text Style
  TextStyle get titleLarge {
    return _baseTextStyle.copyWith(
      fontSize: 20.sp,
      letterSpacing: 0.15,
      fontWeight: FontWeight.w600,
      color: Palette.white,
    );
  }

  /// Subtitle 1 Text Style
  TextStyle get titleMedium {
    return _baseTextStyle.copyWith(
      fontSize: 14.sp,
      letterSpacing: 1,
      fontWeight: FontWeight.bold,
      color: Palette.white,
    );
  }

  /// Subtitle 2 Text Style
  TextStyle get titleSmall {
    return _baseTextStyle.copyWith(
      fontSize: 11.sp,
      letterSpacing: .9,
      fontWeight: AppFontWeight.semiBold,
      color: Palette.white,
    );
  }

  /// Body Text 1 Text Style
  TextStyle get bodyLarge {
    return _baseTextStyle.copyWith(
      fontSize: 18.sp,
      letterSpacing: 0.9,
      fontWeight: AppFontWeight.regular,
      color: Palette.white,
    );
  }

  TextStyle get bodyLargeWebViewContent {
    return _baseTextStyle.copyWith(
      fontSize: 16.sp,
      letterSpacing: 0.9,
      fontWeight: AppFontWeight.regular,
      color: Palette.white,
    );
  }

  /// Body Text 2 Text Style (the default)
  TextStyle get bodyMedium {
    return _baseTextStyle.copyWith(
      fontSize: 11.sp,
      letterSpacing: 0.6,
      fontWeight: AppFontWeight.regular,
      color: Palette.white,
    );
  }

  /// Caption Text Style
  TextStyle get bodySmall {
    return _baseTextStyle.copyWith(
      fontSize: 10.sp,
      letterSpacing: 0.8,
      fontWeight: AppFontWeight.regular,
      color: Palette.white,
    );
  }
  /// expertise Text Style
  TextStyle get bodySmallTile {
    return _baseTextStyle.copyWith(
      fontSize: 9.sp,
      letterSpacing: 0.8,
      fontWeight: AppFontWeight.regular,
      color: Palette.white,
    );
  }

  /// Button Text Style
  TextStyle get labelLarge {
    return _baseTextStyle.copyWith(
      fontSize: 16.sp,
      fontWeight: AppFontWeight.light,
      letterSpacing: 1.1,
      color: Palette.white,
    );
  }

  TextStyle get labelMedium {
    return _baseTextStyle.copyWith(
      fontSize: 14.sp,
      fontWeight: AppFontWeight.semiBold,
      // letterSpacing: 1.25,
      color: Palette.white,
    );
  }

  /// Overline Text Style
  TextStyle get labelSmall {
    return _baseTextStyle.copyWith(
      fontSize: 13.sp,
      fontWeight: AppFontWeight.semiBold,
      letterSpacing: 0.9,
      color: Palette.white,
    );
  }
}
