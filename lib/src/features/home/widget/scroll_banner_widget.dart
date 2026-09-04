import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';

class AutoScrollBanner extends StatefulWidget {
  final List items;

  const AutoScrollBanner({super.key, required this.items});

  @override
  State<AutoScrollBanner> createState() => _AutoScrollBannerState();
}

class _AutoScrollBannerState extends State<AutoScrollBanner> {
  late final PageController _pageController;
  late int _currentPage;
  late final int itemCount;
  Timer? _timer;

  static const int _virtualCount = 10000;

  @override
  void initState() {
    super.initState();
    itemCount = widget.items.length;
    _currentPage = _virtualCount ~/ 2;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );

    if (itemCount > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: PageView.builder(
        controller: _pageController,
        itemCount: itemCount > 1 ? _virtualCount : itemCount,
        itemBuilder: (context, index) {
          final item = widget.items[index % itemCount];
          return Container(
            padding: EdgeInsets.all(10.sp),
            margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Palette.lightRoyalVioletBegin,
                  Palette.lightRoyalVioletMid,
                  Palette.lightRoyalVioletEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(Assets.sparkles, width: 16.w, height: 16.h),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        item?.title ?? "Invite Friends & Earn Coins",
                        style: AppTextStyle().titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  item?.description ?? "Share your referral code with friends and earn coins when they join and complete their registration.",
                  style: AppTextStyle().bodyMedium.copyWith(color: Palette.black, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}