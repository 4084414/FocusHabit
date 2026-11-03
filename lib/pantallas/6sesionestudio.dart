import 'package:flutter/material.dart';

class PantallaSesionEstudio extends StatefulWidget {
  const PantallaSesionEstudio({super.key});

  @override
  State<PantallaSesionEstudio> createState() => _PantallaSesionEstudioState();
}

class _PantallaSesionEstudioState extends State<PantallaSesionEstudio> {
  bool _isRunning = false;
  final int _totalSeconds = 25 * 60; // 25 minutos
  int _remainingSeconds = 25 * 60;

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Enfoque'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '🟢 IA Activa',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

            // Tiempo restante y estado simple
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isRunning ? 'En curso...' : 'Pausado',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const Spacer(),

            // Botones de control (Reiniciar y Play/Pause)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isRunning = false;
                      _remainingSeconds = _totalSeconds;
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 24),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isRunning = !_isRunning;
                    });
                  },
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
