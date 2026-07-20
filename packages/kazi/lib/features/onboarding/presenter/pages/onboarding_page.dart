import 'package:flutter/material.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/routes/router_controller.dart';
import 'package:kazi/features/subscription/presenter/widgets/plan_comparison.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _page = 0;

  static const int _lastPage = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref.read(routerControllerProvider.notifier).setOnboardingSeen();
    if (!mounted) return;
    KaziNavigator.navigate(AppPage.home);
  }

  void _next() {
    if (_page >= _lastPage) {
      _complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final isLastPage = _page == _lastPage;

    return Scaffold(
      backgroundColor: context.colorsScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _complete, child: Text(l10n.skip)),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _page = value),
                children: [_WelcomeStep(), _FeaturesStep(), _PlansStep()],
              ),
            ),
            _PageDots(count: _lastPage + 1, current: _page),
            Padding(
              padding: const EdgeInsets.all(KaziInsets.xxLg),
              child: KaziElevatedButton.label(
                onTap: _next,
                label: isLastPage ? l10n.onboardingGetStarted : l10n.next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    return _StepScaffold(
      children: [
        Center(
          child: KaziImage(KaziImageAssets.onboarding, height: 200, width: 200),
        ),
        KaziSpacings.verticalXLg,
        RichText(
          text: TextSpan(
            text: l10n.onboardingTitle1,
            style: KaziTextStyles.headlineLg,
            children: [
              TextSpan(
                text: l10n.onboardingTitle2,
                style: KaziTextStyles.headlineLg.copyWith(
                  color: context.colorsScheme.primary,
                ),
              ),
            ],
          ),
        ),
        KaziSpacings.verticalXs,
        Text(l10n.onboardingSubtitle, style: KaziTextStyles.headlineSm),
      ],
    );
  }
}

class _FeaturesStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    return _StepScaffold(
      children: [
        Text(l10n.onboardingFeaturesTitle, style: KaziTextStyles.headlineMd),
        KaziSpacings.verticalSm,
        Text(l10n.onboardingFeaturesSubtitle, style: KaziTextStyles.md),
        KaziSpacings.verticalXLg,
        _FeatureLine(Icons.design_services, l10n.services),
        _FeatureLine(Icons.category, l10n.serviceType),
        _FeatureLine(Icons.people, l10n.clients),
      ],
    );
  }
}

class _PlansStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    return _StepScaffold(
      children: [
        Text(l10n.onboardingPlansTitle, style: KaziTextStyles.headlineMd),
        KaziSpacings.verticalSm,
        Text(l10n.onboardingPlansSubtitle, style: KaziTextStyles.md),
        KaziSpacings.verticalXLg,
        const PlanComparison(),
      ],
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: KaziInsets.xxLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.md),
      child: Row(
        children: [
          Icon(icon, color: context.colorsScheme.primary),
          KaziSpacings.horizontalMd,
          Text(label, style: KaziTextStyles.titleMd),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: KaziInsets.xxs),
            width: index == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == current
                  ? context.colorsScheme.primary
                  : context.colorsScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
