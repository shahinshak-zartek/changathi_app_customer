import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/core/model/auth_user.dart';
import 'package:zartek_core/src/util/alert.dart';
import 'package:zartek_core/src/features/auth/model/avatar_model.dart';
import 'package:zartek_core/src/features/profile/controller/profile_controller.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import '../../../util/avatar_cache.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';
import '../../auth/widget/profile_avatar_bottom_sheet.dart';

class ProfileAvatarUpdate extends StatefulWidget {
  final UserData? userData;
  const ProfileAvatarUpdate({super.key, required this.userData});

  @override
  State<ProfileAvatarUpdate> createState() => _ProfileAvatarUpdateState();
}

class _ProfileAvatarUpdateState extends State<ProfileAvatarUpdate> {
  AvatarData? selectedAvatar;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData?.name ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasNameChanged {
    return _nameController.text.trim() != (widget.userData?.name ?? "").trim();
  }

  bool get _hasAvatarChanged => selectedAvatar != null;

  Future<void> _saveChanges(WidgetRef ref) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Alert.showErrorToast("Name cannot be empty");
      return;
    }
    if (newName.length < 2) {
      Alert.showErrorToast("Name must be at least 2 characters");
      return;
    }
    if (RegExp(r'[0-9]').hasMatch(newName)) {
      Alert.showErrorToast("Name cannot contain numbers");
      return;
    }

    if (!_hasNameChanged && !_hasAvatarChanged) {
      Alert.showErrorToast("No changes to save");
      return;
    }

    final controller = ref.read(profileControllerProvider.notifier);

    if (_hasNameChanged) {
      final success = await controller.updateUserNickName(
        newName: newName,
        popOnSuccess: false,
      );
      if (!success) {
        return;
      }
    }

    if (_hasAvatarChanged) {
      final success = await controller.updateUserAvatar(
        avatarId: selectedAvatar?.id ?? "",
        popOnSuccess: false,
      );
      if (!success) {
        return;
      }
    }

    if (mounted) {
      NavigationService.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: GradientItems(
            child: Icon(CupertinoIcons.back, color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: Consumer(
          builder: (context, ref, _) {
            final strings = ref.watch(appStringsProvider);
            return Text(
              strings.t(AppStringKey.profileTitle),
              style: AppTextStyle().bodyMedium,
            );
          },
        ),
      ),
      body: SizedBox(

        width: getWidth(context: context),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            verticalSpaceMedium,
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Palette.deepRoyalPinkBegin,
                    Palette.deepRoyalVioletMid,
                    Palette.deepSkyBlueEnd,
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 35.w,
                backgroundColor: Colors.transparent,
                backgroundImage: cachedAvatarProvider(
                  selectedAvatar?.image_url ??
                      widget.userData?.avatar_data?.image_url,
                ),
                child: (selectedAvatar?.image_url ??
                            widget.userData?.avatar_data?.image_url ??
                            "")
                        .trim()
                        .isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade600)
                    : null,
              ),
            ),
            verticalSpaceSmall,
            Text(
              _nameController.text.trim().isEmpty
                  ? (widget.userData?.name ?? "")
                  : _nameController.text.trim(),
              style: AppTextStyle().titleMedium,
            ),
            verticalSpaceSmall,
            Text(
              widget.userData?.phone ?? "",
              style: AppTextStyle().bodyMedium.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            verticalSpaceLarge,
            GradientItems(
              child: CustomElevatedButton(
                onPressed: () async {
                  final avatar = await showProfileAvatarBottomSheet(context);

                  if (avatar != null) {
                    setState(() {
                      selectedAvatar = avatar;
                    });
                  }
                },
                icon: Icon(CupertinoIcons.person, color: Colors.white),
                color: Colors.transparent,
                nosShadow: true,
                borderSide: BorderSide(color: Colors.white),
                label: "Change Avatar",
              ),
            ),
            // verticalSpaceMedium,
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 30.w),
            //   child: TextFormField(
            //     controller: _nameController,
            //     onChanged: (_) => setState(() {}),
            //     textInputAction: TextInputAction.done,
            //     decoration: buildInputDecoration(
            //       context,
            //       labelColor: AppColors.primaryBlend,
            //       borderRadius: BorderRadius.circular(10),
            //       labelText: 'Name',
            //       borderColor: AppColors.primaryBlend,
            //       borderThickness: 1
            //     ),
            //   ),
            // ),
            verticalSpaceMedium,
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(profileControllerProvider);
                final isLoading = state is ProfileStateLoading;
                final canSave = _hasAvatarChanged || _hasNameChanged;
                return CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: !canSave ? null : () => _saveChanges(ref),
                  label: "Save Changes",
                );
              },
            ),

            // Align(
            //     alignment: Alignment.centerRight,
            //     child: Transform.translate(
            //         offset:  Offset(45, 50),
            //         child: FloatingActionButton(
            //           onPressed: Get.back,
            //           elevation: 0,
            //           backgroundColor: AppColors.primary,
            //           child:  Icon(Icons.arrow_back_ios_new),
            //         )))
          ],
        ),
      ),
    );
  }
}
