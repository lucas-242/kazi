import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// The way into a list's archive, sitting quietly at the end of the list.
///
/// Renders nothing when [count] is zero: an archive screen with nothing in it
/// is a dead end, so it is never reachable.
class ArchivedEntryTile extends StatelessWidget {
  const ArchivedEntryTile({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          KaziLocalizations.current.viewArchived(count),
          style: KaziTextStyles.bodySmall.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ),
    );
  }
}
