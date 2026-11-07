import 'package:flutter/foundation.dart';

/// Controlador singleton para gestionar el estado de las rachas de hábitos.
class RachasController extends ChangeNotifier {
  static final RachasController instance = RachasController._();
  RachasController._();

  // Por defecto, racha iniciada hace 4 días (hoy cuenta como el 5º día)
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 4));
  int _mayorRachaManual = 18;

  DateTime get fechaInicio => _fechaInicio;

  /// Calcula los días transcurridos desde la fecha de inicio hasta hoy (inclusive).
  int get rachaActual {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final inicio = DateTime(
      _fechaInicio.year,
      _fechaInicio.month,
      _fechaInicio.day,
    );

    final diferenciaDias = hoy.difference(inicio).inDays;
    return diferenciaDias >= 0 ? diferenciaDias + 1 : 0;
  }

  /// La mayor racha siempre es al menos tan grande como la racha actual conseguida.
  int get mayorRacha {
    final actual = rachaActual;
    return actual > _mayorRachaManual ? actual : _mayorRachaManual;
  }

  void establecerFechaInicio(DateTime nuevaFecha) {
    _fechaInicio = nuevaFecha;
    notifyListeners();
  }

  void establecerMayorRacha(int maximo) {
    _mayorRachaManual = maximo;
    notifyListeners();
  }
}
