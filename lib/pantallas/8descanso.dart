import 'dart:async';

import 'package:flutter/material.dart';

/// Pantalla encargada de gestionar el ejercicio de descanso visual (regla 20-20-20),
/// implementando una cuenta regresiva de 20 segundos con opciones de pausa y reinicio.
class PantallaDescansoVisual extends StatefulWidget {
  const PantallaDescansoVisual({super.key});

  @override
  State<PantallaDescansoVisual> createState() => _PantallaDescansoVisualState();
}

class _PantallaDescansoVisualState extends State<PantallaDescansoVisual> {
  final int _totalSegundos =
      20; // 20 segundos de duración según la regla 20-20-20
  int _segundosRestantes =
      20; // Segundos restantes que se actualizan en el temporizador
  bool _estaEnMarcha = true; // Bandera para indicar si el contador está activo
  Timer? _temporizador; // Instancia del temporizador periódico

  @override
  void initState() {
    super.initState();
    _iniciarTemporizador(); // Inicia el temporizador automáticamente al abrir la pantalla
  }

  /// Método privado para inicializar el temporizador periódico que descuenta un segundo cada vez.
  void _iniciarTemporizador() {
    _temporizador = Timer.periodic(const Duration(seconds: 1), (temporizador) {
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        _temporizador?.cancel(); // Detiene el temporizador cuando llega a cero
        setState(() => _estaEnMarcha = false);
      }
    });
  }

  /// Alterna el estado del temporizador entre en marcha (Play) y pausado (Pause).
  void _alternarTemporizador() {
    if (_estaEnMarcha) {
      _temporizador?.cancel();
      setState(() => _estaEnMarcha = false);
    } else {
      setState(() => _estaEnMarcha = true);
      _iniciarTemporizador();
    }
  }

  /// Reinicia el temporizador restableciendo los segundos iniciales y reanudando la cuenta.
  void _reiniciarTemporizador() {
    _temporizador?.cancel();
    setState(() {
      _segundosRestantes = _totalSegundos;
      _estaEnMarcha = true;
    });
    _iniciarTemporizador();
  }

  @override
  void dispose() {
    _temporizador?.cancel(); // Libera el temporizador para prevenir fugas de memoria al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Descanso Visual'),
        actions: [
          // Indicador visual en la barra superior (ej. porcentaje de efectividad o salud ocular)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: esquemaColores.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '👁️ 94%',
                  style: temaTexto.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: esquemaColores.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Instrucción principal del ejercicio visual
            Text(
              'Mira a un punto a 6 metros (20 pies)',
              textAlign: TextAlign.center,
              style: temaTexto.titleMedium?.copyWith(
                color: esquemaColores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Muestra de forma destacada el contador de segundos restantes (ej. "20s")
            Text(
              '${_segundosRestantes}s',
              style: temaTexto.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: esquemaColores.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Regla 20-20-20',
              style: temaTexto.bodyMedium?.copyWith(
                color: esquemaColores.outline,
              ),
            ),

            const Spacer(),

            // Botones de control interactivos (Pausa/Reproducción y Reinicio)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  iconSize: 32,
                  icon: Icon(_estaEnMarcha ? Icons.pause : Icons.play_arrow),
                  onPressed: _alternarTemporizador,
                ),
                const SizedBox(width: 24),
                IconButton.outlined(
                  iconSize: 28,
                  icon: const Icon(Icons.refresh),
                  onPressed: _reiniciarTemporizador,
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
