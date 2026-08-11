import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// Picks the client the services list is narrowed to.
///
/// Only lists clients that have a service in the current period — a client with
/// nothing to show would be a filter whose single outcome is an empty screen.
class ClientFilterSheet extends StatelessWidget {
  const ClientFilterSheet({
    super.key,
    required this.clients,
    required this.selectedId,
    required this.onSelected,
  });

  final List<({String id, String name})> clients;
  final String? selectedId;

  /// Null clears the filter.
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: KaziInsets.xLg,
            left: KaziInsets.xLg,
            right: KaziInsets.xLg,
            bottom: KaziInsets.xxxLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                KaziLocalizations.current.client,
                style: KaziTextStyles.titleMedium,
              ),
              KaziSpacings.verticalXLg,
              ConstrainedBox(
                // Enough to scroll rather than to push the sheet past the top
                // of the screen when someone has a long client list.
                constraints: BoxConstraints(maxHeight: context.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  // The clearing row first, so undoing the filter is always in
                  // the same place regardless of how long the list is.
                  itemCount: clients.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _ClientOption(
                        label: KaziLocalizations.current.allClients,
                        isSelected: selectedId == null,
                        onTap: () => onSelected(null),
                      );
                    }

                    final client = clients[index - 1];
                    return _ClientOption(
                      label: client.name,
                      isSelected: client.id == selectedId,
                      onTap: () => onSelected(client.id),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClientOption extends StatelessWidget {
  const _ClientOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: isSelected
            ? KaziTextStyles.titleMedium
            : KaziTextStyles.bodyMedium,
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: context.colors.brand.text)
          : null,
    );
  }
}
