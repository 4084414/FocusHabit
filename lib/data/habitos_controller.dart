import 'package:flutter/material.dart';

/// Controlador singleton para gestionar la lista de hábitos, su estado de completado
/// y los cálculos derivados (progreso, filtros, iconos).
class HabitosController extends ChangeNotifier {
  // Patrón Singleton para mantener una única instancia compartida en toda la aplicación.
  static final HabitosController instance = HabitosController._();
  HabitosController._();

  // Lista privada que almacena los hábitos iniciales con sus propiedades.
  final List<Map<String, String>> _habitos = [
    {
      'titulo': 'Postura recta en la silla',
      'objetivo': '1 min cada hora',
      'categoria': 'Ergonomics',
      'completado': 'false',
    },
    {
      'titulo': 'Regla 20-20-20 (descanso visual)',
      'objetivo': '20 seg cada 20 min',
      'categoria': 'Eye Care',
      'completado': 'false',
    },
    {
      'titulo': 'Vaso de agua al despertar',
      'objetivo': '1 vez al día',
      'categoria': 'Hydration',
      'completado': 'false',
    },
    {
      'titulo': 'Pausa activa y estiramientos',
      'objetivo': '3 veces al día',
      'categoria': 'Ergonomics',
      'completado': 'false',
    },
    {
      'titulo': 'Bloque de enfoque profundo (Pomodoro)',
      'objetivo': '4 veces al día',
      'categoria': 'Focus',
      'completado': 'false',
    },
    {
      'titulo': 'Parpadeo consciente e hidratación ocular',
      'objetivo': '5 min al día',
      'categoria': 'Eye Care',
      'completado': 'false',
    },
    {
      'titulo': 'Caminar o subir escaleras',
      'objetivo': '2 veces al día',
      'categoria': 'Fitness',
      'completado': 'false',
    },
    {
      'titulo': 'Beber agua durante la jornada',
      'objetivo': '8 veces al día',
      'categoria': 'Hydration',
      'completado': 'false',
    },
    {
      'titulo': 'Desconectar pantallas antes de dormir',
      'objetivo': '1 vez al día',
      'categoria': 'Sleep',
      'completado': 'false',
    },
    {
      'titulo': 'Ajustar brillo y distancia del monitor',
      'objetivo': '1 vez al día',
      'categoria': 'Ergonomics',
      'completado': 'false',
    },
  ];

  // Getter público para obtener la lista completa de hábitos.
  List<Map<String, String>> get habitos => _habitos;

  // Retorna la cantidad total de hábitos registrados.
  int get totalHabitos => _habitos.length;

  // Cuenta cuántos hábitos tienen el estado 'completed' en 'true'.
  int get habitosCompletados =>
      _habitos.where((habito) => habito['completado'] == 'true').length;

  // Calcula el porcentaje de progreso general (devuelve un valor entre 0.0 y 1.0).
  double get progreso =>
      totalHabitos > 0 ? habitosCompletados / totalHabitos : 0.0;

  /// Devuelve los 3 primeros hábitos que aún no han sido completados.
  List<Map<String, String>> get primerosTresSinCompletar => _habitos
      .where((habito) => habito['completado'] != 'true')
      .take(3)
      .toList();

  // Agrega un nuevo hábito a la lista y notifica a los oyentes.
  void agregarHabito(Map<String, String> habito) {
    _habitos.add(habito);
    notifyListeners();
  }

  // Actualiza un hábito existente en una posición específica.
  void actualizarHabito(int indice, Map<String, String> habito) {
    if (indice >= 0 && indice < _habitos.length) {
      _habitos[indice] = habito;
      notifyListeners();
    }
  }

  // Elimina un hábito según su índice.
  void eliminarHabitoEnIndice(int indice) {
    if (indice >= 0 && indice < _habitos.length) {
      _habitos.removeAt(indice);
      notifyListeners();
    }
  }

  // Inserta un hábito en una posición específica.
  void insertarHabito(int indice, Map<String, String> habito) {
    _habitos.insert(indice, habito);
    notifyListeners();
  }

  // Alterna el estado de completado (true/false) pasando el mapa del hábito.
  void alternarCompletado(Map<String, String> habito) {
    final estaCompletado = habito['completado'] == 'true';
    habito['completado'] = estaCompletado ? 'false' : 'true';
    notifyListeners();
  }

  // Alterna el estado de completado mediante el índice del hábito
  void alternarCompletadoEnIndice(int indice) {
    if (indice >= 0 && indice < _habitos.length) {
      final estaCompletado = _habitos[indice]['completado'] == 'true';
      _habitos[indice]['completado'] = estaCompletado ? 'false' : 'true';
      notifyListeners();
    }
  }

  /// Método auxiliar estático para asignar un icono representativo según la categoría del hábito.
  static IconData obtenerIconoPorCategoria(String? categoria) {
    switch (categoria) {
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
