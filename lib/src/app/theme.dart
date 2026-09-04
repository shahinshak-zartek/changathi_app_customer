
import 'package:Nizhal/src/app/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zartek_core/src/config/app_config.dart';
import 'app_font_weight.dart';
import 'app_text_style.dart';

class AppColors {
  static const linearTop = Color(0xFF1F2728);
  static const linearBottom = Color(0xFF222926);
  static const linearMiddle = Color(0xFF222325);

  /// Primary brand color — resolved per-client from [AppConfig.colors].
  static Color get primary => AppConfigScope.instance.colors.primary;
  static const primaryBlend = Color(0xFF006B8F);
  static const gray1 = Color(0xFF404040);
  static const gray3 = Color(0xFFDBDBDB);
  static const orange = Color(0xFFF14F03);
  static const red = Color(0xFFEF4444);
  static const gray = Color(0xFFc9c9c9);
  static const green = Color(0xFF22C55E);
  static const black = Color(0xFF222222);
  static const lightGray = Color(0xFF9B9B9B);
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
}

///Material Design typography
/*NAME         SIZE  WEIGHT  SPACING
headline1    96.0  light   -1.5
headline2    60.0  light   -0.5
headline3    48.0  regular  0.0
headline4    34.0  regular  0.25
headline5    24.0  regular  0.0
headline6    20.0  medium   0.15
subtitle1    16.0  regular  0.15
subtitle2    14.0  medium   0.1
body1        16.0  regular  0.5   (bodyText1)
body2        14.0  regular  0.25  (bodyText2)
button       14.0  medium   1.25
caption      12.0  regular  0.4
overLine     10.0  regular  1.5*/

/// Ref: Font Weights: https://api.flutter.dev/flutter/dart-ui/FontWeight-class.html
/// Ref: Font Weights for TextTheme: https://api.flutter.dev/flutter/material/TextTheme-class.html

/// [AppTheme] - A complete app theme, used for the entire app
///
/// It can be customized by using `ThemeData` widget or `copyWith` method at anytime later for specific widgets
class AppTheme {
  const AppTheme(this.colors);

  /// Per-client brand colors used for the theme's accent surfaces.
  final AppConfigColors colors;

  ThemeData get theme {
    return ThemeData(
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: _scaffoldBackground,
        canvasColor: Palette.background,
        dialogBackgroundColor: Palette.white,
        appBarTheme: _appBarTheme,
        bottomNavigationBarTheme: _bottomNavigationBarTheme,
        textButtonTheme: _textButtonTheme,
        textSelectionTheme: _textSelectionTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textTheme: _textTheme,
        dialogTheme: _dialogTheme,
        tooltipTheme: _tooltipTheme,
        bottomSheetTheme: _bottomSheetTheme,
        tabBarTheme: _tabBarTheme,
        dividerTheme: _dividerTheme,
        inputDecorationTheme: _inputDecorationTheme,
        pageTransitionsTheme: _pageTransitionsTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        iconTheme: _iconTheme,
        checkboxTheme: _checkBoxTheme,
        drawerTheme: _drawerTheme,
        radioTheme: _radioTheme,
        popupMenuTheme: _popupMenuTheme,
        sliderTheme: _sliderTheme,
        listTileTheme: _listTileTheme,
        cardTheme: _cardTheme);
  }

  CardThemeData get _cardTheme {
    return const CardThemeData(color: Palette.white);
  }

  Color get _scaffoldBackground {
    return Palette.background;
  }

  ColorScheme get _colorScheme {
    return const ColorScheme.light(
      secondary: Palette.primary,
      background: Palette.background,
    );
  }

  TextTheme get _textTheme => textTheme;

