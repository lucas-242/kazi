import 'package:flutter/material.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The privacy policy, rendered in the app.
///
/// The text has lived, translated, in the `privacyPolice*` ARB keys since 2023
/// with nothing reading it — the policy existed only as a blog post nobody
/// could reach from inside the app. Now that the app records sessions, "go and
/// find it on the web" is not good enough: the document describing what is
/// collected has to be one tap from the switches that turn it off.
///
/// Sections are ordered by what a worried person opens this looking for: what
/// is collected, then the two new things (analytics, recording), then rights,
/// then the boilerplate.
class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;

    return Scaffold(
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubNavBar(title: l10n.privacyPolicy),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: KaziInsets.xxLg),
                children: [
                  _Paragraph(l10n.privacyPoliceStart),
                  _Section(
                    title: l10n.privacyPoliceInformationTitle,
                    body: l10n.privacyPoliceInformation,
                  ),
                  _Providers(
                    names: [
                      l10n.privacyPoliceInformation1,
                      l10n.privacyPoliceInformation2,
                      l10n.privacyPoliceInformation3,
                      l10n.privacyPoliceInformation4,
                      l10n.privacyPoliceInformation5,
                      l10n.privacyPoliceInformation6,
                    ],
                  ),
                  // The two sections this whole page exists for.
                  _Section(
                    title: l10n.privacyPoliceAnalyticsTitle,
                    body: l10n.privacyPoliceAnalytics,
                  ),
                  _Section(
                    title: l10n.privacyPoliceReplayTitle,
                    body: l10n.privacyPoliceReplay,
                  ),
                  _Section(
                    title: l10n.privacyPoliceRightsTitle,
                    body: l10n.privacyPoliceRights,
                  ),
                  _Section(
                    title: l10n.privacyPoliceRetentionTitle,
                    body: l10n.privacyPoliceRetention,
                  ),
                  _Section(
                    title: l10n.privacyPoliceLogDataTitle,
                    body: l10n.privacyPoliceLogData,
                  ),
                  _Section(
                    title: l10n.privacyPoliceCookiesTitle,
                    body: l10n.privacyPoliceCookies,
                  ),
                  _Section(
                    title: l10n.privacyPoliceServicesTitle,
                    body: l10n.privacyPoliceServices,
                  ),
                  _Section(
                    title: l10n.privacyPoliceSecurityTitle,
                    body: l10n.privacyPoliceSecurity,
                  ),
                  _Section(
                    title: l10n.pricayPoliceLinksTitle,
                    body: l10n.pricayPoliceLinks,
                  ),
                  _Section(
                    title: l10n.privacyPoliceChildrenTitle,
                    body: l10n.privacyPoliceChildren,
                  ),
                  _Section(
                    title: l10n.privacyPoliceChangesTitle,
                    body: l10n.privacyPoliceChanges,
                  ),
                  _Section(
                    title: l10n.privacyPoliceContactTitle,
                    body: '${l10n.privacyPoliceContact}${l10n.contactEmail}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: KaziInsets.lg,
            bottom: KaziInsets.xs,
          ),
          child: Text(title, style: context.text.titleMedium),
        ),
        _Paragraph(body),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: KaziTextStyles.bodyMedium.copyWith(
        color: context.colors.textMuted,
      ),
    );
  }
}

/// The third-party list, as a bulleted block rather than a run-on sentence —
/// it is the part people actually scan for a name they do not recognise.
class _Providers extends StatelessWidget {
  const _Providers({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final name in names)
            Padding(
              padding: const EdgeInsets.only(bottom: KaziInsets.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: KaziInsets.xxs),
                    child: KaziColorDot(color: colors.textMuted, size: 6),
                  ),
                  KaziSpacings.horizontalXs,
                  Expanded(
                    child: Text(
                      name,
                      style: KaziTextStyles.bodyMedium.copyWith(
                        color: colors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
