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
  bool _estaEnMarcha = false; // Indica si el temporizador está activo o pausado
  final int _totalSegundos =
      25 * 60; // Duración total de la sesión: 25 minutos en segundos
  int _segundosRestantes =
      25 * 60; // Segundos restantes que van disminuyendo en la cuenta atrás
  Timer? _temporizador; // Instancia del temporizador periódico

  /// Alterna el estado del temporizador entre en marcha (Play) y pausado (Pause).
  void _alternarTemporizador() {
    if (_estaEnMarcha) {
      _temporizador?.cancel(); // Detiene el temporizador si ya estaba corriendo
      setState(() => _estaEnMarcha = false);
    } else {
      setState(() => _estaEnMarcha = true);
      // Crea un temporizador que se ejecuta cada 1 segundo exacto
      _temporizador = Timer.periodic(const Duration(seconds: 1), (
        temporizador,
      ) {
        if (_segundosRestantes > 0) {
          setState(() => _segundosRestantes--); // Decrementa el tiempo restante
        } else {
          _temporizador?.cancel(); // Cancela el temporizador al llegar a cero
          setState(() => _estaEnMarcha = false);
        }
      });
    }
  }

  /// Reinicia el temporizador a su estado inicial de 25 minutos y lo detiene.
  void _reiniciarTemporizador() {
    _temporizador?.cancel();
    setState(() {
      _estaEnMarcha = false;
      _segundosRestantes = _totalSegundos;
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel(); // Libera el temporizador para evitar fugas de memoria (memory leaks) al cerrar la pantalla
    super.dispose();
  }

  /// Método auxiliar para formatear los segundos restantes en un string de tipo "MM:SS".
  String _formatearTiempo(int segundos) {
    final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
    final segundosFormateados = (segundos % 60).toString().padLeft(2, '0');
    return '$minutos:$segundosFormateados';
  }

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;

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
                  color: esquemaColores.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🟢 IA Activa',
                  style: temaTexto.labelSmall?.copyWith(
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

            // Muestra el tiempo restante formateado de forma destacada (ej. "25:00")
            Text(
              _formatearTiempo(_segundosRestantes),
              style: temaTexto.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: esquemaColores.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Texto descriptivo del estado actual del temporizador ("En curso..." o "Pausado")
            Text(
              _estaEnMarcha ? 'En curso...' : 'Pausado',
              style: temaTexto.titleMedium?.copyWith(
                color: esquemaColores.onSurfaceVariant,
              ),
            ),

            const Spacer(),

            // Controles de interacción (Botón de Reiniciar y Botón Principal Play/Pause)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _reiniciarTemporizador,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  onPressed: _alternarTemporizador,
                  child: Icon(_estaEnMarcha ? Icons.pause : Icons.play_arrow),
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
