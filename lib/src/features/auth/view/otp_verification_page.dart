
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/app/app_routes.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';
import 'package:zartek_core/src/util/alert.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../app/theme_x.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'package:zartek_core/src/features/auth/controller/login_controller.dart';
import 'package:zartek_core/src/features/auth/controller/otp_controller.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:pinput/pinput.dart';

import 'package:zartek_core/src/features/auth/model/login_add_body_model.dart';
class OtpVerificationPage extends ConsumerStatefulWidget {
  final LoginAddBodyModel loginAddBodyModel;
  final int initialResendAvailableInSeconds;
  const OtpVerificationPage({super.key,required this.loginAddBodyModel, required this.initialResendAvailableInSeconds});

  @override
  ConsumerState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {

  late OTPController otpController;
  String otpCode = '';
  final FocusNode focusNode = FocusNode();

  /// Owned explicitly so the field can be cleared on resend. Without passing a
  /// controller, Pinput creates its own internally and the entered digits stay
  /// on screen no matter what this State does.
  final TextEditingController pinController = TextEditingController();
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    otpController = ref.read(oTPControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      otpController.startCounter(seconds: widget.initialResendAvailableInSeconds);
    });
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(oTPControllerProvider);
    final otpCounter = ref.watch(otpCounterProvider);
    final strings = ref.watch(appStringsProvider);
    final canResend = otpCounter == "00:00" && !_isResending;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToLogin();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToLogin,
          ),
        ),

        body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Center(
            child: Text(
              strings.t(AppStringKey.otpVerification),
              style: AppTextStyle().titleLarge,
            ),
          ),
          verticalSpaceMedium,
          Text(
            textAlign: TextAlign.center,
            strings.t(AppStringKey.enterOtpSent),
            style: AppTextStyle().bodyMedium,
          ),
          Text(textAlign: TextAlign.center,widget.loginAddBodyModel.phone,style: AppTextStyle().titleMedium.copyWith(color:AppColors.black ),),
          verticalSpaceMedium,
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 25.0.w),
            child: Column(

              children: [
                verticalSpaceSmall,

                Pinput(
                  controller: pinController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  length: 5,
                  submittedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: context.bodyLarge().copyWith(color: Palette.fontDark),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: Palette.deepRoyalVioletMid,width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: context.bodyLarge().copyWith(color: Palette.fontDark),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: Palette.deepRoyalVioletMid,width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: context.bodyLarge().copyWith(color: Palette.fontDark),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: Color(0xffDEE1E6)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  onCompleted: (pin) {
                    otpCode = pin;
                    setState(() {});

                  },
                  onChanged: (pin) {
                    otpCode = pin;
                    setState(() {});
                  },
                ),
                verticalSpaceMedium,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: canResend ? 1 : 0.45,
                      child: InkWell(
                        onTap: canResend ? resend : null,
                        child: otpCounter=="00:00"?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              strings.t(AppStringKey.didntReceiveCode),
                              style: AppTextStyle().bodySmall,
                            ),
                          ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFF4B4B),
                                  Color(0xFF8B5CF6),
                                ],
                              ).createShader(bounds),
                              child:  Text(
                                _isResending
                                    ? 'Resending...'
                                    : strings.t(AppStringKey.resend),
                                style: AppTextStyle().titleSmall.copyWith(color: Colors.white),
                              ),
                          ),

                          ],
                        ):Text(
                          'Resend OTP in $otpCounter',
                          style: context
                              .bodySmall()
                              .copyWith(color: AppColors.primary,),
                        ),
                      ),
                    ),
                  ],
                ),

                verticalSpaceMedium,
                Consumer(
                  builder: (context, ref, child) {
                    final state =
                    ref.watch(loginControllerProvider);
                    final isLoading = state is LoginStateLoading;



                    return CustomElevatedButton(

                      isLoading: isLoading,
                      label: strings.t(AppStringKey.verify),
                      onPressed: verify
                    );
                  },
                ),

              ],
            ),
          ),
        ],
        )),

      ),
    );
  }
  void verify() {
    if (otpCode.length == 5) {
      Map data={
        "phone": widget.loginAddBodyModel.phone,
        "otp": otpCode,
        "role":"customer",
        // // todo make it dynamic
        // "referral_code": "e69227bf-8747-4df3-a99b-25bbb080fd44"
      };
      ref.read(loginControllerProvider.notifier).verifyLoginOtp(req: data);
    }
    else {
      final strings = ref.read(appStringsProvider);
      Alert.showErrorToast(strings.t(AppStringKey.pleaseEnterValidOtp));
    }
  }
  Future<void> resend() async {
    setState(() {
      _isResending = true;
      // Clear on tap, not on success: the moment a new code is requested the
      // typed one is being abandoned, and clearing immediately is the feedback
      // that the tap registered.
      pinController.clear();
      otpCode = '';
    });
    focusNode.requestFocus();
    final seconds = await ref.read(loginControllerProvider.notifier).resendOtp(req: widget.loginAddBodyModel);
    if (!mounted) return;
    setState(() {
      _isResending = false;
    });
    if (seconds != null) {
      otpController.startCounter(seconds: seconds);
    }
  }

  void _goBackToLogin() {
    NavigationService.pushReplacementAll(page: AppRoutes.login);
  }

}
