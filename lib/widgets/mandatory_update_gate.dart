import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

import '../core/theme/app_theme.dart';
import '../core/update/github_update_service.dart';

class MandatoryUpdateGate extends StatefulWidget {
  final Widget child;

  const MandatoryUpdateGate({super.key, required this.child});

  @override
  State<MandatoryUpdateGate> createState() => _MandatoryUpdateGateState();
}

class _MandatoryUpdateGateState extends State<MandatoryUpdateGate> {
  final GithubUpdateService _service = GithubUpdateService();
  StreamSubscription<OtaEvent>? _updateSubscription;
  GithubUpdateCheck? _check;
  bool _checking = true;
  bool _downloading = false;
  double _progress = 0;
  String _status = 'Güncel sürüm kontrol ediliyor…';
  String? _error;

  bool get _supportsApkUpdate =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_supportsApkUpdate) {
      _checkVersion();
    } else {
      _checking = false;
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }

  Future<void> _checkVersion() async {
    if (mounted) {
      setState(() {
        _checking = true;
        _error = null;
        _status = 'Güncel sürüm kontrol ediliyor…';
      });
    }
    try {
      final result = await _service.check();
      if (!mounted) return;
      setState(() {
        _check = result;
        _checking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _check = null;
        _checking = false;
        _error =
            'Sürüm kontrolü yapılamadı. İnternetini kontrol edip tekrar dene.';
        _status = 'Güncelleme kontrolü gerekli';
      });
    }
  }

  void _startUpdate() {
    final release = _check?.release;
    if (release == null || _downloading) return;
    _updateSubscription?.cancel();
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
      _status = 'Güncelleme indiriliyor…';
    });
    try {
      _updateSubscription = OtaUpdate()
          .execute(
            release.apkUrl,
            destinationFilename: 'mavishim-${release.versionTag}.apk',
            sha256checksum: release.sha256,
          )
          .listen(_handleUpdateEvent, onError: _handleUpdateError);
    } catch (error) {
      _handleUpdateError(error);
    }
  }

  void _handleUpdateEvent(OtaEvent event) {
    if (!mounted) return;
    switch (event.status) {
      case OtaStatus.DOWNLOADING:
        final value = double.tryParse(event.value ?? '') ?? 0;
        setState(() {
          _progress = (value / 100).clamp(0, 1);
          _status = 'Güncelleme indiriliyor: %${value.round()}';
        });
      case OtaStatus.INSTALLING:
        setState(() {
          _progress = 1;
          _status = 'Kurulum ekranından güncellemeyi onayla aşkım.';
        });
      case OtaStatus.INSTALLATION_DONE:
        setState(() => _status = 'Güncelleme tamamlandı. Uygulama açılıyor…');
      case OtaStatus.ALREADY_RUNNING_ERROR:
        setState(() => _status = 'Güncelleme zaten indiriliyor…');
      case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
        _setUpdateError(
          'Android, APK kurulum izni vermedi. “Bu kaynaktan uygulama yükle” iznini açıp tekrar dene.',
        );
      case OtaStatus.CHECKSUM_ERROR:
        _setUpdateError('İndirilen APK doğrulanamadı. Tekrar indir.');
      case OtaStatus.DOWNLOAD_ERROR:
        _setUpdateError(
          'Güncelleme indirilemedi. İnternetini kontrol edip tekrar dene.',
        );
      case OtaStatus.INSTALLATION_ERROR:
        _setUpdateError(
          'Güncelleme kurulamadı. APK’nın aynı imza anahtarıyla üretildiğinden emin ol.',
        );
      case OtaStatus.CANCELED:
        _setUpdateError(
          'Güncelleme iptal edildi. Devam etmek için güncellemelisin.',
        );
      case OtaStatus.INTERNAL_ERROR:
        _setUpdateError(event.value ?? 'Güncelleme sırasında bir hata oluştu.');
    }
  }

  void _handleUpdateError(Object error) {
    if (!mounted) return;
    _setUpdateError('Güncelleme başlatılamadı. Tekrar dene.');
  }

  void _setUpdateError(String message) {
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _error = message;
      _status = 'Güncelleme gerekli';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsApkUpdate ||
        (!_checking && _error == null && _check?.updateRequired != true)) {
      return widget.child;
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: PopScope(
        canPop: false,
        child: Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _checking
                            ? _checkingBody()
                            : _check == null
                            ? _checkFailedBody()
                            : _requiredBody(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkingBody() => const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: 20),
      Text(
        'Güncel sürüm kontrol ediliyor…',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _checkFailedBody() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(
        Icons.cloud_off_rounded,
        size: 64,
        color: AppTheme.primaryPink,
      ),
      const SizedBox(height: 14),
      const Text(
        'Sürüm kontrolü yapılamadı',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 10),
      Text(_error!, textAlign: TextAlign.center),
      const SizedBox(height: 18),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _checkVersion,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tekrar Kontrol Et'),
        ),
      ),
    ],
  );

  Widget _requiredBody() {
    final release = _check!.release!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.system_update_rounded,
          size: 64,
          color: AppTheme.primaryPink,
        ),
        const SizedBox(height: 14),
        const Text(
          'Yeni sürüm hazır aşkım 💗',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          '${_check!.currentVersion} → ${release.versionTag}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          'Uygulamaya devam edebilmek için bu güncellemeyi kurmalısın. Kayıtların, skorların ve döngü verilerin korunacak.',
          textAlign: TextAlign.center,
        ),
        if (release.releaseNotes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: SingleChildScrollView(child: Text(release.releaseNotes)),
          ),
        ],
        const SizedBox(height: 20),
        if (_downloading) ...[
          LinearProgressIndicator(value: _progress == 0 ? null : _progress),
          const SizedBox(height: 10),
        ],
        Text(_status, textAlign: TextAlign.center),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _downloading ? null : _startUpdate,
            icon: const Icon(Icons.download_rounded),
            label: Text(_error == null ? 'Şimdi Güncelle' : 'Tekrar Dene'),
          ),
        ),
      ],
    );
  }
}
