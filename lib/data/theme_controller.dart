import 'package:flutter/material.dart';

/// Controlador que gestiona el estado del tema de la aplicación (Claro, Oscuro o Sistema).
/// Extiende de [ChangeNotifier] para notificar a los oyentes cuando el tema cambie.
class ThemeController extends ChangeNotifier {
  // Patrón Singleton: instancia única accesible globalmente desde cualquier parte de la app.
  static final ThemeController instance = ThemeController._();
  ThemeController._();

  // Estado privado que almacena el modo de tema actual (por defecto se adapta al sistema).
  ThemeMode _modoTema = ThemeMode.system;

  // Getter público para consultar el modo de tema actual.
  ThemeMode get modoTema => _modoTema;

  // Getter rápido para verificar si el modo actual es estrictamente oscuro.
  bool get estaEnModoOscuro => _modoTema == ThemeMode.dark;

  /// Cambia el tema entre claro u oscuro de forma binaria (según un booleano).
  void alternarTema(bool oscuro) {
    _modoTema = oscuro ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifica a los widgets suscritos para que se redibujen con el nuevo tema.
  }

  /// Permite establecer un [ThemeMode] específico (Claro u Oscuro).
  void establecerModoTema(ThemeMode modo) {
    _modoTema = modo;
    notifyListeners(); // Notifica el cambio de estado a toda la aplicación.
  }
}
