import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/cycle_provider.dart';
import 'providers/game_provider.dart';
import 'providers/tap_effects_provider.dart';
import 'views/main_navigation.dart';
import 'widgets/mobile_frame_wrapper.dart';
import 'widgets/security_lock_screen.dart';
import 'data/repositories/app_repository.dart';
import 'data/repositories/secure_local_repository.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MavishimBootstrap());
}

class MavishimBootstrap extends StatefulWidget {
  const MavishimBootstrap({super.key});

  @override
  State<MavishimBootstrap> createState() => _MavishimBootstrapState();
}

class _MavishimBootstrapState extends State<MavishimBootstrap> {
  late Future<(AppRepository, AppDataSnapshot)> _initialization;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _initialization = () async {
      final repository = await SecureLocalRepository.create();
      return (repository as AppRepository, await repository.load());
    }();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(AppRepository, AppDataSnapshot)>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MavishimApp(
            repository: snapshot.data!.$1,
            snapshot: snapshot.data!.$2,
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Güvenli veri alanı açılamadı.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cihazın güvenli depolama hizmetini kontrol edip tekrar deneyin.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => setState(_initialize),
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: ColoredBox(color: Colors.black),
        );
      },
    );
  }
}

class MavishimApp extends StatelessWidget {
  final AppRepository repository;
  final AppDataSnapshot snapshot;

  const MavishimApp({
    super.key,
    required this.repository,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CycleProvider(repository, snapshot),
        ),
        ChangeNotifierProvider(
          create: (_) => GameProvider(repository, snapshot),
        ),
        ChangeNotifierProvider(
          create: (_) => TapEffectsProvider(repository, snapshot),
        ),
      ],
      child: MaterialApp(
        title: 'Mavishim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 1,
                maxScaleFactor: 1.6,
              ),
            ),
            child: MobileFrameWrapper(child: SecurityLockScreen(child: child!)),
          );
        },
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('tr'),
        home: const MainNavigationView(),
      ),
    );
  }
}
