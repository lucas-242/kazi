import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/core/currency/currency_providers.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service_view.dart';
import 'package:kazi/features/services/presenter/controllers/catalog_controller.dart';
import 'package:kazi/features/services/presenter/controllers/service_landing_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The client's card: what they have earned the user, then who they are, then
/// what was done for them. See core/counters.md for the figures.
class ClientDetailsContent extends ConsumerWidget {
  const ClientDetailsContent({
    super.key,
    required this.client,
    required this.serviceHistory,
    required this.hasReachedMaxServices,
    required this.isLoadingMoreServices,
    required this.onTapLoadMore,
  });

  final ClientEntry client;
  final List<ServiceHistoryItem> serviceHistory;
  final bool hasReachedMaxServices;
  final bool isLoadingMoreServices;
  final VoidCallback onTapLoadMore;

  /// The catalog item this person gets most, resolved against the catalog the
  /// app already holds — `mostUsedServices` stores ids, so renaming the item
  /// renames the answer.
  String? _mostGets(WidgetRef ref) {
    final id = client.counters.topCatalogItemId;
    if (id == null) return null;

    final items = ref.watch(catalogControllerProvider).catalogItems;
    return items.where((item) => item.id == id).firstOrNull?.name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = client.info.user;
    final phone = user.phones.isNotEmpty ? user.phones.first : '';
    final hasDocument = user.identifier.isNotEmpty;
    final hasBirthDate = !ClientBirthDate.isMissing(user.birthDate);
    final mostGets = _mostGets(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EarningsPanel(client: client),
        KaziSpacings.verticalMd,
        if (mostGets != null) ...[
          _InfoRow(label: KaziLocalizations.current.mostGets, value: mostGets),
          KaziSpacings.verticalMd,
        ],
        if (hasDocument || hasBirthDate) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasDocument)
                Expanded(
                  child: _InfoRow(
                    label: KaziLocalizations.current.document,
                    value: user.identifier,
                  ),
                ),
              if (hasBirthDate)
                Expanded(
                  child: _InfoRow(
                    label: KaziLocalizations.current.birthDate,
                    value: user.birthDate.format().normalizeDate(),
                  ),
                ),
            ],
          ),
          KaziSpacings.verticalMd,
        ],
        _InfoRow(
          label: KaziLocalizations.current.phone,
          value: phone.isEmpty ? '-' : phone,
        ),
        if (user.email.isNotEmpty) ...[
          KaziSpacings.verticalMd,
          _InfoRow(label: KaziLocalizations.current.email, value: user.email),
        ],
        if (client.observation.isNotEmpty) ...[
          KaziSpacings.verticalMd,
          _InfoRow(
            label: KaziLocalizations.current.observation,
            value: client.observation,
          ),
        ],
        KaziSpacings.verticalXLg,
        _HistoryHeading(client: client),
        KaziSpacings.verticalMd,
        if (serviceHistory.isEmpty)
          Text(
            KaziLocalizations.current.noServiceForThisClient,
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
                      child: Text(KaziLocalizations.current.loadMore),
                    ),
            ),
        ],
      ],
    );
  }
}

/// What this person has earned the user, across everything — the answer the
/// screen exists to give, so it leads.
class _EarningsPanel extends ConsumerWidget {
  const _EarningsPanel({required this.client});

  final ClientEntry client;

  /// "12 serviços · cliente desde mar/25". The second half is dropped on a
  /// record written before the registration date was kept — an invented date
  /// is worse than a missing one.
  String _subtitle(BuildContext context) {
    final services = KaziLocalizations.current.servicesCount(
      client.counters.count,
    );
    final since = client.createdAt;
    if (since == null) return services;

    final locale = Localizations.localeOf(context).toString();
    return '$services · '
        '${KaziLocalizations.current.clientSince(DateFormat.yMMM(locale).format(since))}';
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
            // Upper-cased at the call site: Flutter has no text-transform.
            KaziLocalizations.current.earnedYou.toUpperCase(),
            style: KaziTextStyles.tag.copyWith(color: colors.money.onSurface),
          ),
          KaziSpacings.verticalXs,
          // Scaled rather than wrapped: a truncated amount is worse than a
          // smaller one.
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
            _subtitle(context),
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

/// "Histórico · 12 serviços" with the way into the same client on the summary.
/// Like every other shortcut, it opens the services tab with a filter applied.
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
            '${KaziLocalizations.current.servicesCount(client.counters.count)}',
            style: KaziTextStyles.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        KaziSpacings.horizontalXs,
        // Flexible: the heading and a translated call to action together run
        // past a phone's width, and the link is the half that can ellipsise.
        Flexible(
          child: KaziTextButton(
            onTap: () {
              unawaited(
                ref
                    .read(serviceLandingControllerProvider.notifier)
                    .openServices(
                      view: ServiceView.summary,
                      clientId: client.id,
                    ),
              );
              KaziNavigator.navigate(AppPage.services);
            },
            child: Text(
              KaziLocalizations.current.seeInSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KaziTextStyles.bodySmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        KaziSpacings.verticalXs,
        Text(value, style: KaziTextStyles.bodyMedium),
      ],
    );
  }
}

class _ServiceHistory extends StatelessWidget {
  const _ServiceHistory({required this.serviceHistory});

  final List<ServiceHistoryItem> serviceHistory;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: serviceHistory.length,
      separatorBuilder: (_, _) => Divider(color: context.colors.border),
      itemBuilder: (_, index) {
        final service = serviceHistory[index];
        return SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KaziInsets.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(service.serviceName, style: KaziTextStyles.titleSmall),
                KaziSpacings.verticalXs,
                Text(
                  service.formattedDate,
                  style: KaziTextStyles.bodySmall.copyWith(
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
