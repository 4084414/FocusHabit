import 'package:flutter/material.dart';

/// Controlador singleton para gestionar la lista de hábitos, su estado de completado
/// y los cálculos derivados (progreso, filtros, iconos).
class HabitosController extends ChangeNotifier {
  // Patrón Singleton para mantener una única instancia compartida en toda la aplicación.
  static final HabitosController instance = HabitosController._();
  HabitosController._();

  // Lista privada que almacena los hábitos iniciales con sus propiedades.
  final List<Map<String, String>> _habits = [
    {
      'title': 'Postura recta en la silla',
      'target': '1 min cada hora',
      'category': 'Ergonomics',
      'completed': 'false',
    },
    {
      'title': 'Regla 20-20-20 (descanso visual)',
      'target': '20 seg cada 20 min',
      'category': 'Eye Care',
      'completed': 'false',
    },
    {
      'title': 'Vaso de agua al despertar',
      'target': '1 vez al día',
      'category': 'Hydration',
      'completed': 'false',
    },
    {
      'title': 'Pausa activa y estiramientos',
      'target': '3 veces al día',
      'category': 'Ergonomics',
      'completed': 'false',
    },
    {
      'title': 'Bloque de enfoque profundo (Pomodoro)',
      'target': '4 veces al día',
      'category': 'Focus',
      'completed': 'false',
    },
    {
      'title': 'Parpadeo consciente e hidratación ocular',
      'target': '5 min al día',
      'category': 'Eye Care',
      'completed': 'false',
    },
    {
      'title': 'Caminar o subir escaleras',
      'target': '2 veces al día',
      'category': 'Fitness',
      'completed': 'false',
    },
    {
      'title': 'Beber agua durante la jornada',
      'target': '8 veces al día',
      'category': 'Hydration',
      'completed': 'false',
    },
    {
      'title': 'Desconectar pantallas antes de dormir',
      'target': '1 vez al día',
      'category': 'Sleep',
      'completed': 'false',
    },
    {
      'title': 'Ajustar brillo y distancia del monitor',
      'target': '1 vez al día',
      'category': 'Ergonomics',
      'completed': 'false',
    },
  ];

  // Getter público para obtener la lista completa de hábitos.
  List<Map<String, String>> get habits => _habits;

  // Retorna la cantidad total de hábitos registrados.
  int get totalHabitos => _habits.length;

  // Cuenta cuántos hábitos tienen el estado 'completed' en 'true'.
  int get habitosCompletados =>
      _habits.where((h) => h['completed'] == 'true').length;

  // Calcula el porcentaje de progreso general (devuelve un valor entre 0.0 y 1.0).
  double get progreso =>
      totalHabitos > 0 ? habitosCompletados / totalHabitos : 0.0;

  /// Devuelve los 3 primeros hábitos que aún no han sido completados.
  List<Map<String, String>> get primerosTresSinCompletar =>
      _habits.where((h) => h['completed'] != 'true').take(3).toList();

  // Agrega un nuevo hábito a la lista y notifica a los oyentes.
  void addHabito(Map<String, String> habito) {
    _habits.add(habito);
    notifyListeners();
  }

  // Actualiza un hábito existente en una posición específica.
  void updateHabito(int index, Map<String, String> habito) {
    if (index >= 0 && index < _habits.length) {
      _habits[index] = habito;
      notifyListeners();
    }
  }

  // Elimina un hábito según su índice.
  void removeHabitoAt(int index) {
    if (index >= 0 && index < _habits.length) {
      _habits.removeAt(index);
      notifyListeners();
    }
  }

  // Inserta un hábito en una posición específica.
  void insertHabito(int index, Map<String, String> habito) {
    _habits.insert(index, habito);
    notifyListeners();
  }

  // Alterna el estado de completado (true/false) pasando el mapa del hábito.
  void toggleCompletado(Map<String, String> habito) {
    final isCompleted = habito['completed'] == 'true';
    habito['completed'] = isCompleted ? 'false' : 'true';
    notifyListeners();
  }

  // Alterna el estado de completado mediante el índice del hábito
  void toggleCompletadoAt(int index) {
    if (index >= 0 && index < _habits.length) {
      final isCompleted = _habits[index]['completed'] == 'true';
      _habits[index]['completed'] = isCompleted ? 'false' : 'true';
      notifyListeners();
    }
  }

  /// Método auxiliar estático para asignar un icono representativo según la categoría del hábito.
  static IconData getIconForCategory(String? category) {
    switch (category) {
      case 'Ergonomía':
        return Icons.chair_alt;
      case 'Salud visual':
        return Icons.visibility;
      case 'Hidratación':
        return Icons.water_drop;
      case 'Enfoque':
        return Icons.psychology;
      case 'Ejercicio':
        return Icons.fitness_center;
      case 'Sueño':
        return Icons.bedtime;
      default:
        return Icons.check_circle_outline;
    }
  }
}
