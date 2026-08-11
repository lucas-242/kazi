part of 'kazi_snackbar.dart';

OverlayEntry _getSnackbarOverlay(String message) => OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        left: KaziInsets.lg,
        right: KaziInsets.lg,
        child: Material(
          borderRadius: KaziRadii.xsBorder,
          color: context.colors.inverse.withValues(alpha: .9),
          child: Container(
            alignment: Alignment.center,
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: KaziInsets.md,
              vertical: KaziInsets.xxs,
            ),
            child: Text(
              message,
              softWrap: true,
              style: KaziTextStyles.bodyMedium.copyWith(
                color: context.colors.onInverse,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
