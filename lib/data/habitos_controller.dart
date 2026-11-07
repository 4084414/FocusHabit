import 'package:flutter/material.dart';

/// Controlador singleton para gestionar la lista de hábitos y su estado de completado.
class HabitosController extends ChangeNotifier {
  static final HabitosController instance = HabitosController._();
  HabitosController._();

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

  List<Map<String, String>> get habits => _habits;

  int get totalHabitos => _habits.length;

  int get habitosCompletados =>
      _habits.where((h) => h['completed'] == 'true').length;

  double get progreso =>
      totalHabitos > 0 ? habitosCompletados / totalHabitos : 0.0;

  /// Devuelve los 3 primeros hábitos que aún no han sido completados.
  List<Map<String, String>> get primerosTresSinCompletar =>
      _habits.where((h) => h['completed'] != 'true').take(3).toList();

  void addHabito(Map<String, String> habito) {
    _habits.add(habito);
    notifyListeners();
  }

  void updateHabito(int index, Map<String, String> habito) {
    if (index >= 0 && index < _habits.length) {
      _habits[index] = habito;
      notifyListeners();
    }
  }

  void removeHabitoAt(int index) {
    if (index >= 0 && index < _habits.length) {
      _habits.removeAt(index);
      notifyListeners();
    }
  }

  void insertHabito(int index, Map<String, String> habito) {
    _habits.insert(index, habito);
    notifyListeners();
  }

  void toggleCompletado(Map<String, String> habito) {
    final isCompleted = habito['completed'] == 'true';
    habito['completed'] = isCompleted ? 'false' : 'true';
    notifyListeners();
  }

  void toggleCompletadoAt(int index) {
    if (index >= 0 && index < _habits.length) {
      final isCompleted = _habits[index]['completed'] == 'true';
      _habits[index]['completed'] = isCompleted ? 'false' : 'true';
      notifyListeners();
    }
  }

  /// Helper para obtener icono según la categoría
  static IconData getIconForCategory(String? category) {
    switch (category) {
      case 'Ergonomics':
        return Icons.chair_alt;
      case 'Eye Care':
        return Icons.visibility;
      case 'Hydration':
        return Icons.water_drop;
      case 'Focus':
        return Icons.psychology;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Sleep':
        return Icons.bedtime;
      default:
        return Icons.check_circle_outline;
    }
  }
}
