import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kazi/app/models/app_user.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/core/constants/app_assets.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/injector_container.dart';
import 'package:kazi_core/kazi_core.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final containerAnimationDuration = const Duration(milliseconds: 1000);
  final opacityAnimationDuration = const Duration(milliseconds: 1100);
  final minimumSplashTime = const Duration(milliseconds: 3500);
  final delayToInitAnimation = const Duration(milliseconds: 1000);

  //late Timer timer;

  bool showText = false;
  bool canNavigate = false;

  // @override
  // void initState() {
  //   timer = Timer(minimumSplashTime, () => canNavigate = true);
  //   WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
  //   super.initState();
  // }

  // Future<void> _initAnimation() async {
  //   await Future.delayed(
  //     delayToInitAnimation,
  //     () => setState(() => showText = true),
  //   );
  // }

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