  TextTheme get textTheme {
    return TextTheme(
      displayLarge:
          AppTextStyle().displayLarge.copyWith(color: Palette.black),
      displayMedium:
          AppTextStyle().displayMedium.copyWith(color: Palette.black),
      displaySmall:
          AppTextStyle().displaySmall.copyWith(color: Palette.black),
      headlineMedium:
          AppTextStyle().headlineMedium.copyWith(color: Palette.black),
      headlineSmall:
          AppTextStyle().headlineSmall.copyWith(color: Palette.black),
      titleLarge: AppTextStyle().titleLarge.copyWith(color: Palette.black),
      titleMedium: AppTextStyle().titleMedium.copyWith(color: Palette.black),
      titleSmall: AppTextStyle().titleSmall.copyWith(color: Palette.black),
      bodyLarge: AppTextStyle().bodyLarge.copyWith(color: Palette.black),
      bodyMedium: AppTextStyle().bodyMedium.copyWith(color: Palette.black),
      bodySmall: AppTextStyle().bodySmall.copyWith(color: Palette.black),
      labelLarge: AppTextStyle().labelLarge.copyWith(color: Palette.black),
      labelSmall: AppTextStyle().labelSmall.copyWith(color: Palette.black),
    );
  }

  AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: Palette.primary,
      elevation: 0.0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Palette.black),
      titleTextStyle:
          AppTextStyle().titleMedium.copyWith(color: Palette.black),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Palette.white,
      selectedItemColor: Palette.black,
      unselectedItemColor: Palette.fontDarkSecondary,
      selectedIconTheme: IconThemeData(
        color: Palette.black,
      ),
      unselectedIconTheme: IconThemeData(
        color: Palette.fontDarkSecondary,
      ),
    );
  }

  TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.secondary,
        textStyle: AppTextStyle()
            .headlineMedium
            .copyWith(fontWeight: AppFontWeight.extraBold),
      ),
    );
  }

  TextSelectionThemeData get _textSelectionTheme {
    return const TextSelectionThemeData(
      cursorColor: Palette.labelColor,
      selectionColor: Palette.labelColor,
      selectionHandleColor: Palette.labelColor,
    );
  }

  OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        side: const BorderSide(color: Palette.white, width: 2),
        padding:  EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Palette.white,
        minimumSize: const Size(208, 54),
      ),
    );
  }

  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: Palette.black,
        textStyle: AppTextStyle().labelMedium.copyWith(color: Palette.white),
      ),
    );
  }

  DialogThemeData get _dialogTheme {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Palette.darkBackground,
      titleTextStyle: AppTextStyle().titleMedium,
      contentTextStyle: AppTextStyle().bodyLarge,
    );
  }

  TooltipThemeData get _tooltipTheme {
    return const TooltipThemeData(
      decoration: BoxDecoration(
        color: Palette.black,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: EdgeInsets.all(10),
      textStyle: TextStyle(color: Palette.white),
    );
  }

  TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 5.0,
          color: Palette.black,
        ),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Palette.white.withOpacity(0.5); // Pressed state
          }
          if (states.contains(WidgetState.hovered)) {
            return Palette.borderGary; // Hovered state
          }
          if (states.contains(WidgetState.focused)) {
            return Palette.borderGary; // Focused state
          }
          return null; // Default state (no overlay)
        },
      ),
      labelColor: Palette.black,
      unselectedLabelColor: Palette.black,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: AppTextStyle()
          .labelLarge
          .copyWith(fontWeight: AppFontWeight.semiBold),
      unselectedLabelStyle: AppTextStyle()
          .bodyMedium
          .copyWith(fontWeight: AppFontWeight.semiBold),
    );
  }

  DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      space: 0,
      thickness: 0.5,
      color: Palette.grey,
    );
  }

  BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: Palette.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: Palette.white,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: InputBorder.none,
      labelStyle: AppTextStyle().bodySmall.copyWith(color: Palette.grey),
      hintStyle: AppTextStyle().bodySmall.copyWith(color: Palette.grey),
    );
  }

  PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    );
  }

  ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
      circularTrackColor: Colors.red,
    );
  }

  IconThemeData get _iconTheme {
    return const IconThemeData(color: Palette.black);
  }

  CheckboxThemeData get _checkBoxTheme {
    return CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Palette.black),
      fillColor: MaterialStateProperty.all(Palette.transparent),
      // side: const BorderSide(color: Palette.black),
      side: MaterialStateBorderSide.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const BorderSide(color: Palette.black);
        } else {
          return const BorderSide(color: Palette.black);
        }
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  DrawerThemeData get _drawerTheme {
    return const DrawerThemeData(
      backgroundColor: Palette.darkGrey,
    );
  }

  RadioThemeData get _radioTheme {
    return RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => Palette.black,
        ),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => Palette.black,
        ));
  }

  PopupMenuThemeData get _popupMenuTheme {
    return PopupMenuThemeData(
      color: Palette.white,
      textStyle: AppTextStyle().bodyMedium,
    );
  }

  SliderThemeData get _sliderTheme {
    return SliderThemeData(
      thumbColor: colors.secondary,
      activeTrackColor: colors.secondary,
      inactiveTrackColor: Palette.lightGrey,
    );
  }

  ListTileThemeData get _listTileTheme {
    return const ListTileThemeData(iconColor: Palette.black);
  }
}

