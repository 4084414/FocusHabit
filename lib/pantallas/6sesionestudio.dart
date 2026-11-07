import 'dart:async';

import 'package:flutter/material.dart';

/// Pantalla que gestiona una sesión de enfoque (técnica Pomodoro)
/// permitiendo iniciar, pausar y reiniciar el temporizador de cuenta regresiva.
class PantallaSesionEstudio extends StatefulWidget {
  const PantallaSesionEstudio({super.key});

  @override
  State<PantallaSesionEstudio> createState() => _PantallaSesionEstudioState();
}

class _PantallaSesionEstudioState extends State<PantallaSesionEstudio> {
  bool _isRunning = false; // Indica si el temporizador está activo o pausado
  final int _totalSeconds =
      25 * 60; // Duración total de la sesión: 25 minutos en segundos
  int _remainingSeconds =
      25 * 60; // Segundos restantes que van disminuyendo en la cuenta atrás
  Timer? _timer; // Instancia del temporizador periódico

  /// Alterna el estado del temporizador entre en marcha (Play) y pausado (Pause).
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel(); // Detiene el temporizador si ya estaba corriendo
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      // Crea un temporizador que se ejecuta cada 1 segundo exacto
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--); // Decrementa el tiempo restante
        } else {
          _timer?.cancel(); // Cancela el temporizador al llegar a cero
          setState(() => _isRunning = false);
        }
      });
    }
  }

  /// Reinicia el temporizador a su estado inicial de 25 minutos y lo detiene.
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Libera el temporizador para evitar fugas de memoria (memory leaks) al cerrar la pantalla
    super.dispose();
  }

  /// Método auxiliar para formatear los segundos restantes en un string de tipo "MM:SS".
  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Enfoque'),
        actions: [
          // Indicador visual en la barra superior que muestra el estado activo de la IA
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
                  '🟢 IA Activa',
                  style: textTheme.labelSmall?.copyWith(
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

            // Muestra el tiempo restante formateado de forma destacada (ej. "25:00")
            Text(
              _formatTime(_remainingSeconds),
              style: textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Texto descriptivo del estado actual del temporizador ("En curso..." o "Pausado")
            Text(
              _isRunning ? 'En curso...' : 'Pausado',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const Spacer(),

            // Controles de interacción (Botón de Reiniciar y Botón Principal Play/Pause)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  onPressed: _toggleTimer,
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
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
