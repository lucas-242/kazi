import 'dart:convert';
import 'dart:io';

/// Generates a static page per language based on `tool/template.html` and the
/// dictionaries in `l10n/`. The first language in the list is the default and goes to the
/// root; the others go to a folder named after their code (`en/`, `es/`).
const List<String> locales = ['pt', 'en', 'es'];

/// Public URL for each environment — this is what goes into `canonical`, `og:url`, and
/// `hreflang` tags. Publishing to one environment using another's URL causes search engines
/// to index the wrong address, so each deployment generates its own.
const Map<String, String> environments = {
  'staging': 'https://kazi-clients-staging.web.app',
  'prod': undefinedUrl,
};

/// Marker for an environment that doesn't have a URL yet; generating with it fails.
const String undefinedUrl = 'https://DEFINA-O-DOMINIO';

const String defaultEnvironment = 'staging';

void main(List<String> args) {
  try {
    _build(args);
  } on StateError catch (error) {
    stderr.writeln('kazi_landing: ${error.message}');
    exitCode = 1;
  }
}

void _build(List<String> args) {
  final String siteUrl = _stripTrailingSlash(_resolveSiteUrl(args));
  final Directory root = _packageRoot();
  final String template = File(
    '${root.path}/tool/template.html',
  ).readAsStringSync();

  final Map<String, _Locale> loaded = {
    for (final String code in locales) code: _Locale.read(root, code),
  };

  for (final String code in locales) {
    final _Locale locale = loaded[code]!;
    final Map<String, String> values = {
      ...locale.strings,
      '_lang': locale.lang,
      '_ogLocale': locale.ogLocale,
      '_assets': locale.isDefault ? 'assets/' : '../assets/',
      '_canonical': locale.canonical(siteUrl),
      '_alternates': _alternates(loaded, siteUrl),
      '_langSwitch': _langSwitch(loaded, locale),
    };

    final File out = File('${root.path}/${locale.outputPath}');
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(_render(template, values, code));
    stdout.writeln('${locale.outputPath}  ·  ${locale.lang}');
  }

  stdout.writeln('site: $siteUrl');
}

String _resolveSiteUrl(List<String> args) {
  final String? override = _argValue(args, '--site-url');
  if (override != null) return _validated(override, '--site-url');

  final String env = _argValue(args, '--env') ?? defaultEnvironment;
  final String? url = environments[env];
  if (url == null) {
    throw StateError(
      'ambiente desconhecido: $env (use ${environments.keys.join(' ou ')})',
    );
  }
  return _validated(url, 'environments[\'$env\']');
}

String _validated(String url, String origin) {
  if (url == undefinedUrl) {
    throw StateError('defina a URL do ambiente em tool/build.dart ($origin)');
  }
  final Uri? parsed = Uri.tryParse(url);
  if (parsed?.scheme != 'https' || !(parsed?.host ?? '').contains('.')) {
    throw StateError('$origin não é uma URL https válida: $url');
  }
  return url;
}

String _render(String template, Map<String, String> values, String code) {
  final String rendered = template.replaceAllMapped(
    RegExp(r'\{\{([A-Za-z_][A-Za-z0-9_]*)\}\}'),
    (Match match) {
      final String key = match[1]!;
      final String? value = values[key];
      if (value == null) {
        throw StateError('$code: chave ausente no dicionário: $key');
      }
      return key.startsWith('_') ? value : _escape(value);
    },
  );
  final RegExpMatch? leftover = RegExp(r'\{\{.*?\}\}').firstMatch(rendered);
  if (leftover != null) {
    throw StateError('$code: placeholder não resolvido: ${leftover[0]}');
  }
  return rendered;
}

String _alternates(Map<String, _Locale> loaded, String siteUrl) {
  final List<String> lines = [
    for (final String code in locales)
      '<link rel="alternate" hreflang="${loaded[code]!.lang}" '
          'href="${loaded[code]!.canonical(siteUrl)}">',
    '<link rel="alternate" hreflang="x-default" '
        'href="${loaded[locales.first]!.canonical(siteUrl)}">',
  ];
  return lines.join('\n');
}

String _langSwitch(Map<String, _Locale> loaded, _Locale current) {
  final String prefix = current.isDefault ? '' : '../';
  final List<String> links = [
    for (final String code in locales)
      _link(loaded[code]!, prefix, isCurrent: code == current.code),
  ];
  return '<div class="lang-switch" role="group" '
      'aria-label="${_escape(current.strings['langSwitchLabel']!)}">'
      '${links.join()}</div>';
}

String _link(_Locale target, String prefix, {required bool isCurrent}) {
  final String href = target.isDefault
      ? '${prefix}index.html'
      : '$prefix${target.code}/index.html';
  return '<a href="$href" hreflang="${target.lang}" lang="${target.lang}" '
      'aria-label="${_escape(target.name)}"'
      '${isCurrent ? ' aria-current="page"' : ''}>'
      '${_escape(target.shortLabel)}</a>';
}

String _escape(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

Directory _packageRoot() =>
    File.fromUri(Platform.script).parent.parent.absolute;

String? _argValue(List<String> args, String name) {
  for (final String arg in args) {
    if (arg.startsWith('$name=')) return arg.substring(name.length + 1);
  }
  return null;
}

String _stripTrailingSlash(String url) =>
    url.endsWith('/') ? url.substring(0, url.length - 1) : url;

class _Locale {
  const _Locale({
    required this.code,
    required this.lang,
    required this.ogLocale,
    required this.name,
    required this.shortLabel,
    required this.strings,
  });

  factory _Locale.read(Directory root, String code) {
    final File file = File('${root.path}/l10n/$code.json');
    if (!file.existsSync()) {
      throw StateError('dicionário não encontrado: ${file.path}');
    }
    final Map<String, dynamic> json =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return _Locale(
      code: code,
      lang: json['lang'] as String,
      ogLocale: json['ogLocale'] as String,
      name: json['name'] as String,
      shortLabel: json['code'] as String,
      strings: (json['strings'] as Map<String, dynamic>).map(
        (String key, dynamic value) => MapEntry(key, value as String),
      ),
    );
  }

  final String code;
  final String lang;
  final String ogLocale;
  final String name;
  final String shortLabel;
  final Map<String, String> strings;

  bool get isDefault => code == locales.first;

  String get outputPath => isDefault ? 'index.html' : '$code/index.html';

  String canonical(String siteUrl) =>
      isDefault ? '$siteUrl/' : '$siteUrl/$code/';
}
