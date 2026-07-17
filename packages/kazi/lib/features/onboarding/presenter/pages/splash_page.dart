import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kazi/core/constants/app_assets.dart';
import 'package:kazi_core/kazi_core.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final containerAnimationDuration = const Duration(milliseconds: 1000);
  final opacityAnimationDuration = const Duration(milliseconds: 1100);
  final delayToInitAnimation = const Duration(milliseconds: 1000);

  bool showText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
  }

  Future<void> _initAnimation() async {
    await Future.delayed(delayToInitAnimation);
    if (mounted) {
      setState(() => showText = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorsScheme.primary,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(AppAssets.logo, height: 55),
            AnimatedContainer(
              duration: containerAnimationDuration,
              height: KaziInsets.xxxLg,
              width: showText ? context.width * 0.19 : 0,
              child: Center(
                child: AnimatedOpacity(
                  duration: opacityAnimationDuration,
                  opacity: showText ? 1 : 0,
                  child: Text(
                    'Kazi',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: context.colorsScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 36,
                    ),
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
