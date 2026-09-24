import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/app_text_style.dart';
import '../app/palette.dart';
import '../app/theme.dart';
import '../constants/assets.dart';
import 'package:zartek_core/zartek_core.dart';
import '../util/ui_helper.dart';
import 'linear_gradient.dart';

class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  /// Requests a fresh gate check from anywhere below this global gate.
  static Future<void> checkForUpdate(BuildContext context) {
    final state = context.findAncestorStateOfType<UpdateGateState>();
    if (state == null) {
      // This used to be a bare `?? Future.value()`, which meant a call site
      // outside the gate's subtree did nothing at all — no log, no error. That is
      // why the agent_tile checks appeared wired but never ran.
      log(
        'ForceUpdate: checkForUpdate() found no UpdateGate ancestor — this call '
        'site is outside the gate subtree, so NO CHECK RAN. Mount UpdateGate in '
        'MaterialApp.builder (wraps the Navigator), never in home: (wraps only '
        'the first route).',
      );
      assert(false, 'UpdateGate ancestor not found — see the log above.');
      return Future.value();
    }
    return state.checkForUpdate();
  }

  @override
  State<UpdateGate> createState() => UpdateGateState();
}

class UpdateGateState extends State<UpdateGate> {
  final AppUpdateService _service = AppUpdateService();

  /// Static so "Skip"/"Maybe Later" survives gate rebuilds for the whole
  /// session. As an instance field this reset on every rebuild, so the soft
  /// prompt could reappear after the user had already dismissed it.
  static bool _softUpdateSkippedForSession = false;

  Future<void>? _checkInFlight;

  bool _loading = true;
  AppUpdateResult _result = AppUpdateResult.none();

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  /// Coalesces concurrent lifecycle and navigation requests into one check, so
  /// two callers asking at once don't fire two Remote Config fetches.
  Future<void> checkForUpdate() {
    final activeCheck = _checkInFlight;
    if (activeCheck != null) return activeCheck;

    late final Future<void> check;
    check = _runUpdateCheck().whenComplete(() {
      if (identical(_checkInFlight, check)) {
        _checkInFlight = null;
      }
    });
    _checkInFlight = check;
    return check;
  }