/// Dark Mode App [ThemeData].
class AppDarkTheme {
  ThemeData get theme {
    return ThemeData(
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: Palette.darkBackground,
        canvasColor: Palette.darkBackground,
        dialogBackgroundColor: Palette.white,
        appBarTheme: _appBarTheme,
        bottomNavigationBarTheme: _bottomNavigationBarTheme,
        textButtonTheme: _textButtonTheme,
        textSelectionTheme: _textSelectionTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textTheme: _textTheme,
        dialogTheme: _dialogTheme,
        tooltipTheme: _tooltipTheme,
        bottomSheetTheme: _bottomSheetTheme,
        tabBarTheme: _tabBarTheme,
        dividerTheme: _dividerTheme,
        inputDecorationTheme: _inputDecorationTheme,
        pageTransitionsTheme: _pageTransitionsTheme,
        progressIndicatorTheme: _progressIndicatorTheme,
        iconTheme: _iconTheme,
        checkboxTheme: _checkBoxTheme,
        drawerTheme: _drawerTheme,
        radioTheme: _radioTheme,
        popupMenuTheme: _popupMenuTheme,
        sliderTheme: _sliderTheme,
        listTileTheme: _listTileTheme,
        cardTheme: _cardTheme);
  }

  CardThemeData get _cardTheme {
    return const CardThemeData(
        color: Palette.white, shadowColor: Palette.white);
  }

  ColorScheme get _colorScheme {
    return const ColorScheme.dark(
      secondary: Palette.primary,
      background: Palette.background,
    );
  }

