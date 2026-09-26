import 'package:equatable/equatable.dart';

/// What the user has said about being measured.
///
/// The two answers have different shapes because the two questions have
/// different legal footing: usage events run on legitimate interest and record
/// an *objection*, so [analyticsOptOut] is a boolean; recording someone's screen
/// is asked for, so [sessionReplayConsent] is nullable and `null` — the question
/// not yet put — is never read as a yes.
class PrivacySettings extends Equatable {
  const PrivacySettings({
    this.analyticsOptOut = false,
    this.sessionReplayConsent,
  });

  final bool analyticsOptOut;
  final bool? sessionReplayConsent;

  bool get isAnalyticsAllowed => !analyticsOptOut;

  /// Only an explicit yes counts.
  bool get isReplayAllowed => sessionReplayConsent ?? false;

  bool get needsReplayPrompt => sessionReplayConsent == null;

  PrivacySettings copyWith({bool? analyticsOptOut, bool? sessionReplayConsent}) {
    return PrivacySettings(
      analyticsOptOut: analyticsOptOut ?? this.analyticsOptOut,
      sessionReplayConsent: sessionReplayConsent ?? this.sessionReplayConsent,
    );
  }

  @override
  List<Object?> get props => [analyticsOptOut, sessionReplayConsent];
}
