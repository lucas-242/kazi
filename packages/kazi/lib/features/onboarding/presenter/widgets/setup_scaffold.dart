import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_state.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// The frame every setup screen sits in: progress, an escape hatch, a scrolling
/// body and a bottom action pinned below it.
///
/// There is a discreet close button from the second screen on, and deliberately
/// **no "Skip"**. Leaving has to be possible; inviting it does not — whoever
/// skips lands on the empty home this whole flow exists to remove.
class SetupScaffold extends StatelessWidget {
  const SetupScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    required this.action,
    this.subtitle,
    this.onClose,
    this.footer,
    this.showProgress = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final SetupStep step;
  final String title;
  final String? subtitle;
  final Widget child;

  /// The primary button. Null renders the space empty rather than collapsing
  /// it, so the body does not jump between steps.
  final Widget? action;

  /// Rendered under [action] — the secondary way out of a screen, like "I have
  /// not worked yet".
  final Widget? footer;

  final VoidCallback? onClose;
  final bool showProgress;

  /// The opening and closing screens invert: yellow to open, graphite to land
  /// on the number.
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = backgroundColor ?? colors.background;
    final foreground = foregroundColor ?? colors.text;

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
                    step: step,
                    showProgress: showProgress,
                    onClose: onClose,
                    foreground: foreground,
                  ),
                  KaziSpacings.verticalLg,
                  Text(title, style: context.text.headlineSmall),
                  if (subtitle != null) ...[
                    KaziSpacings.verticalXs,
                    Text(
                      subtitle!,
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
                        children: [child],
                      ),
                    ),
                  ),
                  if (action != null) ...[
                    KaziSpacings.verticalMd,
                    SizedBox(width: double.infinity, child: action),
                  ],
                  if (footer != null) ...[KaziSpacings.verticalXs, footer!],
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
    required this.onClose,
    required this.foreground,
  });

  final SetupStep step;
  final bool showProgress;
  final VoidCallback? onClose;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showProgress)
          Expanded(child: _ProgressBar(step: step, foreground: foreground))
        else
          const Spacer(),
        if (onClose != null)
          Padding(
            padding: const EdgeInsets.only(left: KaziInsets.sm),
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              color: foreground.withValues(alpha: 0.6),
              tooltip: KaziLocalizations.current.exit,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
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