  TextTheme get _textTheme => textTheme;

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge:
          AppTextStyle().displayLarge.copyWith(color: Palette.fontLight),
      displayMedium:
          AppTextStyle().displayMedium.copyWith(color: Palette.fontLight),
      displaySmall:
          AppTextStyle().displaySmall.copyWith(color: Palette.fontLight),
      headlineMedium:
          AppTextStyle().headlineMedium.copyWith(color: Palette.fontLight),
      headlineSmall:
          AppTextStyle().headlineSmall.copyWith(color: Palette.fontLight),
      titleLarge: AppTextStyle().titleLarge.copyWith(color: Palette.fontLight),
      titleMedium:
          AppTextStyle().titleMedium.copyWith(color: Palette.fontLight),
      titleSmall: AppTextStyle().titleSmall.copyWith(color: Palette.fontLight),
      bodyLarge: AppTextStyle().bodyLarge.copyWith(color: Palette.fontLight),
      bodyMedium: AppTextStyle().bodyMedium.copyWith(color: Palette.fontLight),
      bodySmall: AppTextStyle().bodySmall.copyWith(color: Palette.fontLight),
      labelLarge: AppTextStyle().labelLarge.copyWith(color: Palette.fontLight),
      labelSmall: AppTextStyle().labelSmall.copyWith(color: Palette.fontLight),
    );
  }

  AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: Palette.linearTop,
      elevation: 0.0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Palette.white),
      titleTextStyle: AppTextStyle().titleMedium.copyWith(
            color: Palette.fontLight,
          ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Palette.background,
      selectedItemColor: Palette.white,
      unselectedItemColor: Palette.grey,
      selectedIconTheme: IconThemeData(
        color: Palette.white,
      ),
      unselectedIconTheme: IconThemeData(
        color: Palette.grey,
      ),
    );
  }

  TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.secondary,
        textStyle: AppTextStyle()
            .headlineMedium
            .copyWith(fontWeight: AppFontWeight.extraBold),
      ),
    );
  }

  TextSelectionThemeData get _textSelectionTheme {
    return const TextSelectionThemeData(
      cursorColor: Palette.primary,
      selectionColor: Palette.primary,
      selectionHandleColor: Palette.primary,
    );
  }

  OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        side: const BorderSide(color: Palette.white, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Palette.white,
        minimumSize: const Size(208, 54),
      ),
    );
  }

  ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        backgroundColor: Palette.black,
        textStyle: AppTextStyle().labelMedium.copyWith(color: Palette.white),
      ),
    );
  }

  DialogThemeData get _dialogTheme {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Palette.darkBackground,
      titleTextStyle: AppTextStyle().titleMedium,
      contentTextStyle: AppTextStyle().bodyLarge,
    );
  }

  TooltipThemeData get _tooltipTheme {
    return const TooltipThemeData(
      decoration: BoxDecoration(
        color: Palette.black,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      padding: EdgeInsets.all(10),
      textStyle: TextStyle(color: Palette.darkBackgroundSecondary),
    );
  }

  TabBarThemeData get _tabBarTheme {
    return TabBarThemeData(
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 5.0,
          color: Palette.secondary,
        ),
      ),
      labelColor: Palette.white,
      unselectedLabelColor: Palette.white,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: AppTextStyle()
          .bodyMedium
          .copyWith(fontWeight: AppFontWeight.semiBold),
      unselectedLabelStyle: AppTextStyle()
          .bodyMedium
          .copyWith(fontWeight: AppFontWeight.semiBold),
    );
  }

  DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      space: 0,
      thickness: 0.5,
      color: Palette.grey,
    );
  }

  BottomSheetThemeData get _bottomSheetTheme {
    return const BottomSheetThemeData(
      backgroundColor: Palette.darkBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }

  InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      // fillColor: AppColors.grayBg,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: InputBorder.none,
      labelStyle: AppTextStyle().bodySmall.copyWith(color: Palette.grey),
      hintStyle: AppTextStyle().bodySmall.copyWith(color: Palette.grey),
    );
  }

  PageTransitionsTheme get _pageTransitionsTheme {
    return const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
      },
    );
  }

  ProgressIndicatorThemeData get _progressIndicatorTheme {
    return const ProgressIndicatorThemeData(
        // circularTrackColor: Palette.yellowGradientBottom,
        );
  }

  IconThemeData get _iconTheme {
    return const IconThemeData(color: Palette.white);
  }

  CheckboxThemeData get _checkBoxTheme {
    return CheckboxThemeData(
      checkColor: MaterialStateProperty.all(Palette.white),
      fillColor: MaterialStateProperty.all(Palette.transparent),
      // side: const BorderSide(color: Palette.black),
      side: MaterialStateBorderSide.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const BorderSide(color: Palette.white);
        } else {
          return const BorderSide(color: Palette.white);
        }
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  DrawerThemeData get _drawerTheme {
    return const DrawerThemeData(
      backgroundColor: Palette.darkGrey,
    );
  }

  RadioThemeData get _radioTheme {
    return RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => Palette.primary2Dark,
        ),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => Palette.primary2Dark,
        ));
  }

  PopupMenuThemeData get _popupMenuTheme {
    return PopupMenuThemeData(
      color: Palette.white,
      textStyle: AppTextStyle().bodyMedium,
    );
  }

  SliderThemeData get _sliderTheme {
    return const SliderThemeData(
      thumbColor: Palette.secondary,
      activeTrackColor: Palette.secondary,
      inactiveTrackColor: Palette.lightGrey,
    );
  }

  ListTileThemeData get _listTileTheme {
    return const ListTileThemeData(iconColor: Palette.white);
  }
}
