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
  final List<Map<String, String>> _alertas = [
    {
      'incidencia': 'Inclinación de cabeza pronunciada',
      'hora': '11:42 AM',
      'severidad': 'alta',
      'duracion': '3 min',
    },
    {
      'incidencia': 'Slouching detected (Espalda encorvada)',
      'hora': '11:15 AM',
      'severidad': 'alta',
      'duracion': '5 min',
    },
    {
      'incidencia': 'Hombros desalineados',
      'hora': '10:30 AM',
      'severidad': 'media',
      'duracion': '2 min',
    },
    {
      'incidencia': 'Distancia muy corta a la pantalla',
      'hora': '09:50 AM',
      'severidad': 'media',
      'duracion': '1 min',
    },
  ];

  CameraController? _controladorCamara;
  bool _camaraActiva = false; // Bandera para saber si la cámara está encendida
  bool _puedeAgregarAlerta =
      true; // Controla el tiempo de espera (cooldown) para simular alertas
  Timer?
  _temporizadorEspera; // Temporizador para limitar la frecuencia de simulación

  @override
  void dispose() {
    _controladorCamara?.dispose(); // Libera el controlador de la cámara
    _temporizadorEspera
        ?.cancel(); // Cancela el temporizador activo al destruir la vista
    super.dispose();
  }

  /// Método para activar o apagar la cámara del dispositivo de forma dinámica.
  Future<void> _alternarCamara() async {
    if (_camaraActiva) {
      await _controladorCamara?.dispose();
      setState(() {
        _controladorCamara = null;
        _camaraActiva = false;
      });
    } else {
      try {
        final camaras = await availableCameras();
        if (camaras.isNotEmpty) {
          // Busca preferentemente la cámara frontal para monitorizar la postura del usuario
          final camaraFrontal = camaras.firstWhere(
            (camara) => camara.lensDirection == CameraLensDirection.front,
            orElse: () => camaras.first,
          );

          _controladorCamara = CameraController(
            camaraFrontal,
            ResolutionPreset.medium,
            enableAudio: false,
          );

          await _controladorCamara!.initialize();
          if (mounted) {
            setState(() {
              _camaraActiva = true;
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
    if (!_camaraActiva || !_puedeAgregarAlerta) return;

    final ahora = DateTime.now();
    final horaFormateada =
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')} ${ahora.hour >= 12 ? 'PM' : 'AM'}';

    // Inserta una nueva alerta de alta severidad al inicio de la lista
    setState(() {
      _alertas.insert(0, {
        'incidencia': 'Postura incorrecta detectada (Movimiento)',
        'hora': horaFormateada,
        'severidad': 'alta',
        'duracion': '1 min',
      });
      _puedeAgregarAlerta =
          false; // Bloquea temporalmente el botón de simulación
    });

    // Inicia un temporizador de 10 segundos de enfriamiento (cooldown) antes de permitir otra simulación
    _temporizadorEspera = Timer(const Duration(seconds: 10), () {
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
    final tema = Theme.of(context);
    final esquemaColores = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de Postura')),
      body: Column(
        children: [
          // Vista previa de la cámara (se muestra únicamente si está activa e inicializada correctamente)
          if (_camaraActiva &&
              _controladorCamara != null &&
              _controladorCamara!.value.isInitialized)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  CameraPreview(_controladorCamara!),
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
              itemCount: _alertas.length,
              itemBuilder: (context, indice) {
                final alerta = _alertas[indice];
                final severidadAlta = alerta['severidad'] == 'alta';
                final esUltima = indice == _alertas.length - 1;

                // Asigna colores de advertencia según la severidad (rojo para alto, ámbar para medio)
                final colorAdvertencia = severidadAlta
                    ? Colors.red.shade400
                    : Colors.amber.shade700;
                final colorFondo = severidadAlta
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
                              color: colorFondo,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              severidadAlta
                                  ? Icons.warning_amber_rounded
                                  : Icons.info_outline,
                              color: colorAdvertencia,
                              size: 20,
                            ),
                          ),
                          if (!esUltima)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: esquemaColores.outlineVariant,
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
                            color: esquemaColores.surfaceContainerLow,
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
                                        alerta['hora']!,
                                        style: tema.textTheme.labelMedium
                                            ?.copyWith(
                                              color: esquemaColores
                                                  .onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Duración: ${alerta['duracion']}',
                                        style: tema.textTheme.labelSmall
                                            ?.copyWith(
                                              color: esquemaColores.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    alerta['incidencia']!,
                                    style: tema.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
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
          if (_camaraActiva)
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
            onPressed: _alternarCamara,
            icon: Icon(_camaraActiva ? Icons.videocam_off : Icons.videocam),
            label: Text(_camaraActiva ? 'Apagar Cámara' : 'Activar Cámara'),
          ),
        ],
      ),
    );
  }
}
