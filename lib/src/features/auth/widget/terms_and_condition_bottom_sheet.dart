import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/profile/model/legal_page_detail_model.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../util/ui_helper.dart';

showTermsAndConditionBottomSheet(
  BuildContext context, {
  String title = "Terms & Condition",
  String content = "",
  Future<LegalPageDetailModel?>? legalPageFuture,
}) {
  showModalBottomSheet(
    scrollControlDisabledMaxHeightRatio: getHeight(context: context),
    backgroundColor: Colors.transparent,
    isDismissible: false,
    useSafeArea: true,
    // barrierColor: Colors.black.withOpacity(0.8),

    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    enableDrag: false,
    context: context,
    builder: (context) => SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: SizedBox(
          width: getWidth(context: context),
      
          child: Stack(
            children: [
              Container(
                width: getWidth(context: context),
                height: getHeight(context: context) * 0.8,
      
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: getHeight(context: context) * 0.8,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // verticalSpaceMedium,
                            // SizedBox(
                            //   width: getWidth(context: context) * 0.9,
                            //   child: Center(
                            //     child: Text(
                            //       title,
                            //       style: AppTextStyle().labelLarge,
                            //     ),
                            //   ),
                            // ),
                            verticalSpaceMedium,
                            SizedBox(
                              width: getWidth(context: context) * 0.9,
                              child: _TermsContent(
                                content: content,
                                legalPageFuture: legalPageFuture,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 15,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () => NavigationService.pop(),
                    child: Container(
                      padding: EdgeInsets.all(5.sp),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 3), // vertical shadow
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, color: Palette.black, size: 16.sp,),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _TermsContent extends StatelessWidget {
  const _TermsContent({
    required this.content,
    this.legalPageFuture,
  });

  final String content;
  final Future<LegalPageDetailModel?>? legalPageFuture;

  @override
  Widget build(BuildContext context) {
    final future = legalPageFuture;
    if (future == null) {
      return Text(
        content.isNotEmpty
            ? content
            : "Terms & Conditions are currently unavailable.",
        style: AppTextStyle().bodySmall,
      );
    }

    return FutureBuilder<LegalPageDetailModel?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: getHeight(context: context) * 0.55,
            child: const Center(child: CupertinoActivityIndicator()),
          );
        }

        final legalContent = snapshot.data?.data?.content ?? content;
        return Text(
          legalContent.isNotEmpty
              ? legalContent
              : "Terms & Conditions are currently unavailable.",
          style: AppTextStyle().bodySmall,
        );
      },
    );
  }
}
