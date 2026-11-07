import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'dart:async';

/// Pantalla encargada de monitorizar la postura del usuario en tiempo real mediante la cámara
/// y de mostrar un historial cronológico de alertas de postura incorrecta detectadas.
class PantallaAlertasPostura extends StatefulWidget {
  const PantallaAlertasPostura({super.key});

  @override
  State<PantallaAlertasPostura> createState() => _PantallaAlertasPosturaState();
}

class _PantallaAlertasPosturaState extends State<PantallaAlertasPostura> {
  // Lista mutable inicializada con alertas de ejemplo para visualizar la interfaz
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
  bool _isCameraActive =
      false; // Bandera para saber si la cámara está encendida
  bool _puedeAgregarAlerta =
      true; // Controla el tiempo de espera (cooldown) para simular alertas
  Timer?
  _cooldownTimer; // Temporizador para limitar la frecuencia de simulación

  @override
  void dispose() {
    _cameraController?.dispose(); // Libera el controlador de la cámara
    _cooldownTimer
        ?.cancel(); // Cancela el temporizador activo al destruir la vista
    super.dispose();
  }

  /// Método para activar o apagar la cámara del dispositivo de forma dinámica.
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
          // Busca preferentemente la cámara frontal para monitorizar la postura del usuario
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

  /// Simula la detección de un movimiento incorrecto de postura captado por la IA/cámara.
  void _detectarMovimientoIncorrecto() {
    if (!_isCameraActive || !_puedeAgregarAlerta) return;

    final now = DateTime.now();
    final horaFormateada =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    // Inserta una nueva alerta de alta severidad al inicio de la lista
    setState(() {
      _alerts.insert(0, {
        'issue': 'Postura incorrecta detectada (Movimiento)',
        'timestamp': horaFormateada,
        'severity': 'high',
        'duration': '1 min',
      });
      _puedeAgregarAlerta =
          false; // Bloquea temporalmente el botón de simulación
    });

    // Inicia un temporizador de 10 segundos de enfriamiento (cooldown) antes de permitir otra simulación
    _cooldownTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _puedeAgregarAlerta = true;
        });
      }
    });

    // Muestra una notificación emergente avisando de la nueva alerta
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
          // Vista previa de la cámara (se muestra únicamente si está activa e inicializada correctamente)
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

          // Lista cronológica de alertas detectadas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final isHighSeverity = alert['severity'] == 'high';
                final isLast = index == _alerts.length - 1;

                // Asigna colores de advertencia según la severidad (rojo para alto, ámbar para medio)
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
                      // Columna indicadora con icono circular y línea conectora de tiempo
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
                      // Tarjeta con los detalles de la alerta (hora, duración y descripción)
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
      // Botones flotantes (FAB) para simular movimientos incorrectos y activar/apagar la cámara
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCameraActive)
            FloatingActionButton.extended(
              heroTag: 'btn_simular_movimiento',
              onPressed: _puedeAgregarAlerta
                  ? _detectarMovimientoIncorrecto
                  : null, // Deshabilita el botón durante el tiempo de espera
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
