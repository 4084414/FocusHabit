import 'package:flutter/material.dart';
import 'package:focushabit/data/theme_controller.dart';

import 'pantallas/1hoy.dart';

abstract final class FocusHabitTheme {
  static const Color _seedColor = Color(0xFF2E7D6B);

  static final ThemeData light = _buildTheme(Brightness.light);
  static final ThemeData dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Focus Habit',
          debugShowCheckedModeBanner: false,
          theme: FocusHabitTheme.light,
          darkTheme: FocusHabitTheme.dark,
          themeMode: ThemeController.instance.themeMode, // <--- Conectado aquí
          home: const PantallaHoy(),
        );
      },
    );
  }
}
