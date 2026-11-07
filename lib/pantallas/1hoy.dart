import 'package:flutter/material.dart';

import '../data/habitos_controller.dart';
import '../data/rachas_controller.dart';
import '2habitos.dart';
import '5rachas.dart';
import '9estadisticas.dart';
import '10ajustes.dart';
import '6sesionestudio.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Pantalla contenedora principal que administra la barra de navegación inferior (BottomNavigationBar)
/// y cambia entre las 5 secciones de la aplicación mediante un [IndexedStack].
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  int _indiceActual = 0; // Índice de la pestaña seleccionada actualmente

  // Lista con las 5 pantallas principales conectadas a la navegación
  final List<Widget> _pantallas = const [
    _ContenidoHoy(),
    PantallaHabitos(),
    PantallaEstadisticas(),
    PantallaRachas(),
    PantallaAjustes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indiceActual, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (int indice) {
          setState(() {
            _indiceActual = indice; // Actualiza la pestaña activa al pulsar
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Rachas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

/// Contenido de la primera pestaña: "Hoy", que incluye la barra de progreso,
/// los hábitos pendientes y el control interactivo por voz (Speech-to-Text).
class _ContenidoHoy extends StatefulWidget {
  const _ContenidoHoy();

  @override
  State<_ContenidoHoy> createState() => _ContenidoHoyState();
}

class _ContenidoHoyState extends State<_ContenidoHoy> {
  late final stt.SpeechToText _reconocimientoVoz;
  bool _estaEscuchando =
      false; // Bandera para saber si el micrófono está activo
  String _mensajeTranscripcion = ''; // Texto reconocido por voz

  @override
  void initState() {
    super.initState();
    _reconocimientoVoz =
        stt.SpeechToText(); // Inicializa la librería de reconocimiento de voz
  }

  /// Inicia el reconocimiento de voz al mantener presionado el botón flotante.
  Future<void> _iniciarEscucha() async {
    bool disponible = await _reconocimientoVoz.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (estado) => print('Status: $estado'),
    );

    if (disponible) {
      setState(() {
        _estaEscuchando = true;
        _mensajeTranscripcion = 'Escuchando... 🎙️';
      });

      _reconocimientoVoz.listen(
        localeId: 'es_ES', // Configurado para español de España
        onResult: (resultado) {
          setState(() {
            _mensajeTranscripcion = resultado
                .recognizedWords; // Actualiza la transcripción en tiempo real
          });
        },
      );
    } else {
      setState(() {
        _mensajeTranscripcion = 'El reconocimiento de voz no está disponible';
      });
    }
  }

  /// Detiene la escucha al soltar el botón y procesa el comando de voz dictado.
  Future<void> _detenerEscucha() async {
    await _reconocimientoVoz.stop();
    setState(() {
      _estaEscuchando = false;
    });

    _procesarComandoVoz(_mensajeTranscripcion);
  }

  /// Lógica de procesamiento de lenguaje natural básico para interpretar el texto dictado
  /// y marcar automáticamente el hábito correspondiente si coincide.
  void _procesarComandoVoz(String texto) {
    final textoMinuscula = texto.toLowerCase();

    // Comprueba si la frase contiene instrucciones para marcar un hábito como completado
    if (textoMinuscula.contains('completado') &&
        textoMinuscula.contains('habito')) {
      final partes = textoMinuscula.split(RegExp(r'h[áa]bito'));
      if (partes.length > 1) {
        final nombreObjetivo = partes[1].trim();

        final controladorHabitos = HabitosController.instance;
        // Busca un hábito cuyo título coincida o contenga el nombre dictado
        final habitoEncontrado = controladorHabitos.habitos.firstWhere(
          (habito) =>
              (habito['titulo'] ?? '').toLowerCase().contains(nombreObjetivo),
          orElse: () => {},
        );

        if (habitoEncontrado.isNotEmpty) {
          if (habitoEncontrado['completado'] != 'true') {
            controladorHabitos.alternarCompletado(habitoEncontrado);
          }
          _mostrarSnackBarTemporal(
            '¡Hábito "${habitoEncontrado['titulo']}" completado con éxito! ✅',
          );
          return;
        }
      }
    }

    if (texto.isNotEmpty && texto != 'Escuchando... 🎙️') {
      _mostrarSnackBarTemporal('No se reconoció ningún hábito en: "$texto"');
    }
  }

  /// Muestra notificaciones flotantes temporales (SnackBars) en pantalla.
  void _mostrarSnackBarTemporal(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temaTexto = Theme.of(context).textTheme;
    final esquemaColores = Theme.of(context).colorScheme;
    final controladorHabitos = HabitosController.instance;

    // ListenableBuilder redibuja la pestaña automáticamente cuando cambian los hábitos
    return ListenableBuilder(
      listenable: controladorHabitos,
      builder: (context, _) {
        final completados = controladorHabitos.habitosCompletados;
        final total = controladorHabitos.totalHabitos;
        final progreso = controladorHabitos.progreso;
        final pendientesHoy = controladorHabitos.primerosTresSinCompletar;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hoy'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  // ListenableBuilder secundario para actualizar la racha actual en tiempo real
                  child: ListenableBuilder(
                    listenable: RachasController.instance,
                    builder: (context, _) {
                      final racha = RachasController.instance.rachaActual;
                      return Text(
                        '🔥 $racha ${racha == 1 ? "día" : "días"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '¡Hola de nuevo! 👋',
                style: temaTexto.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Contenedor animado que muestra el mensaje de voz actual o estado de escucha
              if (_estaEscuchando || _mensajeTranscripcion.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: esquemaColores.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: esquemaColores.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: esquemaColores.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _mensajeTranscripcion,
                          style: temaTexto.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tarjeta visual que muestra el progreso porcentual y la barra de avance
              Card(
                elevation: 0,
                color: esquemaColores.primaryContainer.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                completados == total && total > 0
                                    ? Icons.task_alt
                                    : Icons.pie_chart_outline,
                                color: esquemaColores.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progreso de hábitos',
                                style: temaTexto.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: esquemaColores.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: esquemaColores.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$completados de $total completadas',
                              style: temaTexto.labelSmall?.copyWith(
                                color: esquemaColores.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progreso,
                          minHeight: 8,
                          backgroundColor:
                              esquemaColores.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            esquemaColores.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        completados == total && total > 0
                            ? '¡Increíble! Has completado todos los hábitos de tu lista 🎉'
                            : 'Llevas el ${(progreso * 100).round()}% de tus hábitos completados hoy',
                        style: temaTexto.bodySmall?.copyWith(
                          color: esquemaColores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Hábitos de hoy',
                style: temaTexto.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tus próximos 3 hábitos pendientes de la lista',
                style: temaTexto.bodySmall?.copyWith(
                  color: esquemaColores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Si no hay pendientes, muestra un mensaje de felicitación; de lo contrario, lista los 3 primeros
              if (pendientesHoy.isEmpty)
                Card(
                  elevation: 0,
                  color: esquemaColores.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 48,
                            color: esquemaColores.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '¡Todos los hábitos completados!',
                            style: temaTexto.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendientesHoy.map((habito) {
                  final iconoCategoria =
                      HabitosController.obtenerIconoPorCategoria(
                        habito['categoria'],
                      );

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        iconoCategoria,
                        color: esquemaColores.primary,
                      ),
                      title: Text(
                        habito['titulo'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Objetivo: ${habito['objetivo']} · ${habito['categoria']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Marcar como completado',
                        color: esquemaColores.primary,
                        onPressed: () {
                          controladorHabitos.alternarCompletado(habito);
                        },
                      ),
                      onTap: () {
                        controladorHabitos.alternarCompletado(habito);
                      },
                    ),
                  );
                }),
            ],
          ),
          // Botones flotantes (Mantener presionado para hablar mediante voz + Iniciar sesión de enfoque)
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onLongPressStart: (_) => _iniciarEscucha(),
                onLongPressEnd: (_) => _detenerEscucha(),
                child: FloatingActionButton(
                  heroTag: 'fab_voice',
                  onPressed:
                      () {}, // Callback obligatorio requerido por Flutter
                  backgroundColor: _estaEscuchando
                      ? Colors.redAccent
                      : esquemaColores.primary,
                  foregroundColor: esquemaColores.onPrimary,
                  tooltip: 'Mantén presionado para dictar',
                  child: Icon(_estaEscuchando ? Icons.mic : Icons.mic_none),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                heroTag: 'fab_focus',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaSesionEstudio(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar Enfoque'),
              ),
            ],
          ),
        );
      },
    );
  }
}
