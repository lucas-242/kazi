// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:kazi_companies/core/routes/routes.dart';
// import 'package:kazi_core/kazi_core.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   final containerAnimationDuration = const Duration(milliseconds: 1000);
//   final opacityAnimationDuration = const Duration(milliseconds: 1100);
//   final minimumSplashTime = const Duration(milliseconds: 3500);
//   final delayToInitAnimation = const Duration(milliseconds: 1000);

//   late Timer timer;

//   bool showText = false;
//   bool canNavigate = false;

//   @override
//   void initState() {
//     timer = Timer(minimumSplashTime, () => canNavigate = true);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
//     Future.delayed(const Duration(seconds: 3)).then(
//       (_) => {
//         if (mounted) context.navigate(Routes.services),
//       },
//     );
//     super.initState();
//   }

//   Future<void> _initAnimation() async {
//     await Future.delayed(
//       delayToInitAnimation,
//       () => setState(() => showText = true),
//     );
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.colorsScheme.primary,
//       body: Center(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // SvgPicture.asset(
//             //   KaziAssets.logo,
//             //   height: 55,
//             // ),
//             AnimatedContainer(
//               duration: containerAnimationDuration,
//               height: KaziSizings.logoHeight,
//               width: showText ? context.width * 0.19 : 0,
//               child: Center(
//                 child: AnimatedOpacity(
//                   duration: opacityAnimationDuration,
//                   opacity: showText ? 1 : 0,
//                   child: Text(
//                     'Kazi',
//                     style: KaziTextStyles.headlineLg.copyWith(fontSize: 36),
//                     softWrap: false,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:kazi_core/shared/themes/extensions/theme_extension.dart';
import 'package:kazi_core/shared/themes/settings/kazi_icons.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animações para cada elemento
  late Animation<double> _markOpacity;
  late Animation<Offset> _markSlide;
  late Animation<double> _wordOpacity;
  late Animation<Offset> _wordSlide;
  late Animation<double> _footOpacity;
  late Animation<Offset> _footSlide;

  @override
  void initState() {
    super.initState();

    // Duração total sincronizada com a marca (2 segundos)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Raio (Logo): sp-mark (.8s = 40% de 2s) com cubic-bezier(.2,.9,.2,1)
    final markCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Cubic(0.2, 0.9, 0.2, 1.0)),
    );
    _markOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(markCurve);
    _markSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(markCurve);

    // 2. Palavra "kazi": sp-word (.6s com delay de .34s -> intervalo de 17% a 47%)
    final wordCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.17, 0.47, curve: Curves.easeOut),
    );
    _wordOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(wordCurve);
    _wordSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(wordCurve);

    // 3. Rodapé: sp-word (.6s com delay de .55s -> intervalo de 27.5% a 57.5%)
    final footCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.275, 0.575, curve: Curves.easeOut),
    );
    _footOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(footCurve);
    _footSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(footCurve);

    // Inicia a animação
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.kaziColors.onMoneySurface;
    final brandColor = context.kaziColors.focusRing;
    final wordColor = context.colorsScheme.brightness == Brightness.dark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF1E1E1E);
    final footColor = context.colorsScheme.brightness == Brightness.dark
        ? const Color(0xFF757575)
        : const Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Conteúdo Centralizado (Raio + Nome)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Marca / Raio
                SlideTransition(
                  position: _markSlide,
                  child: FadeTransition(
                    opacity: _markOpacity,
                    child: Icon(
                      KaziIcons.logo,
                      size: 74,
                      color: brandColor,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // 2. Palavra "kazi"
                SlideTransition(
                  position: _wordSlide,
                  child: FadeTransition(
                    opacity: _wordOpacity,
                    child: Text(
                      'kazi',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.55,
                        color: wordColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Rodapé Posicionado
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _footSlide,
              child: FadeTransition(
                opacity: _footOpacity,
                child: Text(
                  'kazi · trabalho',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    color: footColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
