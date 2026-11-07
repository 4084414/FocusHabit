import 'package:flutter/material.dart';

import 'pantallas/1hoy.dart'; // Asegúrate de ajustar la ruta de importación según tu estructura de carpetas

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
    return MaterialApp(
      title: 'Focus Habit',
      debugShowCheckedModeBanner: false,
      theme: FocusHabitTheme.light,
      darkTheme: FocusHabitTheme.dark,
      themeMode:
          ThemeMode.system, // Cambia automáticamente según el modo del sistema
      home: const PantallaHoy(),
    );
  }
}
