import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'dart:async';

class PantallaAlertasPostura extends StatefulWidget {
  const PantallaAlertasPostura({super.key});

  @override
  State<PantallaAlertasPostura> createState() => _PantallaAlertasPosturaState();
}

class _PantallaAlertasPosturaState extends State<PantallaAlertasPostura> {
  // Lista mutable para poder añadir nuevas alertas en tiempo real
  final List<Map<String, String>> _alerts = [
    {
      'issue': 'Inclinación de cabeza pronunciada',
      'timestamp': '11:42 AM',
      'severity': 'high',
      'duration': '3 min',
    },
    {
      'issue': 'Slouching detected (Espalda encorvada)',
      'timestamp': '11:15 AM',
      'severity': 'high',
      'duration': '5 min',
    },
    {
      'issue': 'Hombros desalineados',
      'timestamp': '10:30 AM',
      'severity': 'medium',
      'duration': '2 min',
    },
    {
      'issue': 'Distancia muy corta a la pantalla',
      'timestamp': '09:50 AM',
      'severity': 'medium',
      'duration': '1 min',
    },
  ];

  CameraController? _cameraController;
  bool _isCameraActive = false;
  bool _puedeAgregarAlerta = true;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cameraController?.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // Activar o apagar la cámara
  Future<void> _toggleCamara() async {
    if (_isCameraActive) {
      await _cameraController?.dispose();
      setState(() {
        _cameraController = null;
        _isCameraActive = false;
      });
    } else {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          // Usamos la cámara frontal por defecto para monitorizar la postura
          final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );

          _cameraController = CameraController(
            frontCamera,
            ResolutionPreset.medium,
            enableAudio: false,
          );

          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraActive = true;
            });
          }
        }
      } catch (e) {
        debugPrint('Error al inicializar la cámara: $e');
      }
    }
  }

  // Simula el evento de movimiento detectado por la cámara
  void _detectarMovimientoIncorrecto() {
    if (!_isCameraActive || !_puedeAgregarAlerta) return;

    // Añadimos la nueva alerta de postura incorrecta
    final now = DateTime.now();
    final horaFormateada =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    setState(() {
      _alerts.insert(0, {
        'issue': 'Postura incorrecta detectada (Movimiento)',
        'timestamp': horaFormateada,
        'severity': 'high',
        'duration': '1 min',
      });
      _puedeAgregarAlerta = false; // Bloqueamos nuevas alertas
    });

    // Iniciamos temporizador de 10 segundos para desbloquear
    _cooldownTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _puedeAgregarAlerta = true;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Alerta añadida: Postura incorrecta'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de Postura')),
      body: Column(
        children: [
          // Vista previa de la cámara si está activa
          if (_isCameraActive &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.black54,
                      child: const Text(
                        'Monitoreando postura...',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Lista de alertas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final isHighSeverity = alert['severity'] == 'high';
                final isLast = index == _alerts.length - 1;

                final warningColor = isHighSeverity
                    ? Colors.red.shade400
                    : Colors.amber.shade700;
                final backgroundColor = isHighSeverity
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.1);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isHighSeverity
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline,
                              color: warningColor,
                              size: 20,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Card(
                            elevation: 0,
                            color: colorScheme.surfaceContainerLow,
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        alert['timestamp']!,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Duración: ${alert['duration']}',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    alert['issue']!,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para encender/apagar la cámara y simular detección de movimiento
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCameraActive)
            FloatingActionButton.extended(
              heroTag: 'btn_simular_movimiento',
              onPressed: _puedeAgregarAlerta
                  ? _detectarMovimientoIncorrecto
                  : null,
              backgroundColor: _puedeAgregarAlerta
                  ? Colors.orange
                  : Colors.grey,
              icon: const Icon(Icons.accessibility_new),
              label: Text(
                _puedeAgregarAlerta ? 'Simular Movimiento' : 'Esperando (10s)',
              ),
            ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'btn_camara',
            onPressed: _toggleCamara,
            icon: Icon(_isCameraActive ? Icons.videocam_off : Icons.videocam),
            label: Text(_isCameraActive ? 'Apagar Cámara' : 'Activar Cámara'),
          ),
        ],
      ),
    );
  }
}
