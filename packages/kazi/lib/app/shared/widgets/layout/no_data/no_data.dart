import 'package:flutter/material.dart';
import 'package:kazi/app/shared/themes/themes.dart';

class NoData extends StatelessWidget {
  const NoData({super.key, required this.message, this.navbar});
  final String message;
  final Widget? navbar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (navbar != null) navbar!,
          if (navbar != null) SizedBox(height: AppSizeConstants.mediumSpace),
          Image.asset(AppAssets.noData),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizeConstants.largeSpace,
            ),
            child: Text(
              message,
              style: context.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
