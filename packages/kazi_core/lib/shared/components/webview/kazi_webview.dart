import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_circular_button.dart';
import 'package:kazi_core/shared/components/buttons/kazi_pill_button.dart';
import 'package:kazi_core/shared/components/status/kazi_loading.dart';
import 'package:kazi_core/shared/themes/themes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatelessWidget {
  const WebView({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(KaziColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => const KaziLoading(),
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            KaziSpacings.verticalMd,
            _BackButton(text: title),
            KaziSpacings.verticalMd,
          ],
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: KaziColors.background,
        titleSpacing: KaziInsets.lg,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    this.text,
  });
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const KaziCircularButton(
              child: Icon(Icons.chevron_left),
            ),
            KaziSpacings.horizontalSm,
            Visibility(
              visible: text != null,
              child: Text(
                text ?? '',
                style: KaziTextStyles.headlineMd,
              ),
            ),
          ],
        ),
        KaziPillButton(
          onTap: null,
          backgroundColor: context.colorsScheme.onSurface,
          foregroundColor: KaziColors.white,
          child: const Text(''),
        ),
      ],
    );
  }
}
