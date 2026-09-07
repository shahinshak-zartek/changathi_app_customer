// Changathi has no SMS/messaging feature, so the wallet is Coins-only — see the
// commented Messages tab below. These imports served only that tab.
// import 'package:Changathi/src/features/wallet/view/sms_wallet_screen.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:zartek_core/src/features/wallet/controller/chat_plan_controller.dart';
// import 'package:zartek_core/src/features/wallet/controller/recharge_plan_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/features/wallet/controller/wallet_controller.dart';
import 'package:zartek_core/zartek_core.dart';

import '../../../app/app_text_style.dart';
import '../../../app/palette.dart';
// verticalSpaceMedium / verticalSpaceSmall framed the tab strip.
// import '../../../util/ui_helper.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/update_gate.dart';
import 'coin_wallet_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const WalletScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

// SingleTickerProviderStateMixin supplied `vsync` for the TabController — needed
// again if the Messages tab returns.
class _WalletScreenState extends ConsumerState<WalletScreen> {
  // Tracked which tab was selected, purely to highlight it in the TabBar.
  // final walletIndexProvider = StateProvider<int>((ref) {
  //   return 0;
  // });
  // TabController? tabs;
  @override
  void initState() {
    super.initState();
    // tabs = TabController(
    //   length: 2,
    //   vsync: this,
    //   initialIndex: widget.initialIndex,
    // );
    // Pushed route: newly constructed on every visit, so this re-checks each
    // time the wallet is opened. Covers CoinWalletScreen / SmsWalletScreen too —
    // they are TabBarView children of this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateGate.checkForUpdate(context);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(walletControllerProvider.notifier).getWalletData();
      // Selected-tab tracking and the chat-plan prefetch for initialIndex == 1
      // went with the Messages tab.
      // ref
      //     .read(walletIndexProvider.notifier)
      //     .update((state) => state = widget.initialIndex);
      // if (widget.initialIndex == 1) {
      //   ref.read(chatPlanControllerProvider.notifier).getChatPlan();
      // }
    });
    // Refetched a tab's plans when you switched back to it. Not needed with one
    // tab, and not load-bearing for the coin list either way: the core
    // RechargePlanController calls getRechargePlan('Coins') in its own build(),
    // so CoinWalletScreen's ref.watch triggers the fetch.
    // tabs?.addListener(() {
    //   ref
    //       .read(walletIndexProvider.notifier)
    //       .update((state) => state = tabs?.index ?? 0);
    //   switch (tabs?.index ?? 0) {
    //     case 0:
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         ref
    //             .read(rechargePlanControllerProvider.notifier)
    //             .getRechargePlan(planType: "Coins");
    //       });
    //       break;
    //     case 1:
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         ref.read(chatPlanControllerProvider.notifier).getChatPlan();
    //       });
    //       break;
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final selectIndex = ref.watch(walletIndexProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: Palette.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
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
      // Coins is the only wallet section. The tab strip and its Column wrapper
      // are gone rather than left as a single-tab bar — CoinWalletScreen is its
      // own Scaffold and opens with verticalSpaceSmall, so this keeps the
      // content tight under the title bar instead of leaving the tab strip's gap.
      //
      // To restore Messages: bring back the Column below with its TabBar and
      // TabBarView, _buildTab(), the TabController and its listener, the
      // walletIndexProvider, and the imports at the top of the file.
      body: SafeArea(child: CoinWalletScreen()),
      // body: SafeArea(
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       verticalSpaceMedium,
      //       SizedBox(
      //         child: TabBar(
      //           dividerColor: Colors.transparent,
      //           indicator: BoxDecoration(),
      //           controller: tabs,
      //           tabs: [
      //             _buildTab("Coins", selectIndex == 0),
      //             _buildTab("Messages", selectIndex == 1),
      //           ],
      //         ),
      //       ),
      //       verticalSpaceSmall,
      //       Expanded(
      //         child: TabBarView(
      //           controller: tabs,
      //           children: [CoinWalletScreen(), SmsWalletScreen()],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // Rendered one label in the TabBar above.
  // Widget _buildTab(String label, bool selected) {
  //   bool isSelected = selected;
  //   return GradientItems(
  //     gradient: !isSelected,
  //     child: Container(
  //       padding: const EdgeInsets.all(8.0),
  //       decoration: BoxDecoration(
  //         border: isSelected
  //             ? Border(bottom: BorderSide(color: Colors.white, width: 2))
  //             : null,
  //       ),
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: AppTextStyle().labelSmall.copyWith(
  //             color: Colors.white,
  //             fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
