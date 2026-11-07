import 'package:flutter/material.dart';

class EyeCareRestScreen extends StatefulWidget {
  const EyeCareRestScreen({super.key});

  @override
  State<EyeCareRestScreen> createState() => _EyeCareRestScreenState();
}

class _EyeCareRestScreenState extends State<EyeCareRestScreen> {
  final int _totalSeconds = 20; // 20 segundos según la regla 20-20-20
  int _remainingSeconds = 20;
  bool _isRunning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descanso Visual'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '👁️ 94%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

            // Indicación del ejercicio
            const Text(
              'Mira a un punto a 6 metros (20 pies)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Contador de segundos simple
            Text(
              '${_remainingSeconds}s',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Regla 20-20-20',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const Spacer(),

            // Controles de Play/Pause y Reinicio
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _isRunning = !_isRunning;
                    });
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 28,
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _remainingSeconds = _totalSeconds;
                    });
                  },
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
