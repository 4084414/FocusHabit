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
  final int _totalSeconds =
      20; // 20 segundos de duración según la regla 20-20-20
  int _remainingSeconds =
      20; // Segundos restantes que se actualizan en el temporizador
  bool _isRunning = true; // Bandera para indicar si el contador está activo
  Timer? _timer; // Instancia del temporizador periódico

  @override
  void initState() {
    super.initState();
    _startTimer(); // Inicia el temporizador automáticamente al abrir la pantalla
  }

  /// Método privado para inicializar el temporizador periódico que descuenta un segundo cada vez.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel(); // Detiene el temporizador cuando llega a cero
        setState(() => _isRunning = false);
      }
    });
  }

  /// Alterna el estado del temporizador entre en marcha (Play) y pausado (Pause).
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _startTimer();
    }
  }

  /// Reinicia el temporizador restableciendo los segundos iniciales y reanudando la cuenta.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = true;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Libera el temporizador para prevenir fugas de memoria al cerrar la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '👁️ 94%',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
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
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Muestra de forma destacada el contador de segundos restantes (ej. "20s")
            Text(
              '${_remainingSeconds}s',
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Regla 20-20-20',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),

            const Spacer(),

            // Botones de control interactivos (Pausa/Reproducción y Reinicio)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  iconSize: 32,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: _toggleTimer,
                ),
                const SizedBox(width: 24),
                IconButton.outlined(
                  iconSize: 28,
                  icon: const Icon(Icons.refresh),
                  onPressed: _resetTimer,
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
