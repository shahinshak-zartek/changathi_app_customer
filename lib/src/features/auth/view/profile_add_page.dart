import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zartek_core/src/features/auth/model/avatar_model.dart';
import 'package:zartek_core/src/features/auth/model/user_model.dart';
import 'package:zartek_core/src/features/profile/controller/legal_pages_controller.dart';
import '../../../app/app_text_style.dart';
import 'package:zartek_core/src/util/alert.dart';
import '../../../app/theme.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/text_form_field_input_decoration.dart';
import 'package:zartek_core/src/features/auth/controller/avatar_list_controller.dart';
import 'package:zartek_core/src/features/auth/controller/login_controller.dart';
import '../widget/profile_avatar_bottom_sheet.dart';
import '../widget/terms_and_condition_bottom_sheet.dart';

class ProfileAddPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  const ProfileAddPage({super.key, required this.phoneNumber});

  @override
  ConsumerState<ProfileAddPage> createState() => _ProfileAddPageState();
}

class _ProfileAddPageState extends ConsumerState<ProfileAddPage> {
  String? selectedGender;
  String? avatarError;
  String? genderError;
  final _formKey = GlobalKey<FormBuilderState>();
  AvatarData? selectedAvatar;

  void _selectDefaultAvatar(AvatarModel? avatarList) {
    if (selectedAvatar != null) return;
    final firstAvatar = avatarList?.data?.isNotEmpty == true
        ? avatarList!.data!.first
        : null;
    if (firstAvatar == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || selectedAvatar != null) return;
      setState(() {
        selectedAvatar = firstAvatar;
        avatarError = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(avatarListControllerProvider).whenOrNull(
      success: _selectDefaultAvatar,
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10.sp),
          width: getWidth(context: context),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,

              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                verticalSpaceMedium,
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final avatar = await showProfileAvatarBottomSheet(context);

                                if (avatar != null) {
                                  setState(() {
                                    selectedAvatar = avatar;
                                    avatarError = null;
                                  });
                                }
                              },
                              child: Container(
                                width: 100.w,
                                height: 100.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border: Border.all(
                                    color: avatarError != null ? Colors.red : Colors.grey,
                                  ),
                                  shape: BoxShape.circle,
                                  image: selectedAvatar == null
                                      ? null
                                      : DecorationImage(
                                    image: cachedAvatarProvider(selectedAvatar?.image_url)!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: selectedAvatar == null
                                    ? Icon(
                                  Icons.person_add_alt_1_outlined,
                                  size: 40.sp,
                                  color: Colors.grey,
                                )
                                    : const SizedBox(),
                              ),
                            ),
                            // SvgPicture.asset(Assets.camera, width: 25, height: 25),
                          ],
                        ),

