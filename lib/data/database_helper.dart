import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Acceso único a la base de datos SQLite de FocusHabit.
/// Uso: final db = await DatabaseHelper.instance.database;
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'focushabit.db';
  static const _dbVersion = 1;
  static const _schemaAsset = 'assets/db/focushabit_schema.sql';

  static Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      // Activa las claves foráneas (SQLite las desactiva por defecto).
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      // Solo se ejecuta la primera vez que se crea el archivo .db.
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final script = await rootBundle.loadString(_schemaAsset);

    // Quita comentarios de línea completa y separa por ';'.
    final sentencias = script
        .split('\n')
        .where((l) => !l.trimLeft().startsWith('--'))
        .join('\n')
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !s.toUpperCase().startsWith('PRAGMA'));

    final batch = db.batch();
    for (final s in sentencias) {
      batch.execute(s);
    }
    await batch.commit(noResult: true);
  }


  String _hoy() => DateTime.now().toIso8601String().substring(0, 10);

  /// Suma cantidad a un hábito hoy (también para «Marca dos vasos de agua»).
  Future<int> registrar(int habitoId, {int cantidad = 1}) async {
    final db = await database;
    return db.insert('registro', {
      'habito_id': habitoId,
      'fecha': _hoy(),
      'cantidad': cantidad,
    });
  }

  /// Guarda una alerta: 'postura' o 'descanso_visual'.
  Future<int> guardarAlerta(String tipo) async {
    final db = await database;
    return db.insert('alerta', {'tipo': tipo}); // fecha: valor por defecto
  }

  /// Progreso de hoy: SUM(cantidad) frente a meta (pantalla Hoy).
  Future<List<Map<String, Object?>>> progresoHoy() async {
    final db = await database;
    return db.rawQuery('''
      SELECT h.id, h.nombre, c.color, h.meta_diaria,
             COALESCE(SUM(r.cantidad), 0) AS total_hoy
      FROM habito h
      JOIN categoria c ON c.id = h.categoria_id
      LEFT JOIN registro r ON r.habito_id = h.id AND r.fecha = ?
      GROUP BY h.id
      ORDER BY c.nombre, h.nombre
    ''', [_hoy()]);
  }

  /// Racha actual (días consecutivos cumplidos) de un hábito.
  Future<int> rachaActual(int habitoId) async {
    final db = await database;
    final res = await db.rawQuery('''
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
    ''', [habitoId, habitoId]);
    return res.isEmpty ? 0 : res.first['dias'] as int;
  }
}
