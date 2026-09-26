import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kazi/core/constants/app_urls.dart';
import 'package:kazi_core/kazi_core.dart';

class LoginLegalText extends ConsumerStatefulWidget {
  const LoginLegalText({
    super.key,
    required this.color,
    required this.linkColor,
  });

  /// Ink for the sentence itself.
  final Color color;

  /// Ink for the link — full-strength, so it reads as tappable against the
  /// muted sentence around it.
  final Color linkColor;

  @override
  ConsumerState<LoginLegalText> createState() => _LoginLegalTextState();
}

class _LoginLegalTextState extends ConsumerState<LoginLegalText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  Future<void> _open(String url) =>
      ref.read(kaziUrlLauncherServiceProvider).launch(url);

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();

    final l10n = KaziLocalizations.current;
    final privacyLabel = l10n.privacyPolicy;

    final links = {privacyLabel: AppUrls.privacyPolicy};

    final baseStyle = KaziTextStyles.bodySmall.copyWith(color: widget.color);
    final linkStyle = baseStyle.copyWith(
      color: widget.linkColor,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: widget.linkColor,
    );

    return Text.rich(
      TextSpan(
        children: _spans(
          text: l10n.loginLegal(privacyLabel),
          links: links,
          baseStyle: baseStyle,
          linkStyle: linkStyle,
        ),
      ),
    );
  }

  List<InlineSpan> _spans({
    required String text,
    required Map<String, String> links,
    required TextStyle baseStyle,
    required TextStyle linkStyle,
  }) {
    final spans = <InlineSpan>[];
    var cursor = 0;

    while (cursor < text.length) {
      // The next label to appear, whichever it is: the sentence decides the
      // order, not the map.
      String? nextLabel;
      var nextIndex = -1;

      for (final label in links.keys) {
        if (label.isEmpty) {
          continue;
        }
        final index = text.indexOf(label, cursor);
        if (index != -1 && (nextIndex == -1 || index < nextIndex)) {
          nextIndex = index;
          nextLabel = label;
        }
      }

      if (nextLabel == null) {
        spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
        break;
      }

      if (nextIndex > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, nextIndex), style: baseStyle),
        );
      }

      final url = links[nextLabel]!;

      if (url.isEmpty) {
        spans.add(TextSpan(text: nextLabel, style: baseStyle));
      } else {
        final recognizer = TapGestureRecognizer()..onTap = () => _open(url);
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(text: nextLabel, style: linkStyle, recognizer: recognizer),
        );
      }

      cursor = nextIndex + nextLabel.length;
    }

    return spans;
  }
}
