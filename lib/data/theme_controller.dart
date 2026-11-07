import 'package:flutter/material.dart';

/// Controlador que gestiona el estado del tema de la aplicación (Claro, Oscuro o Sistema).
/// Extiende de [ChangeNotifier] para notificar a los oyentes cuando el tema cambie.
class ThemeController extends ChangeNotifier {
  // Patrón Singleton: instancia única accesible globalmente desde cualquier parte de la app.
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  // Estado privado que almacena el modo de tema actual (por defecto se adapta al sistema).
  ThemeMode _themeMode = ThemeMode.system;

  // Getter público para consultar el modo de tema actual.
  ThemeMode get themeMode => _themeMode;

  // Getter rápido para verificar si el modo actual es estrictamente oscuro.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Cambia el tema entre claro u oscuro de forma binaria (según un booleano).
  void toggleTheme(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifica a los widgets suscritos para que se redibujen con el nuevo tema.
  }

  /// Permite establecer un [ThemeMode] específico (Claro u Oscuro).
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Notifica el cambio de estado a toda la aplicación.
  }
}
