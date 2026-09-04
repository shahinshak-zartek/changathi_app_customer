import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/auth/controller/avatar_list_controller.dart';
import 'package:zartek_core/src/features/auth/model/avatar_model.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../util/avatar_cache.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/oops_error.dart';

List<String> avatarUrls=[
  "https://newprofilepic.photo-cdn.net//assets/images/article/profile.jpg?90af0c8",
  "https://t4.ftcdn.net/jpg/04/31/64/75/360_F_431647519_usrbQ8Z983hTYe8zgA7t1XVc5fEtqcpa.jpg",
  "https://img.freepik.com/free-photo/front-view-business-woman-suit_23-2148603018.jpg?semt=ais_hybrid&w=740&q=80"
];
Future<AvatarData?>showProfileAvatarBottomSheet(BuildContext context, {bool isEdit = false}) async {
  AvatarData? selectedAvatar;

  return await showModalBottomSheet<AvatarData>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                         Text(
                          isEdit?"Change Avatar":'Select Avatar',
                          style: AppTextStyle().bodyLarge,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
        
                   verticalSpaceMedium,
        
                    /// Avatar Grid
                    Consumer(
                      builder: (context,ref,child) {
                        var res=ref.watch(avatarListControllerProvider);
                       return res.when( loading: () => Center(child: CupertinoActivityIndicator()), success: (avatarList) {
                          precacheAvatarUrls(
                            context,
                            avatarList?.data?.map((avatar) => avatar.image_url) ?? const [],
                          );
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (avatarList?.data??[]).length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 16.sp,
                              crossAxisSpacing: 16.sp,
                            ),
                            itemBuilder: (context, index) {
                              final isSelected =
                                  avatarList?.data?[index] == selectedAvatar;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAvatar = avatarList?.data?[index];
                                  });
                                },
                                child: Container(
                                  padding:  EdgeInsets.all(3.sp),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSelected
                                        ? const LinearGradient(
                                      colors: [
                                        Palette.deepRoyalVioletBegin,
                                        Palette.deepRoyalVioletMid,
                                        Palette.deepRoyalVioletEnd
                                      ],
                                    )
                                        : null,
                                  ),
                                  child: CircleAvatar(
                                    radius: 28.sp,
                                    backgroundImage:
                                    cachedAvatarProvider(avatarList?.data?[index].image_url),
                                    backgroundColor: Colors.grey.shade200,
                                    child: (avatarList?.data?[index].image_url ?? "").trim().isEmpty
                                        ? Icon(Icons.person, color: Colors.grey.shade600)
                                        : null,
                                  ),
                                ),
                              );
                            },
                          );
                        }, error: (error) => OopsError(error: error),);

                      }
                    ),
        
                    verticalSpaceMedium,
        
                    /// Select Button
                    CustomElevatedButton(onPressed: selectedAvatar == null
                        ? null
                        : () {
                      Navigator.pop(context, selectedAvatar);
                    },
                      label: "Select",
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