                        /// Avatar Error
                        if (avatarError != null)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              avatarError!,
                              style: TextStyle(color: Colors.red, fontSize: 12.sp),
                            ),
                          ),
                      ],
                    ),
                    // SvgPicture.asset(Assets.camera, width: 25, height: 25),
                  ],
                ),
                verticalSpaceMedium,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Upload Avatar", style: AppTextStyle().titleLarge),
                  ],
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.phoneNumber, style: AppTextStyle().titleMedium),
                  ],
                ),
                FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      verticalSpaceMedium,

                      ///Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: AppTextStyle().bodyMedium,
                          ),
                          verticalSpaceSX,
                          FormBuilderTextField(
                            style: formBuilderTextStyle(context),
                            maxLines: 1,
                            name: 'name',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'),
                              ),
                            ],
                            decoration: buildInputDecoration(
                              labelColor: Colors.grey,
                              context,
                              borderRadius: BorderRadius.circular(5),
                              labelText: 'Name',
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Name is required',
                              ),
                              FormBuilderValidators.minLength(
                                2,
                                errorText: 'Name must be at least 2 characters',
                              ),
                              FormBuilderValidators.match(
                                RegExp(r'^[a-zA-Z\s]+$'),
                                errorText: 'Only alphabets are allowed',
                              ),
                              FormBuilderValidators.maxLength(
                                25,
                                errorText: 'Name must be less than 25 characters',
                              ),
                            ]),
                            keyboardType: TextInputType.text,
                          ),
                        ],
                      ),
                      verticalSpaceSX,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Select Gender", style: AppTextStyle().bodyMedium),
                              Text(
                                " *",
                                style: AppTextStyle().bodyMedium.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          verticalSpaceSX,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: genderError != null
                                    ? Colors.red
                                    : Color(0xffECECEC),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: Text("Select Gender",style: AppTextStyle().bodyMedium.copyWith(color: Colors.grey),),
                                value: selectedGender,
                                isExpanded: true,
                                items:  [
                                  DropdownMenuItem(value: 'Male', child: Text('Male',style: AppTextStyle().bodyMedium,)),
                                  DropdownMenuItem(value: 'Female', child: Text('Female',style: AppTextStyle().bodyMedium,)),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                    genderError = null;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (genderError != null)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h, left: 12.w),
                              child: Text(
                                genderError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                      verticalSpaceSX,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Referral code (optional)",
                            style: AppTextStyle().bodyMedium,
                          ),
                          verticalSpaceSX,
                          FormBuilderTextField(
                            style: formBuilderTextStyle(context),
                            maxLines: 1,
                            name: 'code',
                            decoration: buildInputDecoration(
                              labelColor: Colors.grey,
                              context,
                              borderRadius: BorderRadius.circular(5),
                              labelText: 'Code',
                            ),
                            validator: (_) => null,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                      verticalSpaceSX,
                      verticalSpaceMedium,
                      Column(
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            "By clicking continue, you agree to the",
                            style: AppTextStyle().bodySmall.copyWith(fontSize: 8.sp),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final controller = ref.read(
                                    legalPagesControllerProvider.notifier,
                                  );
                                  showTermsAndConditionBottomSheet(
                                    context,
                                    title: "Terms & Conditions",
                                    legalPageFuture: controller.getLegalPagesData(
                                      "agent-terms-and-conditions",
                                    ),
                                  );
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      Color(0xFFd72ebe),
                                      Color(0xFFa31cc5),
                                      Color(0xFF2a6dcc),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    " Terms & Conditions",
                                    style: AppTextStyle().bodySmall.copyWith(
                                      color: AppColors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.white,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                " and ",
                                style: AppTextStyle().bodySmall.copyWith(fontSize: 8.sp),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final controller = ref.read(
                                    legalPagesControllerProvider.notifier,
                                  );
                                  showTermsAndConditionBottomSheet(
                                    context,
                                    title: "Child Safety Policy",
                                    legalPageFuture: controller.getLegalPagesData(
                                      "child-safety-policy",
                                    ),
                                  );
                                },
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [
                                      Color(0xFFd72ebe),
                                      Color(0xFFa31cc5),
                                      Color(0xFF2a6dcc),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    " Child Safety Policy",
                                    style: AppTextStyle().bodySmall.copyWith(
                                      color: AppColors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.white,
                                      fontSize: 8.sp,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      verticalSpaceMedium,
                      Consumer(
                        builder: (context, ref, child) {
                          return Center(
                            child: Consumer(
                              builder: (context,ref,child) {
                                final state =
                                ref.watch(loginControllerProvider);
                                final isLoading = state is LoginStateLoading;
                                return CustomElevatedButton(
                                  isLoading: isLoading,
                                  label: 'Continue',
                                  onPressed: () {
                                    /// Avatar Validation
                                    if (selectedAvatar == null) {
                                      setState(() {
                                        avatarError = "Please select an profile avatar";
                                      });
                                      return;
                                    }
                                    if (selectedGender == null) {
                                      setState(() {
                                        genderError = "Gender is mandatory";
                                      });
                                      Alert.showErrorToast("Gender is mandatory");
                                      return;
                                    }
                                    if ((_formKey.currentState?.validate() ?? false )) {
                                      var res = UserModel(
                                          name: _formKey.currentState
                                              ?.fields['name']?.value ?? '',
                                        referral_code:
                                        (_formKey.currentState?.fields['code']?.value as String?)
                                            ?.isEmpty ?? true
                                            ? null : _formKey.currentState
                                            ?.fields['code']?.value,
                                        gender: selectedGender,
                                        avatar_id: selectedAvatar?.id??"",
                                      );
                                      ref.read(loginControllerProvider.notifier).addUserDetail(req: res);
                                    }
                                    else {
                                      Alert.showErrorToast('Please Enter Valid Details');
                                    }
                                  },
                                );
                              }
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
