import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'database_helper.dart';

/// Controlador singleton para gestionar la lista de hábitos, su estado de completado
/// y los cálculos derivados (progreso, filtros, iconos).
class HabitosController extends ChangeNotifier {
  // Patrón Singleton para mantener una única instancia compartida en toda la aplicación.
  static final HabitosController instance = HabitosController._();
  HabitosController._();

  // Lista en memoria que refleja la tabla `habito` de SQLite.
  // Cada mapa lleva además la clave 'id' (id de la fila en la base de datos).
  final List<Map<String, String>> _habitos = [];

  /// Carga los hábitos (y su estado de hoy) desde la base de datos.
  /// Se llama una vez al arrancar la app, antes de runApp.
  Future<void> cargar() async {
    try {
      final filas = await DatabaseHelper.instance.cargarHabitos();
      _habitos
        ..clear()
        ..addAll(filas);
    } catch (error) {
      debugPrint('No se pudo cargar la base de datos: $error');
    }
    notifyListeners();
  }

  // Ejecuta una escritura en SQLite sin bloquear la interfaz.
  void _guardar(Future<void> Function() accion) {
    unawaited(
      accion().catchError(
        (Object error) => debugPrint('Error al guardar en SQLite: $error'),
      ),
    );
  }

  // Extrae la meta diaria numérica del texto de objetivo ("3 veces al día").
  static int _metaDe(String? objetivo) {
    final coincidencia = RegExp(r'\d+').firstMatch(objetivo ?? '');
    final valor = int.tryParse(coincidencia?.group(0) ?? '') ?? 1;
    return math.max(1, valor);
  }

  static int? _idDe(Map<String, String> habito) => int.tryParse(habito['id'] ?? '');

  // Inserta el hábito en SQLite y guarda su id en el mapa.
  Future<void> _insertarEnBd(Map<String, String> habito) async {
    final id = await DatabaseHelper.instance.insertarHabito(
      titulo: habito['titulo'] ?? '',
      categoria: habito['categoria'] ?? 'Ergonomía',
      metaDiaria: _metaDe(habito['objetivo']),
    );
    habito['id'] = '$id';
    if (habito['completado'] == 'true') {
      await DatabaseHelper.instance.fijarCompletadoHoy(id, true);
    }
  }

  // Guarda en SQLite el estado de completado de un hábito.
  void _guardarCompletado(Map<String, String> habito) {
    final id = _idDe(habito);
    if (id == null) return;
    final completado = habito['completado'] == 'true';
    _guardar(() => DatabaseHelper.instance.fijarCompletadoHoy(id, completado));
  }

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
    _guardar(() => _insertarEnBd(habito));
  }

  // Actualiza un hábito existente en una posición específica.
  void actualizarHabito(int indice, Map<String, String> habito) {
    if (indice >= 0 && indice < _habitos.length) {
      final anterior = _habitos[indice];
      final id = _idDe(anterior);
      if (id != null) habito['id'] = '$id';
      _habitos[indice] = habito;
      notifyListeners();
      if (id != null) {
        _guardar(() async {
          await DatabaseHelper.instance.actualizarHabito(
            id,
            titulo: habito['titulo'] ?? '',
            categoria: habito['categoria'] ?? 'Ergonomía',
            metaDiaria: _metaDe(habito['objetivo']),
          );
          // Solo toca los registros si el usuario cambió el estado de completado.
          if (anterior['completado'] != habito['completado']) {
            await DatabaseHelper.instance.fijarCompletadoHoy(
              id,
              habito['completado'] == 'true',
            );
          }
        });
      }
    }
  }

  // Elimina un hábito según su índice.
  void eliminarHabitoEnIndice(int indice) {
    if (indice >= 0 && indice < _habitos.length) {
      final eliminado = _habitos.removeAt(indice);
      notifyListeners();
      final id = _idDe(eliminado);
      if (id != null) _guardar(() => DatabaseHelper.instance.eliminarHabito(id));
    }
  }

  // Inserta un hábito en una posición específica.
  void insertarHabito(int indice, Map<String, String> habito) {
    _habitos.insert(indice, habito);
    notifyListeners();
    _guardar(() => _insertarEnBd(habito)); // vuelve a crearlo en la BD
  }

  // Alterna el estado de completado (true/false) pasando el mapa del hábito.
  void alternarCompletado(Map<String, String> habito) {
    final estaCompletado = habito['completado'] == 'true';
    habito['completado'] = estaCompletado ? 'false' : 'true';
    notifyListeners();
    _guardarCompletado(habito);
  }

  // Alterna el estado de completado mediante el índice del hábito
  void alternarCompletadoEnIndice(int indice) {
    if (indice >= 0 && indice < _habitos.length) {
      final estaCompletado = _habitos[indice]['completado'] == 'true';
      _habitos[indice]['completado'] = estaCompletado ? 'false' : 'true';
      notifyListeners();
      _guardarCompletado(_habitos[indice]);
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
