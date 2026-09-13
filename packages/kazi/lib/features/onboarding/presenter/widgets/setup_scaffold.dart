import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The ground a setup screen sits on: yellow to open and to land on the
/// number, graphite to register the first service, the page background for
/// everything in between.
enum SetupSurface { plain, brand, money }

/// The frame every setup screen sits in: progress, a way back, a scrolling
/// body and a bottom action pinned below it.
///
/// There is no close and no "Skip": every question is the minimum the app
/// needs to calculate, so the only way forward is answering it.
class SetupScaffold extends StatelessWidget {
  const SetupScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.subtitle,
    this.onBack,
    this.footer,
    this.showProgress = true,
    this.surface = SetupSurface.plain,
  });

  final SetupStep step;
  final String title;
  final String? subtitle;
  final Widget child;

  final String actionLabel;

  /// Null renders the action disabled.
  final VoidCallback? onAction;

  /// Rendered under the action — a secondary answer to the screen, like "I
  /// have not worked yet".
  final Widget? footer;

  final VoidCallback? onBack;
  final bool showProgress;
  final SetupSurface surface;

  @override
  Widget build(BuildContext context) {
    final frame = _SetupFrame(scaffold: this);

    // The money surface is graphite in both brightnesses; rows and chips drawn
    // from the light palette would paint graphite ink on it.
    return surface == SetupSurface.money
        ? Theme(data: KaziThemeSettings.dark(), child: frame)
        : frame;
  }
}

class _SetupFrame extends StatelessWidget {
  const _SetupFrame({required this.scaffold});

  final SetupScaffold scaffold;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final surface = scaffold.surface;

    final (background, foreground, footerInk) = switch (surface) {
      SetupSurface.plain => (colors.background, colors.text, colors.brand.text),
      SetupSurface.brand => (
        colors.brand.fill,
        colors.brand.onFill,
        colors.brand.onFill,
      ),
      SetupSurface.money => (
        colors.money.surface,
        colors.money.onSurface,
        colors.money.accent,
      ),
    };

    // The default button is yellow, which has no edge on a yellow ground.
    final onBrand = surface == SetupSurface.brand;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: colors.overlayOn(background),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziInsets.lg,
                vertical: KaziInsets.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    step: scaffold.step,
                    showProgress: scaffold.showProgress,
                    onBack: scaffold.onBack,
                    foreground: foreground,
                  ),
                  KaziSpacings.verticalLg,
                  Text(
                    scaffold.title,
                    style: KaziTextStyles.headlineSmall.copyWith(
                      color: foreground,
                    ),
                  ),
                  if (scaffold.subtitle case final String subtitle) ...[
                    KaziSpacings.verticalXs,
                    Text(
                      subtitle,
                      style: KaziTextStyles.bodyMedium.copyWith(
                        color: foreground.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  KaziSpacings.verticalMd,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [scaffold.child],
                      ),
                    ),
                  ),
                  KaziSpacings.verticalMd,
                  SizedBox(
                    width: double.infinity,
                    child: KaziElevatedButton.label(
                      label: scaffold.actionLabel,
                      onTap: scaffold.onAction,
                      backgroundColor: onBrand ? colors.brand.onFill : null,
                      foregroundColor: onBrand ? colors.brand.fill : null,
                      disabledBackgroundColor: foreground.withValues(
                        alpha: 0.12,
                      ),
                      disabledForegroundColor: foreground.withValues(
                        alpha: 0.38,
                      ),
                    ),
                  ),
                  if (scaffold.footer case final Widget footer) ...[
                    KaziSpacings.verticalXs,
                    TextButtonTheme(
                      data: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: footerInk),
                      ),
                      child: footer,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.showProgress,
    required this.onBack,
    required this.foreground,
  });

  final SetupStep step;
  final bool showProgress;
  final VoidCallback? onBack;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // Held at the back button's height so the title does not jump between
    // screens that have one and screens that do not.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: KaziSizings.minTouchTarget),
      child: Row(
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: KaziInsets.sm),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                color: foreground,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (showProgress)
            Expanded(child: _ProgressBar(step: step, foreground: foreground))
          else
            const Spacer(),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.foreground});

  final SetupStep step;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final done = step.index + 1;

    return Semantics(
      label: KaziLocalizations.current.checklistProgress(
        done,
        SetupStep.progressSteps,
      ),
      child: Row(
        children: [
          for (var index = 0; index < SetupStep.progressSteps; index++) ...[
            if (index > 0) const SizedBox(width: KaziInsets.xxs),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: index < done
                      ? foreground
                      : foreground.withValues(alpha: 0.2),
                  borderRadius: KaziRadii.fullBorder,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
