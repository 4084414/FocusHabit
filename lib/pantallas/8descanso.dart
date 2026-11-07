import 'dart:async';

import 'package:flutter/material.dart';

class PantallaDescansoVisual extends StatefulWidget {
  const PantallaDescansoVisual({super.key});

  @override
  State<PantallaDescansoVisual> createState() => _PantallaDescansoVisualState();
}

class _PantallaDescansoVisualState extends State<PantallaDescansoVisual> {
  final int _totalSeconds = 20; // 20 segundos según la regla 20-20-20
  int _remainingSeconds = 20;
  bool _isRunning = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _startTimer();
    }
  }

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
    _timer?.cancel();
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

            // Indicación del ejercicio
            Text(
              'Mira a un punto a 6 metros (20 pies)',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Contador de segundos
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

            // Controles de Play/Pause y Reinicio
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