  Future<void> _runUpdateCheck() async {
    log('ForceUpdate: Starting update gate check.');
    final result = await _service.checkForceUpdate();

    if (!mounted) return;

    setState(() {
      _result = result;
      _loading = false;
    });

    log(
      'ForceUpdate: Gate completed type=${result.type.name} '
      'platform=${result.platform} currentBuild=${result.currentBuild} '
      'minimumBuild=${result.minimumBuild} latestBuild=${result.latestBuild}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: SizedBox()),
        // body: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_result.type == UpdateType.none ||
        (_result.type == UpdateType.soft && _softUpdateSkippedForSession)) {
      return widget.child;
    }

    // Maintenance blocks like a force update but offers no store button — the
    // backend is deliberately down, so there is nothing for the user to install.
    if (_result.type == UpdateType.maintenance) {
      final gradient = LinearGradient(
        colors: [
          Palette.deepRoyalPinkBegin,
          Palette.deepRoyalVioletMid,
          Palette.deepSkyBlueEnd,
        ],
      );

      return PopScope(
        canPop: false,
        child: Scaffold(
          body: CustomGradient(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(18.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Maintenance icon
                          Container(
                            width: 72.w,
                            height: 72.w,
                            decoration: BoxDecoration(
                              gradient: gradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.construction_rounded,
                              color: Colors.white,
                              size: 34.sp,
                            ),
                          ),
                          verticalSpaceSmall,

                          /// Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _result.title.isNotEmpty
                                  ? _result.title
                                  : 'UNDER MAINTENANCE',
                              style: AppTextStyle().bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          verticalSpaceTiny,

                          /// Message
                          Text(
                            _result.message,
                            textAlign: TextAlign.center,
                            style: AppTextStyle().bodyMedium.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_result.type == UpdateType.force) {
      final gradient = LinearGradient(
        colors: [
          Palette.deepRoyalPinkBegin,
          Palette.deepRoyalVioletMid,
          Palette.deepSkyBlueEnd,
        ],
      );

      return PopScope(
        canPop: false,
        child: Scaffold(
          body: CustomGradient(
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(18.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// App Icon
                          SizedBox(
                            width: 72.w,
                            height: 72.w,
                            child: Image.asset(Assets.appIcon),
                          ),
                          verticalSpaceSmall,

                          /// Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              _result.title,
                              style: AppTextStyle().bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          verticalSpaceTiny,

                          /// Message
                          Text(
                            _result.message,
                            textAlign: TextAlign.center,
                            style: AppTextStyle().bodyMedium.copyWith(
                              color: AppColors.primary.withOpacity(0.85),
                            ),
                          ),
                          verticalSpaceMedium,

                          /// Update Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              gradient: gradient,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.5.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 11.h,
                                ),
                              ),
                              onPressed: () =>
                                  _service.openStore(_result.storeUrl),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /// Gradient icon box
                                  Container(
                                    width: 34.w,
                                    height: 34.w,
                                    decoration: BoxDecoration(
                                      gradient: gradient,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ),
                                  horizontalSpaceSmall,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Update Changathi App',
                                        style: AppTextStyle().titleMedium
                                            .copyWith(color: AppColors.primary),
                                      ),
                                      Text(
                                        'Takes less than a minute',
                                        style: AppTextStyle().bodySmall
                                            .copyWith(
                                              color: AppColors.primary
                                                  .withOpacity(0.6),
                                              fontSize: 10.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          verticalSpaceSmall,

                          /// Version tag
                          Text(
                            'Version ${_result.minimumBuild} is available',
                            style: AppTextStyle().bodySmall.copyWith(
                              color: AppColors.primary.withOpacity(0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (_result.type == UpdateType.soft) {
      final gradient = LinearGradient(
        colors: [
          Palette.deepRoyalPinkBegin,
          Palette.deepRoyalVioletMid,
          Palette.deepSkyBlueEnd,
        ],
      );

      return Scaffold(
        body: CustomGradient(
          child: SafeArea(
            child: Stack(
              children: [
                // ── Skip button top right ──
                Positioned(
                  top: 8,
                  right: 12,
                  child: TextButton(
                    onPressed: () {
                      log('skip');
                      setState(() {
                        _softUpdateSkippedForSession = true;
                      });
                    },
                    child: Text(
                      'Skip',
                      style: AppTextStyle().bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(18.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// App Icon
                            SizedBox(
                              width: 72.w,
                              height: 72.w,
                              child: Image.asset(Assets.appIcon),
                            ),
                            verticalSpaceSmall,

                            /// Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                _result.title.isNotEmpty
                                    ? _result.title
                                    : 'New Update Available',
                                style: AppTextStyle().bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            verticalSpaceTiny,

                            /// Message
                            Text(
                              _result.message.isNotEmpty
                                  ? _result.message
                                  // Brand comes from AppConfig — this used to
                                  // read "Vibe Talk" in the Changathi app.
                                  : 'A new version of '
                                        '${AppConfigScope.instance.appName} is '
                                        'available with improvements and bug '
                                        'fixes.',
                              textAlign: TextAlign.center,
                              style: AppTextStyle().bodyMedium.copyWith(
                                color: AppColors.primary.withOpacity(0.85),
                              ),
                            ),
                            verticalSpaceMedium,

                            /// Update Button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.5.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 11.h,
                                  ),
                                ),
                                onPressed: () =>
                                    _service.openStore(_result.storeUrl),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 34.w,
                                      height: 34.w,
                                      decoration: BoxDecoration(
                                        gradient: gradient,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.system_update_rounded,
                                        color: Colors.white,
                                        size: 18.sp,
                                      ),
                                    ),
                                    horizontalSpaceSmall,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Update Changathi App',
                                          style: AppTextStyle().titleMedium
                                              .copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                        Text(
                                          'Takes less than a minute',
                                          style: AppTextStyle().bodySmall
                                              .copyWith(
                                                color: AppColors.primary
                                                    .withOpacity(0.6),
                                                fontSize: 10.sp,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            verticalSpaceTiny,

                            /// Later button
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _softUpdateSkippedForSession = true;
                                });
                              },
                              child: Text(
                                'Maybe Later',
                                style: AppTextStyle().bodySmall.copyWith(
                                  color: AppColors.primary.withOpacity(0.5),
                                ),
                              ),
                            ),

                            /// Version tag
                            Text(
                              'Version ${_result.latestBuild} is available',
                              style: AppTextStyle().bodySmall.copyWith(
                                color: AppColors.primary.withOpacity(0.4),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
