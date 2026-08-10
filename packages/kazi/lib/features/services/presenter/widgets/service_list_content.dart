import 'package:flutter/material.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/core/routes/app_pages.dart';
import 'package:kazi/core/services/data/banner_ad_policy.dart';
import 'package:kazi/core/widgets/ads/ad_block.dart';
import 'package:kazi/features/services/services.dart';
import 'package:kazi/features/services/presenter/controllers/service_receipt_controller.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class ServiceListContent extends ConsumerWidget {
  const ServiceListContent({
    super.key,
    required this.services,
    required this.canScroll,
  });
  final List<Service> services;
  final bool canScroll;

  void _onTap(BuildContext context, Service service) => KaziNavigator.push(
    AppPage.serviceDetails,
    extra: ServiceArguments(service: service),
  );

  /// Flips the payment stamp on [service], then reports back so the row can
  /// stay put instead of dismissing.
  Future<bool> _onSwipe(
    BuildContext context,
    WidgetRef ref,
    Service service,
  ) async {
    try {
      await ref.read(serviceReceiptControllerProvider.notifier).setReceived([
        service,
      ], received: !service.isReceived);
    } on AppError catch (exception) {
      if (context.mounted) KaziSnackbar.show(context, exception.message);
    } catch (_) {
      if (context.mounted) {
        KaziSnackbar.show(context, KaziLocalizations.current.errorUnknowError);
      }
    }

    // Always false: the row is not going anywhere, it just changes state. A
    // true here would animate it out of a list it still belongs to.
    return false;
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    int index, {
    required BannerAdPolicy bannerPolicy,
  }) {
    final service = services[index];
    // Keyed on both branches: the ad-wrapped one used to go unkeyed, and
    // Dismissible throws without a stable key.
    final key = Key('service-${service.id}');

    final card = ServiceCard(
      service: service,
      onTap: () => _onTap(context, service),
    );

    if (bannerPolicy.shouldShowAt(index)) {
      return AdBlock(key: key, child: card);
    }

    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _onSwipe(context, ref, service),
      background: _SwipeBackground(isReceived: service.isReceived),
      child: card,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerPolicy = ref.watch(bannerAdPolicyProvider);

    if (!canScroll) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < services.length; index++) ...[
            if (index != 0) const Divider(),
            _buildItem(context, ref, index, bannerPolicy: bannerPolicy),
          ],
        ],
      );
    }

    return ListView.separated(
      itemCount: services.length,
      itemBuilder: (context, index) =>
          _buildItem(context, ref, index, bannerPolicy: bannerPolicy),
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

/// What shows behind a row being swiped: the action it is about to perform.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({required this.isReceived});

  /// Swiping a paid service undoes the stamp, so the label has to say so.
  final bool isReceived;

  @override
  Widget build(BuildContext context) {
    final roles = context.kaziColors;
    final color = isReceived ? roles.warningContainer : roles.successContainer;
    final onColor = isReceived
        ? roles.onWarningContainer
        : roles.onSuccessContainer;

    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KaziInsets.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              isReceived ? Icons.undo : Icons.check_circle_outline,
              size: 18,
              color: onColor,
            ),
            KaziSpacings.horizontalXs,
            Text(
              isReceived
                  ? KaziLocalizations.current.notReceived
                  : KaziLocalizations.current.received,
              style: KaziTextStyles.labelSm.copyWith(color: onColor),
            ),
          ],
        ),
      ),
    );
  }
}
