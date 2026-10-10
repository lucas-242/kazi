import 'package:flutter/material.dart';
import 'package:kazi/core/constants/app_urls.dart';
import 'package:kazi/core/widgets/sub_nav_bar.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A readable summary of the privacy policy, with the full text below it.
///
/// The full text stays in the app rather than only behind the web link: the
/// web copy predates analytics and session recording.
class PrivacyPolicyPage extends ConsumerStatefulWidget {
  const PrivacyPolicyPage({super.key});

  /// When the `privacyPolice*` text last changed. Bump it with the text.
  static final updatedAt = DateTime(2026, 10, 6);

  @override
  ConsumerState<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends ConsumerState<PrivacyPolicyPage> {
  bool _isFullVersionShown = false;

  Future<void> _open(String url) =>
      ref.read(kaziUrlLauncherServiceProvider).launch(url);

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;
    final locale = Localizations.localeOf(context).toString();
    final updatedAt = DateFormat.yMMMMd(
      locale,
    ).format(PrivacyPolicyPage.updatedAt);

    return Scaffold(
      body: KaziSafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubNavBar(
              title: l10n.privacy,
              pills: [
                KaziCircularButton.plain(
                  onTap: () => _open(AppUrls.privacyPolicy),
                  semantics: l10n.privacyOpenWebVersion,
                  child: const Icon(LucideIcons.languages, size: 18),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: KaziInsets.md,
                bottom: KaziInsets.xxLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.privacyUpdatedOn(updatedAt),
                    style: KaziTextStyles.bodySmall.copyWith(
                      color: context.colors.textMuted,
                    ),
                  ),
                  KaziSpacings.verticalSm,
                  _SummaryCard(
                    title: l10n.privacySummaryStoredTitle,
                    body: l10n.privacySummaryStored,
                  ),
                  _SummaryCard(
                    title: l10n.privacySummaryNeverTitle,
                    body: l10n.privacySummaryNever,
                  ),
                  _SummaryCard(
                    title: l10n.privacySummaryControlTitle,
                    body: l10n.privacySummaryControl,
                  ),
                  _SummaryCard(
                    title: l10n.privacySummaryDeleteTitle,
                    body: l10n.privacySummaryDelete,
                  ),
                  KaziSpacings.verticalXxs,
                  if (_isFullVersionShown)
                    _FullVersion(onOpen: _open)
                  else
                    KaziElevatedButton.outlined(
                      onTap: () => setState(() => _isFullVersionShown = true),
                      label: l10n.privacyReadFullVersion,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Material(
        color: colors.card,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: KaziRadii.mdBorder,
          side: BorderSide(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KaziInsets.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: KaziTextStyles.titleSmall),
              KaziSpacings.verticalXxs,
              Text(
                body,
                style: KaziTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullVersion extends StatelessWidget {
  const _FullVersion({required this.onOpen});

  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = KaziLocalizations.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaziSpacings.verticalSm,
        _Paragraph(l10n.privacyPoliceStart),
        _Section(
          title: l10n.privacyPoliceInformationTitle,
          body: l10n.privacyPoliceInformation,
        ),
        _Providers(
          onOpen: onOpen,
          providers: [
            (
              name: l10n.privacyPoliceProviderFirebase,
              purpose: l10n.privacyPoliceProviderFirebasePurpose,
              url: l10n.privacyPoliceProviderFirebaseUrl,
            ),
            (
              name: l10n.privacyPoliceProviderAdMob,
              purpose: l10n.privacyPoliceProviderAdMobPurpose,
              url: l10n.privacyPoliceProviderAdMobUrl,
            ),
            (
              name: l10n.privacyPoliceProviderGoogle,
              purpose: l10n.privacyPoliceProviderGooglePurpose,
              url: l10n.privacyPoliceProviderGoogleUrl,
            ),
            (
              name: l10n.privacyPoliceProviderApple,
              purpose: l10n.privacyPoliceProviderApplePurpose,
              url: l10n.privacyPoliceProviderAppleUrl,
            ),
            (
              name: l10n.privacyPoliceProviderPostHog,
              purpose: l10n.privacyPoliceProviderPostHogPurpose,
              url: l10n.privacyPoliceProviderPostHogUrl,
            ),
            (
              name: l10n.privacyPoliceProviderPlayServices,
              purpose: l10n.privacyPoliceProviderPlayServicesPurpose,
              url: l10n.privacyPoliceProviderPlayServicesUrl,
            ),
          ],
        ),
        _Section(
          title: l10n.privacyPoliceAnalyticsTitle,
          body: l10n.privacyPoliceAnalytics,
        ),
        _Section(
          title: l10n.privacyPoliceReplayTitle,
          body: l10n.privacyPoliceReplay,
        ),
        _Section(
          title: l10n.privacyPoliceAdsTitle,
          body: l10n.privacyPoliceAds,
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

typedef _Provider = ({String name, String purpose, String url});

/// Lists every provider on both platforms: the web copy of this text is one
/// page for Android and iPhone alike, so platform-only entries say so in their
/// name rather than being hidden here.
class _Providers extends StatelessWidget {
  const _Providers({required this.providers, required this.onOpen});

  final List<_Provider> providers;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: KaziInsets.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final provider in providers)
            Semantics(
              link: true,
              child: InkWell(
                onTap: () => onOpen(provider.url),
                borderRadius: KaziRadii.smBorder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: KaziInsets.xxs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: KaziInsets.xxs),
                        child: KaziColorDot(color: colors.textMuted, size: 6),
                      ),
                      KaziSpacings.horizontalXs,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: KaziTextStyles.bodyMedium.copyWith(
                                color: colors.text,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: colors.text,
                              ),
                            ),
                            Text(
                              provider.purpose,
                              style: KaziTextStyles.bodySmall.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
