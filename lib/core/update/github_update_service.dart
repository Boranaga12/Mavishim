import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GithubUpdateRelease {
  final String versionTag;
  final String apkUrl;
  final String apkName;
  final String releaseName;
  final String releaseNotes;
  final String? sha256;

  const GithubUpdateRelease({
    required this.versionTag,
    required this.apkUrl,
    required this.apkName,
    required this.releaseName,
    required this.releaseNotes,
    this.sha256,
  });
}

class GithubUpdateCheck {
  final bool updateRequired;
  final String currentVersion;
  final GithubUpdateRelease? release;

  const GithubUpdateCheck.current(this.currentVersion)
    : updateRequired = false,
      release = null;

  const GithubUpdateCheck.required(this.currentVersion, this.release)
    : updateRequired = true;
}

class GithubUpdateService {
  static const _latestReleaseUrl =
      'https://api.github.com/repos/Boranaga12/Mavishim/releases/latest';
  static const _cachedTagKey = 'required_update_tag';
  static const _cachedUrlKey = 'required_update_url';
  static const _cachedNameKey = 'required_update_apk_name';
  static const _cachedTitleKey = 'required_update_title';
  static const _cachedNotesKey = 'required_update_notes';
  static const _cachedShaKey = 'required_update_sha256';

  final http.Client _client;

  GithubUpdateService({http.Client? client})
    : _client = client ?? http.Client();

  Future<GithubUpdateCheck> check() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentText = '${packageInfo.version}+${packageInfo.buildNumber}';
    final current = _AppVersion.parse(currentText);
    final preferences = await SharedPreferences.getInstance();

    final cached = _readCachedRelease(preferences);
    if (cached != null) {
      if (_AppVersion.parse(cached.versionTag).compareTo(current) > 0) {
        return GithubUpdateCheck.required(currentText, cached);
      }
      await _clearCachedRelease(preferences);
    }

    try {
      final response = await _client
          .get(
            Uri.parse(_latestReleaseUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
              'User-Agent': 'Mavishim-Android-Updater',
            },
          )
          .timeout(const Duration(seconds: 12));

      // No release has been published yet. This keeps development builds usable
      // until the first APK is attached to a GitHub Release.
      if (response.statusCode == 404) {
        return GithubUpdateCheck.current(currentText);
      }
      if (response.statusCode != 200) {
        throw StateError('GitHub yanıt kodu: ${response.statusCode}');
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final release = _releaseFromPayload(payload);
      if (_AppVersion.parse(release.versionTag).compareTo(current) <= 0) {
        await _clearCachedRelease(preferences);
        return GithubUpdateCheck.current(currentText);
      }

      await _cacheRelease(preferences, release);
      return GithubUpdateCheck.required(currentText, release);
    } catch (_) {
      // Forced updates must not be bypassed by disabling the connection. The
      // gate keeps the app locked until GitHub can confirm the latest release.
      rethrow;
    }
  }

  GithubUpdateRelease _releaseFromPayload(Map<String, dynamic> payload) {
    final tag = (payload['tag_name'] as String? ?? '').trim();
    if (tag.isEmpty) throw const FormatException('Sürüm etiketi bulunamadı.');

    final assets = (payload['assets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .where((asset) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          return name.endsWith('.apk');
        })
        .toList();
    if (assets.isEmpty) {
      throw const FormatException('GitHub Release içinde APK bulunamadı.');
    }
    assets.sort((a, b) {
      int priority(Map<String, dynamic> asset) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.contains('mavishim') || name.contains('universal')) return 0;
        return 1;
      }

      return priority(a).compareTo(priority(b));
    });
    final asset = assets.first;
    final apkUrl = (asset['browser_download_url'] as String? ?? '').trim();
    final uri = Uri.tryParse(apkUrl);
    if (!_isTrustedGithubDownload(uri)) {
      throw const FormatException('Güvenli GitHub APK adresi bulunamadı.');
    }

    final digest = asset['digest'] as String?;
    final sha256 = digest?.startsWith('sha256:') == true
        ? digest!.substring('sha256:'.length)
        : null;
    return GithubUpdateRelease(
      versionTag: tag,
      apkUrl: apkUrl,
      apkName: (asset['name'] as String? ?? 'mavishim.apk').trim(),
      releaseName: (payload['name'] as String? ?? tag).trim(),
      releaseNotes: (payload['body'] as String? ?? '').trim(),
      sha256: sha256,
    );
  }

  GithubUpdateRelease? _readCachedRelease(SharedPreferences preferences) {
    final tag = preferences.getString(_cachedTagKey);
    final url = preferences.getString(_cachedUrlKey);
    if (tag == null || url == null) return null;
    if (!_isTrustedGithubDownload(Uri.tryParse(url))) return null;
    return GithubUpdateRelease(
      versionTag: tag,
      apkUrl: url,
      apkName: preferences.getString(_cachedNameKey) ?? 'mavishim.apk',
      releaseName: preferences.getString(_cachedTitleKey) ?? tag,
      releaseNotes: preferences.getString(_cachedNotesKey) ?? '',
      sha256: preferences.getString(_cachedShaKey),
    );
  }

  Future<void> _cacheRelease(
    SharedPreferences preferences,
    GithubUpdateRelease release,
  ) async {
    await preferences.setString(_cachedTagKey, release.versionTag);
    await preferences.setString(_cachedUrlKey, release.apkUrl);
    await preferences.setString(_cachedNameKey, release.apkName);
    await preferences.setString(_cachedTitleKey, release.releaseName);
    await preferences.setString(_cachedNotesKey, release.releaseNotes);
    if (release.sha256 == null) {
      await preferences.remove(_cachedShaKey);
    } else {
      await preferences.setString(_cachedShaKey, release.sha256!);
    }
  }

  Future<void> _clearCachedRelease(SharedPreferences preferences) async {
    await Future.wait([
      preferences.remove(_cachedTagKey),
      preferences.remove(_cachedUrlKey),
      preferences.remove(_cachedNameKey),
      preferences.remove(_cachedTitleKey),
      preferences.remove(_cachedNotesKey),
      preferences.remove(_cachedShaKey),
    ]);
  }

  void dispose() => _client.close();

  bool _isTrustedGithubDownload(Uri? uri) {
    if (uri == null || uri.scheme != 'https') return false;
    return uri.host == 'github.com' || uri.host.endsWith('.github.com');
  }
}

class _AppVersion implements Comparable<_AppVersion> {
  final List<int> parts;
  final int build;

  const _AppVersion(this.parts, this.build);

  factory _AppVersion.parse(String value) {
    var cleaned = value.trim().toLowerCase();
    if (cleaned.startsWith('v')) cleaned = cleaned.substring(1);
    final pieces = cleaned.split('+');
    final versionParts = pieces.first
        .split('.')
        .map(
          (part) =>
              int.tryParse(RegExp(r'\d+').firstMatch(part)?.group(0) ?? '') ??
              0,
        )
        .toList();
    while (versionParts.length < 3) {
      versionParts.add(0);
    }
    final build = pieces.length > 1 ? int.tryParse(pieces[1]) ?? 0 : 0;
    return _AppVersion(versionParts, build);
  }

  @override
  int compareTo(_AppVersion other) {
    final length = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;
    for (var index = 0; index < length; index++) {
      final left = index < parts.length ? parts[index] : 0;
      final right = index < other.parts.length ? other.parts[index] : 0;
      if (left != right) return left.compareTo(right);
    }
    return build.compareTo(other.build);
  }
}
