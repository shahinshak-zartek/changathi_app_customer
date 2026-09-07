import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zartek_core/src/features/wallet/controller/payment_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/payment_gateway_controller.dart';
import 'package:zartek_core/src/util/navigation_service.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
import '../../../constants/assets.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';

/// Fetches the active gateways then opens the payment sheet. Falls back to
/// Razorpay if the gateway list can't be loaded, so a plan tap always proceeds.
Future<void> proceedToPayment(
  BuildContext context,
  WidgetRef ref, {
  bool isSms = false,
  required int amount,
  required String planId,
}) async {
  List<String> gateways;
  try {
    gateways = await ref.read(activeGatewaysProvider.future);
  } catch (_) {
    gateways = [PaymentGateways.razorpay];
  }
  if (gateways.isEmpty) gateways = [PaymentGateways.razorpay];
  if (!context.mounted) return;
  await showPaymentProceedBottomSheet(
    context,
    isSms: isSms,
    amount: amount,
    planId: planId,
    enabledGateways: gateways,
  );
}

showPaymentProceedBottomSheet(
  BuildContext context, {
  bool isSms = false,
  required int amount,
  required String planId,
  required List<String> enabledGateways,
}) async {
  final gateways =
      enabledGateways.isEmpty ? [PaymentGateways.razorpay] : enabledGateways;
  return await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return _PaymentProceedSheet(
        isSms: isSms,
        amount: amount,
        planId: planId,
        enabledGateways: gateways,
      );
    },
  );
}

class _PaymentProceedSheet extends ConsumerStatefulWidget {
  const _PaymentProceedSheet({
    required this.isSms,
    required this.amount,
    required this.planId,
    required this.enabledGateways,
  });

  final bool isSms;
  final int amount;
  final String planId;
  final List<String> enabledGateways;

  @override
  ConsumerState<_PaymentProceedSheet> createState() =>
      _PaymentProceedSheetState();
}

class _PaymentProceedSheetState extends ConsumerState<_PaymentProceedSheet> {
  late String _selectedGateway = widget.enabledGateways.first;

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentControllerProvider, (previous, next) {
      next.whenOrNull(
        success: () {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Payment successful");
        },
        error: (message) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: message);
        },
      );
    });

    final paymentState = ref.watch(paymentControllerProvider);
    final isLoading =
        paymentState.maybeWhen(loading: () => true, orElse: () => false);
    final hasMultiple = widget.enabledGateways.length > 1;

    return SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  horizontalSpaceSmall,
                  Text(
                    'Confirm Payment',
                    style: AppTextStyle().titleMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!isLoading) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),

              verticalSpaceMedium,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.isSms ? "SMS" : "Coin"} Recharge Package',
                    style: AppTextStyle().bodyMedium,
                  ),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: AppTextStyle().titleMedium,
                  ),
                ],
              ),
              verticalSpaceSmall,

              /// Payment method selection
              if (hasMultiple) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Method:',
                    style: AppTextStyle().bodyMedium,
                  ),
                ),
                verticalSpaceSmall,
                ...widget.enabledGateways.map(
                  (gateway) => _GatewayOption(
                    gateway: gateway,
                    selected: _selectedGateway == gateway,
                    onTap: isLoading
                        ? null
                        : () => setState(() => _selectedGateway = gateway),
                  ),
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Method:',
                      style: AppTextStyle().bodyMedium,
                    ),
                    _gatewayLogo(_selectedGateway),
                  ],
                ),

              verticalSpaceSmall,
              Text(
                'By proceeding, you agree to the payment\nterms and conditions.',
                style: AppTextStyle().bodySmall,
                textAlign: TextAlign.center,
              ),
              verticalSpaceMedium,

              /// Select Button
              paymentState.maybeWhen(
                loading: () => const Center(child: CupertinoActivityIndicator()),
                orElse: () => CustomElevatedButton(
                  onPressed: () {
                    ref.read(paymentControllerProvider.notifier).startPayment(
                          planId: widget.planId,
                          isChatPlan: widget.isSms,
                          gateway: _selectedGateway,
                        );
                  },
                  label: "Pay Securely ₹${widget.amount.toStringAsFixed(2)}",
                ),
              ),
              verticalSpaceSmall,
              GradientItems(
                child: CustomElevatedButton(
                  onPressed: () {
                    if (!isLoading) {
                      NavigationService.pop();
                    }
                  },
                  color: Colors.transparent,
                  nosShadow: true,
                  borderSide: const BorderSide(color: Colors.white),
                  label: "Cancel",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A selectable payment-gateway tile shown when more than one gateway is
/// enabled.
class _GatewayOption extends StatelessWidget {
  const _GatewayOption({
    required this.gateway,
    required this.selected,
    required this.onTap,
  });

  final String gateway;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                selected ? Palette.deepRoyalPinkBegin : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? Palette.deepRoyalPinkBegin : Colors.grey,
              size: 20.sp,
            ),
            horizontalSpaceSmall,
            _gatewayLogo(gateway),
          ],
        ),
      ),
    );
  }
}

Widget _gatewayLogo(String gateway) {
  switch (gateway) {
    case PaymentGateways.cashfree:
      return Image.asset(Assets.cashfree, width: 80.w, height: 25.h);
    case PaymentGateways.razorpay:
    default:
      return Image.asset(Assets.razorpay, width: 80.w, height: 25.h);
  }
}
