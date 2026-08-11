import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi_core/kazi_core.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Total run of the animation, no loop.
  ///
  /// Shorter than `kaziMinimumSplashDurationProvider` on purpose: the screen is
  /// held past this so the finished composition — mark, word and signature
  /// together — can be read, instead of existing only on its last frame.
  static const _total = Duration(milliseconds: 1100);

  /// Word: fade + 8px rise over 0.6s, starting at 0.34s.
  static const _wordInterval = Interval(340 / 1100, 940 / 1100);

  /// Signature: the same movement, entering at 0.55s.
  ///
  /// The brandbook asks for the same 0.6s fade, which would end at 1.15s — 50ms
  /// past the total it also specifies. The fade is trimmed rather than the run
  /// extended, so the splash still clears in 1.1s.
  static const _signatureInterval = Interval(550 / 1100, 1);

  /// The distance the word and the signature travel as they fade in.
  static const _rise = 8.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final background = isDark ? KaziColors.graphite : KaziColors.yellow;
    final ink = isDark ? KaziColors.mist : KaziColors.graphite;
    final markInk = isDark ? KaziColors.yellow : KaziColors.graphite;
    final signatureInk = isDark ? KaziColors.graphite300 : KaziColors.amber700;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  KaziSvg(
                    KaziSvgAssets.logo,
                    height: KaziSizings.splashLogoHeight,
                    color: markInk,
                  ),
                  KaziSpacings.verticalMd,
                  _Entrance(
                    controller: _controller,
                    interval: _wordInterval,
                    skip: reduceMotion,
                    child: Text(
                      _wordmark,
                      style: KaziTextStyles.wordmarkAt(44).copyWith(color: ink),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: KaziInsets.xxLg),
                child: SafeArea(
                  child: _Entrance(
                    controller: _controller,
                    interval: _signatureInterval,
                    skip: reduceMotion,
                    child: Text(
                      KaziLocalizations.current.splashSignature.toUpperCase(),
                      style: KaziTextStyles.tag.copyWith(color: signatureInk),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _wordmark = 'kazi';
}

/// Fade plus an 8px rise, over the slice of the splash that owns it.
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.controller,
    required this.interval,
    required this.skip,
    required this.child,
  });

  final AnimationController controller;
  final Interval interval;
  final bool skip;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (skip) {
      return child;
    }

    final animation = CurvedAnimation(parent: controller, curve: interval);

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, _SplashPageState._rise * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}
