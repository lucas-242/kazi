import 'dart:convert';
import 'dart:io';

/// Generates a static page per language based on `tool/template.html` and the
/// dictionaries in `l10n/`. The first language in the list is the default and goes to the
/// root; the others go to a folder named after their code (`en/`, `es/`).
const List<String> locales = ['pt', 'en', 'es'];

/// Public URL for each environment. It goes into `canonical`, `og:url` and the
/// `hreflang` tags. Publishing one environment with another's URL makes search
/// engines index the wrong address, so every deploy generates its own.
const Map<String, String> environments = {
  'staging': 'https://kazi-clients-staging.web.app',
  'prod': 'https://kazipro.io',
};

/// Marker for an environment that doesn't have a URL yet; generating with it fails.
const String undefinedUrl = 'https://DEFINA-O-DOMINIO';

const String defaultEnvironment = 'staging';

/// The pages generated for every language: the template each one comes from and
/// the folder it lands in, inside that language's folder.
///
/// `policy` is the address the app links to (`AppUrls.privacyPolicy`); moving it
/// breaks the link on every version already on Play.
enum _Page {
  home('tool/template.html', ''),
  policy('tool/policy.html', 'policy-privacy/');

  const _Page(this.template, this.directory);

  final String template;
  final String directory;
}

/// The policy text is the app's own, read from the `kazi_core` ARBs, so the web
/// version cannot drift from what the app shows. A key listed here but missing
/// from an ARB fails the build.
const String arbDirectory = '../kazi_core/lib/shared/l10n/arb';

const List<String> appKeys = [
  'contactEmail',
  'privacyPolicy',
  'privacyUpdatedOn',
  'privacySummaryStoredTitle',
  'privacySummaryStored',
  'privacySummaryNeverTitle',
  'privacySummaryNever',
  'privacySummaryControlTitle',
  'privacySummaryControl',
  'privacySummaryDeleteTitle',
  'privacySummaryDelete',
  'privacyPoliceStart',
  'privacyPoliceInformationTitle',
  'privacyPoliceInformation',
  'privacyPoliceInformation1',
  'privacyPoliceInformation2',
  'privacyPoliceInformation3',
  'privacyPoliceInformation4',
  'privacyPoliceInformation5',
  'privacyPoliceInformation6',
  'privacyPoliceAnalyticsTitle',
  'privacyPoliceAnalytics',
  'privacyPoliceReplayTitle',
  'privacyPoliceReplay',
  'privacyPoliceRightsTitle',
  'privacyPoliceRights',
  'privacyPoliceRetentionTitle',
  'privacyPoliceRetention',
  'privacyPoliceLogDataTitle',
  'privacyPoliceLogData',
  'privacyPoliceCookiesTitle',
  'privacyPoliceCookies',
  'privacyPoliceServicesTitle',
  'privacyPoliceServices',
  'privacyPoliceSecurityTitle',
  'privacyPoliceSecurity',
  'pricayPoliceLinksTitle',
  'pricayPoliceLinks',
  'privacyPoliceChildrenTitle',
  'privacyPoliceChildren',
  'privacyPoliceChangesTitle',
  'privacyPoliceChanges',
  'privacyPoliceContactTitle',
  'privacyPoliceContact',
];

