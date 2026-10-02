import 'package:flutter/material.dart';
import 'package:kazi/features/auth/presenter/controllers/account_action_state.dart';
import 'package:kazi/features/auth/presenter/controllers/delete_account_controller.dart';
import 'package:kazi/features/auth/presenter/controllers/sign_out_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Blocks [child] while the account is being signed out or deleted, and
/// reports a failure of either.
class AccountActionProgress extends ConsumerWidget {
  const AccountActionProgress({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onFailure(AccountActionState? _, AccountActionState current) {
      if (current.status == AccountActionStatus.error &&
          current.errorMessage != null) {
        KaziSnackbar.show(context, current.errorMessage!);
      }
    }

    ref
      ..listen(signOutControllerProvider, onFailure)
      ..listen(deleteAccountControllerProvider, onFailure);

    final isRunning =
        ref.watch(signOutControllerProvider.select((s) => s.isRunning)) ||
        ref.watch(deleteAccountControllerProvider.select((s) => s.isRunning));

    return KaziBlockingLoading(isLoading: isRunning, child: child);
  }
}
