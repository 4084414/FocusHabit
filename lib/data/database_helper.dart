import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Acceso único a la base de datos SQLite de FocusHabit.
/// Uso: final baseDatos = await DatabaseHelper.instance.baseDatos;
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nombreBaseDatos = 'focushabit.db';
  static const _versionBaseDatos = 1;
  static const _rutaEsquema = 'assets/db/focushabit_schema.sql';

  static Database? _baseDatos;

  Future<Database> get baseDatos async => _baseDatos ??= await _abrir();

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreBaseDatos);
    return openDatabase(
      ruta,
      version: _versionBaseDatos,
      // Activa las claves foráneas (SQLite las desactiva por defecto).
      onConfigure: (baseDatos) => baseDatos.execute('PRAGMA foreign_keys = ON'),
      // Solo se ejecuta la primera vez que se crea el archivo .db.
      onCreate: _alCrear,
    );
  }

  Future<void> _alCrear(Database baseDatos, int version) async {
    final esquema = await rootBundle.loadString(_rutaEsquema);

    // Quita comentarios de línea completa y separa por ';'.
    final sentencias = esquema
        .split('\n')
        .where((linea) => !linea.trimLeft().startsWith('--'))
        .join('\n')
        .split(';')
        .map((sentencia) => sentencia.trim())
        .where(
          (sentencia) =>
              sentencia.isNotEmpty &&
              !sentencia.toUpperCase().startsWith('PRAGMA'),
        );

    final lote = baseDatos.batch();
    for (final sentencia in sentencias) {
      lote.execute(sentencia);
    }
    await lote.commit(noResult: true);
  }

  String _hoy() => DateTime.now().toIso8601String().substring(0, 10);

  /// Suma cantidad a un hábito hoy (también para «Marca dos vasos de agua»).
  Future<int> registrar(int habitoId, {int cantidad = 1}) async {
    final baseDatos = await this.baseDatos;
    return baseDatos.insert('registro', {
      'habito_id': habitoId,
      'fecha': _hoy(),
      'cantidad': cantidad,
    });
  }

  /// Guarda una alerta: 'postura' o 'descanso_visual'.
  Future<int> guardarAlerta(String tipo) async {
    final baseDatos = await this.baseDatos;
    return baseDatos.insert('alerta', {
      'tipo': tipo,
    }); // fecha: valor por defecto
  }

  /// Progreso de hoy: SUM(cantidad) frente a meta (pantalla Hoy).
  Future<List<Map<String, Object?>>> progresoHoy() async {
    final baseDatos = await this.baseDatos;
    return baseDatos.rawQuery(
      '''
      SELECT h.id, h.nombre, c.color, h.meta_diaria,
             COALESCE(SUM(r.cantidad), 0) AS total_hoy
      FROM habito h
      JOIN categoria c ON c.id = h.categoria_id
      LEFT JOIN registro r ON r.habito_id = h.id AND r.fecha = ?
      GROUP BY h.id
      ORDER BY c.nombre, h.nombre
    ''',
      [_hoy()],
    );
  }

  /// Racha actual (días consecutivos cumplidos) de un hábito.
  Future<int> rachaActual(int habitoId) async {
    final baseDatos = await this.baseDatos;
    final resultado = await baseDatos.rawQuery(
      '''
      WITH dias AS (
        SELECT fecha, SUM(cantidad) AS total
        FROM registro WHERE habito_id = ? GROUP BY fecha
      ),
      cumplidos AS (
        SELECT d.fecha FROM dias d
        JOIN habito h ON h.id = ? WHERE d.total >= h.meta_diaria
      ),
      grupos AS (
        SELECT fecha,
               julianday(fecha) - ROW_NUMBER() OVER (ORDER BY fecha) AS grp
        FROM cumplidos
      )
      SELECT COUNT(*) AS dias
      FROM grupos GROUP BY grp
      HAVING MAX(fecha) >= date('now', '-1 day', 'localtime')
      ORDER BY MAX(fecha) DESC LIMIT 1
    ''',
      [habitoId, habitoId],
    );
    return resultado.isEmpty ? 0 : resultado.first['dias'] as int;
  }
}