/// The app formats this date at runtime; the site has no formatter, so each
/// dictionary carries it already written out.
const String updatedAtKey = 'policyUpdatedAt';

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

  final Map<_Page, String> templates = {
    for (final _Page page in _Page.values)
      page: File('${root.path}/${page.template}').readAsStringSync(),
  };

  final Map<String, _Locale> loaded = {
    for (final String code in locales) code: _Locale.read(root, code),
  };

  for (final String code in locales) {
    final _Locale locale = loaded[code]!;
    final Map<String, String> app = _appStrings(root, locale);

    for (final _Page page in _Page.values) {
      final _Output output = _Output(page, locale);
      final Map<String, String> values = {
        ...locale.strings,
        ...app,
        '_lang': locale.lang,
        '_ogLocale': locale.ogLocale,
        '_assets': '${output.toRoot}assets/',
        '_home': output.linkTo(_Output(_Page.home, locale)),
        '_policy': output.linkTo(_Output(_Page.policy, locale)),
        '_canonical': output.canonical(siteUrl),
        '_alternates': _alternates(loaded, page, siteUrl),
        '_langSwitch': _langSwitch(loaded, output),
      };

      final File out = File('${root.path}/${output.path}');
      out.parent.createSync(recursive: true);
      out.writeAsStringSync(_render(templates[page]!, values, code));
      stdout.writeln('${output.path}  ·  ${locale.lang}');
    }
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

Map<String, String> _appStrings(Directory root, _Locale locale) {
  final File file = File('${root.path}/$arbDirectory/intl_${locale.code}.arb');
  if (!file.existsSync()) {
    throw StateError('ARB do app não encontrada: ${file.path}');
  }
  final Map<String, dynamic> arb =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  final String updatedAt =
      locale.strings[updatedAtKey] ??
      (throw StateError(
        '${locale.code}: chave ausente no dicionário: $updatedAtKey',
      ));

  final Map<String, String> values = {};
  for (final String key in appKeys) {
    final dynamic value = arb[key];
    if (value is! String) {
      throw StateError('${locale.code}: chave ausente na ARB do app: $key');
    }
    final String text = value.replaceAll('{date}', updatedAt);
    values[key] = text;
    values['_$key'] = _paragraphs(text);
  }
  return values;
}

/// Turns an ARB string into HTML paragraphs. The app renders each line break as
/// a new block, and so does the site.
String _paragraphs(String text) => text
    .split('\n')
    .map((String line) => line.trim())
    .where((String line) => line.isNotEmpty)
    .map((String line) => '<p>${_escape(line)}</p>')
    .join('\n');

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

String _alternates(Map<String, _Locale> loaded, _Page page, String siteUrl) {
  final List<String> lines = [
    for (final String code in locales)
      '<link rel="alternate" hreflang="${loaded[code]!.lang}" '
          'href="${_Output(page, loaded[code]!).canonical(siteUrl)}">',
    '<link rel="alternate" hreflang="x-default" '
        'href="${_Output(page, loaded[locales.first]!).canonical(siteUrl)}">',
  ];
  return lines.join('\n');
}

String _langSwitch(Map<String, _Locale> loaded, _Output current) {
  final List<String> links = [
    for (final String code in locales)
      _link(
        current,
        _Output(current.page, loaded[code]!),
        isCurrent: code == current.locale.code,
      ),
  ];
  return '<div class="lang-switch" role="group" '
      'aria-label="${_escape(current.locale.strings['langSwitchLabel']!)}">'
      '${links.join()}</div>';
}

String _link(_Output from, _Output target, {required bool isCurrent}) {
  final _Locale locale = target.locale;
  return '<a href="${from.linkTo(target)}" hreflang="${locale.lang}" '
      'lang="${locale.lang}" aria-label="${_escape(locale.name)}"'
      '${isCurrent ? ' aria-current="page"' : ''}>'
      '${_escape(locale.shortLabel)}</a>';
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
}

/// One generated file: a page in a language, and every address that depends on
/// where it sits in the tree.
class _Output {
  const _Output(this.page, this.locale);

  final _Page page;
  final _Locale locale;

  String get directory =>
      '${locale.isDefault ? '' : '${locale.code}/'}${page.directory}';

  String get path => '${directory}index.html';

  /// Relative prefix from this page back to the site root.
  String get toRoot => '../' * '/'.allMatches(directory).length;

  String canonical(String siteUrl) => '$siteUrl/$directory';

  /// Relative link from this page to another one, so the pages also work opened
  /// straight from disk.
  String linkTo(_Output target) {
    final List<String> here = _segments(directory);
    final List<String> there = _segments(target.directory);
    int shared = 0;
    while (shared < here.length &&
        shared < there.length &&
        here[shared] == there[shared]) {
      shared++;
    }
    final String up = '../' * (here.length - shared);
    final String down = there.skip(shared).map((String s) => '$s/').join();
    return '$up${down}index.html';
  }

  List<String> _segments(String directory) => directory
      .split('/')
      .where((String segment) => segment.isNotEmpty)
      .toList();
}
