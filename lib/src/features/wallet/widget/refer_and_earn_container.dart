import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zartek_core/src/features/profile/repository/profile_repository.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/src/util/alert.dart';
import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/oops_error.dart';

class ReferAndEarnContainer extends ConsumerWidget {
  const ReferAndEarnContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = ref.watch(walletControllerProvider);

    return res.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error) => OopsError(error: error),
      success: (wallet) {
        final fullCode = wallet?.data?.referral_code ?? "";

        return SizedBox(
          width: getWidth(context: context) * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Refer and Earn", style: AppTextStyle().titleMedium),
              Row(
                children: [
                  SvgPicture.asset(Assets.coin, width: 20.w, height: 20.h),
                  Text(" Get bonus coins for each referral",style: AppTextStyle().bodySmall,)
                ],
              ),
              verticalSpaceTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: getWidth(context: context) * 0.63,
                    padding: EdgeInsets.all(5.sp),
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.sp),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4.0.w),
                          child: Text(
                            fullCode,
                            style: AppTextStyle().bodyMedium.copyWith(
                              color: const Color(0xff0088FF),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(fullCode),
                          icon: GradientItems(
                            child: Icon(Icons.copy, size: 16.sp, color: Colors.white,),
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _shareReferral(ref, fullCode),
                    child: Container(
                      height: 60.h,
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.sp),
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
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Alert.showToast("Copied to clipboard");
  }

  Future<void> _shareReferral(WidgetRef ref, String fullCode) async {
    String? androidLink;
    String? iosLink;
    try {
      final links = await ref.read(profileRepoProvider).getStoreLinks();
      androidLink = links.playStore;
      iosLink = links.appStore;
    } catch (_) {
      // fall through — share whatever we have (possibly empty links)
    }

    final buffer = StringBuffer()
      ..writeln('Use my referral code for Changathi App!')
      ..writeln('referral code 🎁:')
      ..writeln()
      ..writeln(fullCode)
      ..writeln()
      ..writeln('Install Changathi App! 📲');
    if (androidLink != null && androidLink.isNotEmpty) {
      buffer.writeln('Android: $androidLink');
    }
    if (iosLink != null && iosLink.isNotEmpty) {
      buffer.writeln('iOS: $iosLink');
    }

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }
}