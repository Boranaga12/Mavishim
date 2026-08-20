import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primaryPink = Color(0xFFFF5F78);
  static const secondaryPink = Color(0xFFFF8EB5);
  static const deepPurple = Color(0xFF35113D);
  static const champagneBg = Color(0xFFFFF5F6);
  static const cardBg = Colors.white;
  static const accentPeach = Color(0xFFFFB3C1);
  static const accentGold = Color(0xFFFFD166);
  static const periodColor = Color(0xFFE83E5B);
  static const follicularColor = Color(0xFFE85D92);
  static const ovulationColor = Color(0xFF9A6500);
  static const lutealColor = Color(0xFF7B2CBF);

  static const primaryGradient = LinearGradient(
    colors: [primaryPink, secondaryPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF0F3), Color(0xFFF8E1E7), Color(0xFFFFF8F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    const brightness = Brightness.light;
    const surface = cardBg;
    const scaffold = champagneBg;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryPink,
      brightness: brightness,
      primary: primaryPink,
      secondary: secondaryPink,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      textTheme:
          (brightness == Brightness.dark
                  ? Typography.material2021(
                      platform: TargetPlatform.android,
                    ).white
                  : Typography.material2021(
                      platform: TargetPlatform.android,
                    ).black)
              .apply(
                bodyColor: scheme.onSurface,
                displayColor: scheme.onSurface,
                fontFamily: 'Outfit',
                fontFamilyFallback: const [
                  'Segoe UI',
                  'San Francisco',
                  'Noto Sans',
                  'Segoe UI Emoji',
                  'Apple Color Emoji',
                  'Noto Color Emoji',
                ],
              ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: primaryPink.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
            fontSize: 12,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(48, 48))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }
}
