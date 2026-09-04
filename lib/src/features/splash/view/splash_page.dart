
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../app/app_text_style.dart';
import '../../../constants/assets.dart';
import 'package:zartek_core/src/util/alert.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/linear_gradient.dart';
import 'package:zartek_core/src/features/splash/controllers/splash_controller.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool _didPrecacheSplashAssets = false;
  bool _didStartSplashFlow = false;
  bool _didNavigate = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didStartSplashFlow) return;
      _didStartSplashFlow = true;
      ref.read(splashControllerProvider.notifier).initialize();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecacheSplashAssets) {
      _didPrecacheSplashAssets = true;
      precacheImage(AssetImage(Assets.appIcon), context);
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(
        splashControllerProvider, (_, state) => _handleSplashState(state));

    return Scaffold(
        body: CustomGradient(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                horizontalSpaceSX,
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
          
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            Image.asset(
                              Assets.appIcon,
                              fit: BoxFit.cover,
                              height: 140,
                            ),


                            // verticalSpaceMedium,
                            // isLoading ? const CupertinoActivityIndicator(color: Colors.black,) : Container()
                          ],
                        ),
                      ),
                    ),
                    verticalSpaceMedium,
                    Text("Nizhal",style: AppTextStyle().titleLarge.copyWith(color: Colors.white),),
                    // verticalSpaceLarge,
                    // isLoading ? Column(
                    //   children: [
                    //     const CupertinoActivityIndicator(color: Colors.white,),
                    //     verticalSpaceSmall,
                    //     Text(textAlign: TextAlign.center,"Loading...",style: AppTextStyle().bodySmall.copyWith(color: Colors.white),),
                    //   ],
                    // ) : Container()
                  ],
                ),
          
              ],
            ),
          ),
        ));
  }

  _handleSplashState(AsyncValue state) {
    if (state is AsyncData) {
      final route = state.value;
      if (_didNavigate || route is! String) return;
      _didNavigate = true;
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
      NavigationService.pushReplacementAll(page: route);
    } else if (state is AsyncError) {
      Alert.showErrorToast(state.error.toString());
    }
  }
}
