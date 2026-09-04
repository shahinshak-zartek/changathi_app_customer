import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:zartek_core/src/features/auth/model/login_add_body_model.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../app/theme.dart';
import '../../../constants/assets.dart';
import 'package:zartek_core/src/util/alert.dart';
import '../../../util/country_picker.dart';
import 'package:zartek_core/src/util/phone_number_validator.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/text_form_field_input_decoration.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/features/auth/controller/login_controller.dart';
import 'package:zartek_core/src/features/profile/controller/legal_pages_controller.dart';

import '../../../widgets/whatsapp_container.dart';
import '../widget/terms_and_condition_bottom_sheet.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const _smsChannel = 'sms';
  static const _whatsappChannel = 'whatsapp';

  final _formKey = GlobalKey<FormBuilderState>();
  String phoneCode = "91";
  String? _loadingChannel;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final loginState = ref.watch(loginControllerProvider);
    final isLoginLoading = loginState is LoginStateLoading;
    final isIndianNumber = phoneCode == "91";
    final isSmsLoading = isLoginLoading && _loadingChannel == _smsChannel;
    final isWhatsappLoading =
        isLoginLoading && _loadingChannel == _whatsappChannel;

    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next is! LoginStateLoading && _loadingChannel != null && mounted) {
        setState(() {
          _loadingChannel = null;
        });
      }
    });

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             verticalSpaceLarge,
             Image.asset(Assets.appIcon, fit: BoxFit.cover, height: 100.h),
             verticalSpaceMedium,
            Center(
              child: Text(
                strings.t(AppStringKey.welcomeBack),
                style: AppTextStyle().titleLarge,
              ),
            ),
             verticalSpaceMedium,
            Text(
              textAlign: TextAlign.center,
              strings.t(AppStringKey.enterMobileToLogin),
              style: AppTextStyle().bodyMedium,
            ),
             verticalSpaceMedium,

             Padding(
               padding: EdgeInsets.symmetric(horizontal: 25.0.w),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  Text(
                    textAlign: TextAlign.center,
                    strings.t(AppStringKey.mobileNumber),
                    style: AppTextStyle().bodyMedium,
                  ),
                   verticalSpaceSmall,
                   FormBuilder(
                     key: _formKey,
                     autovalidateMode: AutovalidateMode.onUnfocus,
                     // initialValue: {
                     //   'identification':'5710080281081',
                     //       'password':'Test123;'
                     // },
                     child: Column(
                       children: [
                         verticalSpaceSmall,

                         ///phone
                         FormBuilderTextField(
                           cursorColor: Palette.black,
                           autovalidateMode: AutovalidateMode.onUserInteraction,
                           validator: (value) => validatePhoneNumber("+$phoneCode $value"),
                           style: formBuilderTextStyle(context),
                           maxLines: 1,
                           name: 'phone',
                           decoration: buildInputDecoration(context,
                             labelColor: Colors.grey,
                             borderRadius: BorderRadius.circular(5),
                             prefixIcon: GestureDetector(
                               behavior: HitTestBehavior.opaque,
                               onTap: () => gotoCountryPicker(context, (p0) {
                                 setState(() {
                                   phoneCode = p0.phoneCode;
                                 });
                               }),
                               child: SizedBox(
                                 height: 30,
                                 child: Container(
                                   padding: const EdgeInsets.only(
                                     top: 0,
                                     right: 12,
                                   ),
                                   margin: const EdgeInsetsDirectional.only(
                                     top: 6,
                                     bottom: 6,
                                   ),
                                   decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          width: 1,
                                          color: AppColors.lightGray,
                                        ),
                                      ),
                                   ),
                                   child: Text("+$phoneCode",style: AppTextStyle().bodyMedium,
                                   ),
                                 ),
                               ),
                             ),
                             hintText: strings.t(
                               AppStringKey.enterMobileNumberHint,
                             ),
                           ),

                           keyboardType: TextInputType.number,
                           inputFormatters: [
                             FilteringTextInputFormatter.digitsOnly,
                             LengthLimitingTextInputFormatter(15),
                           ],
                           onChanged: (value) {
                             if ((value?.length ?? 0) == 15) {
                               FocusScope.of(context).unfocus();
                             }
                           },
                         ),
                         verticalSpaceMedium,
                          if (isIndianNumber)
                            CustomElevatedButton(
                              width: 300.w,
                              height: 42.h,
                              isLoading: isSmsLoading,
                              label: 'Send OTP',
                              onPressed: isLoginLoading
                                  ? null
                                  : () {
                                      submit(_smsChannel);
                                    },
                            ),
                          if (isIndianNumber) verticalSpaceSmall,
                          WhatsappContainer(
                            isLoading: isWhatsappLoading,
                            isEnabled: !isLoginLoading,
                            onTap: () {
                             submit(_whatsappChannel);
                           },
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
             ),
             if (isIndianNumber) ...[
             verticalSpaceSX,
            Text(
              textAlign: TextAlign.center,
              strings.t(AppStringKey.chooseWhatsappOtp),
              style: AppTextStyle().bodySmall,
            ),
             verticalSpaceMedium,
          ],
             verticalSpaceSX,
             Column(
               children: [
                Text(
                  textAlign: TextAlign.center,
                  strings.t(AppStringKey.byCreatingAccount),
                  style: AppTextStyle().bodySmall.copyWith(fontSize: 8.sp),
                ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                    Text(
                      textAlign: TextAlign.center,
                      strings.t(AppStringKey.toOur),
                      style: AppTextStyle().bodySmall.copyWith(
                        fontSize: 8.sp,
                      ),
                    ),
                     GestureDetector(
                       onTap: () {
                         final controller = ref.read(
                           legalPagesControllerProvider.notifier,
                         );
                         showTermsAndConditionBottomSheet(
                            context,
                            title: "Terms & Conditions",
                            legalPageFuture: controller.getLegalPagesData(
                              "customer-terms-and-conditions",
                            ),
                          );
                        },
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF4C1D95),
                              Color(0xFF8B5CF6),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            textAlign: TextAlign.center,
                            strings.t(AppStringKey.termsAndPrivacy),
                            style: AppTextStyle().bodySmall.copyWith(
                              color: AppColors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit(String channel) {
    if (_formKey.currentState?.validate() ?? false) {
      final otpChannel = phoneCode == "91" ? channel : _whatsappChannel;
      setState(() {
        _loadingChannel = otpChannel;
      });
      var data = LoginAddBodyModel(
        channel: otpChannel,
        phone:
            "+$phoneCode${_formKey.currentState?.fields['phone']?.value ?? ''}",
      );
      ref.read(loginControllerProvider.notifier).loginWithOtp(req: data);
    } else {
      final strings = ref.read(appStringsProvider);
      Alert.showToast(strings.t(AppStringKey.pleaseEnterValidDetails));
    }
  }
}
