import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Marks a service as already paid for.
///
/// A small mark rather than a colour change on the row: the category colour
/// already owns the row's colour, and the brandbook keeps categories as small
/// marks only. Yellow is not an option here either — on these screens it
/// belongs to the button that registers a service.
class ReceivedBadge extends StatelessWidget {
  const ReceivedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = context.kaziColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaziInsets.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: roles.successContainer,
        borderRadius: KaziRadii.fullBorder,
      ),
      child: Text(
        KaziLocalizations.current.received.toUpperCase(),
        style: KaziTextStyles.tag.copyWith(
          color: roles.onSuccessContainer,
          fontSize: 9,
        ),
      ),
    );
  }
}
