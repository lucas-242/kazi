import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/currency/currency_providers.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/presenter/widgets/contact_options_sheet.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The client's card: what they have earned the user, then who they are, then
/// what was done for them. See core/counters.md for the figures.
class ClientDetailsContent extends ConsumerWidget {
  const ClientDetailsContent({
    super.key,
    required this.client,
    required this.serviceHistory,
    required this.firstServiceDate,
    required this.hasReachedMaxServices,
    required this.isLoadingMoreServices,
    required this.onTapLoadMore,
  });

  final ClientEntry client;
  final List<Service> serviceHistory;

  /// The oldest service performed for this person, or null when there is none.
  final DateTime? firstServiceDate;

  final bool hasReachedMaxServices;
  final bool isLoadingMoreServices;
  final VoidCallback onTapLoadMore;

  String? _mostGets(WidgetRef ref) {
    final id = client.counters.topCatalogItemId;
    if (id == null) return null;

    final items = ref.watch(catalogControllerProvider).catalogItems;
    return items.where((item) => item.id == id).firstOrNull?.name;
  }

  String? _clientSince(BuildContext context) {
    final since = firstServiceDate ?? client.info.user.createdAt;
    if (since == null) return null;

    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMM(locale).format(since);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = KaziLocalizations.current;
    final user = client.info.user;
    final phone = user.phones.isNotEmpty ? user.phones.first : '';
    final mostGets = _mostGets(ref);
    final clientSince = _clientSince(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EarningsPanel(client: client, clientSince: clientSince),
        KaziSpacings.verticalSm,
        if (mostGets != null)
          _InfoRow(
            icon: Icons.local_offer_outlined,
            label: l10n.mostGets,
            value: mostGets,
          ),
        if (user.document.isNotEmpty)
          _InfoRow(
            icon: Icons.badge_outlined,
            label: l10n.document,
            value: user.document,
          ),
        if (phone.isNotEmpty)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: l10n.phone,
            value: phone,
            onTap: () => openContactOptions(context, ref, phone),
          ),
        if (user.email.isNotEmpty)
          _InfoRow(
            icon: Icons.mail_outlined,
            label: l10n.email,
            value: user.email,
            onTap: () => openEmail(context, ref, user.email),
          ),
        if (!ClientBirthDate.isMissing(user.birthDate))
          _InfoRow(
            icon: Icons.cake_outlined,
            label: l10n.birthDate,
            value: user.birthDate.format().normalizeDate(),
          ),
        if (client.observation.isNotEmpty)
          _InfoRow(
            icon: Icons.sticky_note_2_outlined,
            label: l10n.observation,
            value: client.observation,
          ),
        KaziSpacings.verticalSm,
        _HistoryHeading(client: client),
        KaziSpacings.verticalSm,
        if (serviceHistory.isEmpty)
          Text(
            l10n.noServiceForThisClient,
            style: KaziTextStyles.bodySmall.copyWith(
              color: context.colors.textMuted,
            ),
          )
        else ...[
          _ServiceHistory(serviceHistory: serviceHistory),
          if (!hasReachedMaxServices)
            Center(
              child: isLoadingMoreServices
                  ? const Padding(
                      padding: EdgeInsets.all(KaziInsets.sm),
                      child: KaziLoading(height: KaziInsets.xxLg),
                    )
                  : KaziTextButton(
                      onTap: onTapLoadMore,
                      child: Text(l10n.loadMore),
                    ),
            ),
        ],
        KaziSpacings.verticalLg,
      ],
    );
  }
}

class _EarningsPanel extends ConsumerWidget {
  const _EarningsPanel({required this.client, required this.clientSince});

  final ClientEntry client;

  /// The month resolved by [ClientDetailsContent._clientSince], or null when
  /// there is no date to stand behind.
  final String? clientSince;

  /// "12 serviços · cliente desde mar/25", less the second half when no date
  /// could be resolved — an invented one is worse than a missing one.
  String _subtitle() {
    final services = KaziLocalizations.current.servicesCount(
      client.counters.count,
    );
    if (clientSince == null) return services;

    return '$services · '
        '${KaziLocalizations.current.clientSince(clientSince!)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currency = ref.watch(kaziDefaultCurrencyProvider);
    final rateBook =
        ref
            .watch(dayRateBookProvider(ExchangeRates.dateKeyOf(DateTime.now())))
            .asData
            ?.value ??
        const RateBook.empty();

    final total = client.counters.commissionIn(
      currency,
      rateBook: rateBook,
      legacyCurrency: currency,
      dateKey: ExchangeRates.dateKeyOf(DateTime.now()),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaziInsets.md),
      decoration: BoxDecoration(
        color: colors.money.surface,
        borderRadius: KaziRadii.mdBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            KaziLocalizations.current.earnedYou.toUpperCase(),
            style: KaziTextStyles.tag.copyWith(color: colors.money.label),
          ),
          KaziSpacings.verticalXs,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              NumberFormatUtils.formatCurrencyIn(total.amount, currency),
              style: KaziTextStyles.amount.copyWith(
                color: colors.money.onSurface,
              ),
            ),
          ),
          KaziSpacings.verticalXxs,
          Text(
            _subtitle(),
            style: KaziTextStyles.labelSmall.copyWith(
              color: colors.money.accent,
            ),
          ),
          if (total.unconverted > 0) ...[
            KaziSpacings.verticalXxs,
            Text(
              KaziLocalizations.current.ratesUnavailable,
              style: KaziTextStyles.labelSmall.copyWith(
                color: colors.money.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryHeading extends ConsumerWidget {
  const _HistoryHeading({required this.client});

  final ClientEntry client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${KaziLocalizations.current.history} · '
                    '${KaziLocalizations.current.servicesCount(client.counters.count)}'
                .toUpperCase(),
            style: KaziTextStyles.tag.copyWith(color: context.colors.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        KaziSpacings.horizontalXs,
        KaziTextButton(
          color: context.colors.brand.text,
          onTap: () {
            unawaited(
              ref
                  .read(serviceLandingControllerProvider.notifier)
                  .openServices(view: ServiceView.summary, clientId: client.id),
            );
            KaziNavigator.navigate(AppPage.services);
          },
          child: Text(
            KaziLocalizations.current.seeInSummary,
            style: KaziTextStyles.labelMedium,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Set on the phone and email rows only — the two facts here that lead
  /// somewhere else. The value reads in the brand ink exactly because of this,
  /// the same signal `KaziTextButton` gives every other link in the app.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaziInsets.xs),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: KaziRadii.smBorder,
          border: Border.all(color: colors.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: KaziRadii.smBorder,
          child: InkWell(
            onTap: onTap,
            borderRadius: KaziRadii.smBorder,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KaziInsets.md,
                vertical: KaziInsets.sm,
              ),
              child: Row(
                children: [
                  Icon(icon, size: KaziSizings.iconSm, color: colors.textMuted),
                  KaziSpacings.horizontalXs,
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      style: KaziTextStyles.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                  KaziSpacings.horizontalSm,
                  Expanded(
                    flex: 3,
                    child: Text(
                      value,
                      style: KaziTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: onTap == null ? null : colors.brand.text,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceHistory extends StatelessWidget {
  const _ServiceHistory({required this.serviceHistory});

  final List<Service> serviceHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < serviceHistory.length; index++) ...[
          if (index != 0) KaziSpacings.verticalXs,
          ServiceCard(
            service: serviceHistory[index],
            showClient: false,
            onTap: () => KaziNavigator.push(
              AppPage.serviceDetails,
              extra: ServiceArguments(service: serviceHistory[index]),
            ),
          ),
        ],
      ],
    );
  }
}
