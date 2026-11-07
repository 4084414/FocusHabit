import 'package:flutter/material.dart';
import 'package:focushabit/data/theme_controller.dart';

import 'pantallas/1hoy.dart';

/// Clase abstracta y final encargada de centralizar la definición
/// y personalización de los temas visuales (Claro y Oscuro) de la aplicación.
abstract final class FocusHabitTheme {
  // Color base (semilla) utilizado por Material 3 para generar toda la paleta de colores.
  static const Color _colorSemilla = Color(0xFF2E7D6B);

  // Definición estática del tema claro de la app.
  static final ThemeData claro = _construirTema(Brightness.light);

  // Definición estática del tema oscuro de la app.
  static final ThemeData oscuro = _construirTema(Brightness.dark);

  /// Método auxiliar privado para construir un [ThemeData] basado en el brillo (claro u oscuro).
  static ThemeData _construirTema(Brightness brillo) {
    // Genera automáticamente una paleta de colores coherente a partir del color semilla.
    final esquemaColores = ColorScheme.fromSeed(
      seedColor: _colorSemilla,
      brightness: brillo,
    );

    // Retorna la configuración completa del tema para Material 3.
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquemaColores,
      scaffoldBackgroundColor: esquemaColores.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: esquemaColores.surface,
        foregroundColor: esquemaColores.onSurface,
        elevation: 0, // Sin sombra por defecto en la barra superior
      ),
    );
  }
}

void main() {
  // Punto de entrada de la aplicación Flutter.
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder escucha los cambios en el controlador del tema
    // para reconstruir MaterialApp automáticamente cuando este cambie.
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Focus Habit',
          debugShowCheckedModeBanner: false,
          theme: FocusHabitTheme.claro, // Asigna el tema claro personalizado
          darkTheme:
              FocusHabitTheme.oscuro, // Asigna el tema oscuro personalizado
          themeMode: ThemeController
              .instance
              .modoTema, // Controla qué tema se muestra actualmente
          home: const PantallaHoy(), // Pantalla inicial de la app
        );
      },
    );
  }
}
