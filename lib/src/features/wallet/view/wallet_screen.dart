import 'package:Changathi/src/features/wallet/view/sms_wallet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/features/wallet/controller/chat_plan_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/recharge_plan_controller.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/zartek_core.dart';

import '../../../app/app_text_style.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/update_gate.dart';
import 'coin_wallet_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const WalletScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  final walletIndexProvider = StateProvider<int>((ref) {
    return 0;
  });
  TabController? tabs;
  @override
  void initState() {
    super.initState();
    tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    // Pushed route: newly constructed on every visit, so this re-checks each
    // time the wallet is opened. Covers CoinWalletScreen / SmsWalletScreen too —
    // they are TabBarView children of this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(walletIndexProvider.notifier)
          .update((state) => state = widget.initialIndex);
      ref.read(walletControllerProvider.notifier).getWalletData();
      if (widget.initialIndex == 1) {
        ref.read(chatPlanControllerProvider.notifier).getChatPlan();
      }
    });
    tabs?.addListener(() {
      ref
          .read(walletIndexProvider.notifier)
          .update((state) => state = tabs?.index ?? 0);
      switch (tabs?.index ?? 0) {
        case 0:
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            ref
                .read(rechargePlanControllerProvider.notifier)
                .getRechargePlan(planType: "Coins");
          });
          break;
        case 1:
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            ref.read(chatPlanControllerProvider.notifier).getChatPlan();
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectIndex = ref.watch(walletIndexProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: GradientItems(
            child: Icon(CupertinoIcons.back, color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: Text(
          strings.t(AppStringKey.walletTitle),
          style: AppTextStyle().bodyLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            verticalSpaceMedium,
            SizedBox(
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(),

                controller: tabs,

                tabs: [
                  _buildTab("Coins", selectIndex == 0),
                  _buildTab("Messages", selectIndex == 1),
                ],
              ),
            ),
            verticalSpaceSmall,
            Expanded(
              child: TabBarView(
                controller: tabs,
                children: [CoinWalletScreen(), SmsWalletScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool selected) {
    bool isSelected = selected;
    return GradientItems(
      gradient: !isSelected,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: Colors.white, width: 2))
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle().labelSmall.copyWith(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
