import 'package:flutter/material.dart';

import '../data/habitos_controller.dart';
import '../data/rachas_controller.dart';
import '2habitos.dart';
import '5rachas.dart';
import '9estadisticas.dart';
import '10ajustes.dart';
import '6sesionestudio.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  int _currentIndex = 0;

  // Lista con las 5 pantallas conectadas
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
      body: IndexedStack(index: _currentIndex, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
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

/// Contenido de la primera pestaña: "Hoy"
class _ContenidoHoy extends StatefulWidget {
  const _ContenidoHoy();

  @override
  State<_ContenidoHoy> createState() => _ContenidoHoyState();
}

class _ContenidoHoyState extends State<_ContenidoHoy> {
  late final stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcriptionMessage = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Iniciar la escucha al mantener presionado el botón
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) => print('Error: $val'),
      onStatus: (val) => print('Status: $val'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _transcriptionMessage = 'Escuchando... 🎙️';
      });

      _speech.listen(
        localeId: 'es_ES', // Ajusta según tu idioma preferido
        onResult: (val) {
          setState(() {
            _transcriptionMessage = val.recognizedWords;
          });
        },
      );
    } else {
      setState(() {
        _transcriptionMessage = 'El reconocimiento de voz no está disponible';
      });
    }
  }

  // Detener la escucha al soltar el botón y procesar el comando
  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });

    _procesarComandoVoz(_transcriptionMessage);
  }

  // Lógica para interpretar el texto dictado y marcar el hábito
  void _procesarComandoVoz(String texto) {
    final textoLower = texto.toLowerCase();

    // Verificamos si contiene "completado" y "habito" (o variaciones comunes)
    if (textoLower.contains('completado') && textoLower.contains('habito')) {
      // Extraemos la parte posterior a "hábito" o "habito"
      final partes = textoLower.split(RegExp(r'h[áa]bito'));
      if (partes.length > 1) {
        final nombreObjetivo = partes[1].trim();

        final habitosController = HabitosController.instance;
        // Buscamos un hábito cuyo título coincida (o contenga lo dictado)
        final habitoEncontrado = habitosController.habits.firstWhere(
          (h) => (h['title'] ?? '').toLowerCase().contains(nombreObjetivo),
          orElse: () => {},
        );

        if (habitoEncontrado.isNotEmpty) {
          // Si no estaba completado, lo marcamos
          if (habitoEncontrado['completed'] != 'true') {
            habitosController.toggleCompletado(habitoEncontrado);
          }
          _mostrarSnackBarTemporal(
            '¡Hábito "${habitoEncontrado['title']}" completado con éxito! ✅',
          );
          return;
        }
      }
    }

    if (texto.isNotEmpty && texto != 'Escuchando... 🎙️') {
      _mostrarSnackBarTemporal('No se reconoció ningún hábito en: "$texto"');
    }
  }

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final habitosController = HabitosController.instance;

    return ListenableBuilder(
      listenable: habitosController,
      builder: (context, _) {
        final completados = habitosController.habitosCompletados;
        final total = habitosController.totalHabitos;
        final progreso = habitosController.progreso;
        final pendientesHoy = habitosController.primerosTresSinCompletar;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hoy'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
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
                '¡Hola de novo! 👋',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Mensaje flotante temporal de transcripción de voz
              if (_isListening || _transcriptionMessage.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _transcriptionMessage,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Indicador de tareas completadas del total...
              // (El resto de widgets de tu tarjeta de progreso y lista se mantienen igual)
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                // ...
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
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progreso de hábitos',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
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
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$completados de $total completadas',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
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
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        completados == total && total > 0
                            ? '¡Increíble! Has completado todos los hábitos de tu lista 🎉'
                            : 'Llevas el ${(progreso * 100).round()}% de tus hábitos completados hoy',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Hábitos de hoy',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tus próximos 3 hábitos pendientes de la lista',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              if (pendientesHoy.isEmpty)
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withValues(
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
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '¡Todos los hábitos completados!',
                            style: textTheme.titleMedium?.copyWith(
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
                  final categoryIcon = HabitosController.getIconForCategory(
                    habito['category'],
                  );

                  return Card(
                    child: ListTile(
                      leading: Icon(categoryIcon, color: colorScheme.primary),
                      title: Text(
                        habito['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Objetivo: ${habito['target']} · ${habito['category']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Marcar como completado',
                        color: colorScheme.primary,
                        onPressed: () {
                          habitosController.toggleCompletado(habito);
                        },
                      ),
                      onTap: () {
                        habitosController.toggleCompletado(habito);
                      },
                    ),
                  );
                }),
            ],
          ),
          // Botones flotantes (Mantener presionado para hablar + Iniciar Enfoque)
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón de voz con GestureDetector para Mantener Presionado (LongPress)
              GestureDetector(
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: FloatingActionButton(
                  heroTag: 'fab_voice',
                  onPressed:
                      () {}, // <--- Obligatorio para que no falle y esté activo
                  backgroundColor: _isListening
                      ? Colors.redAccent
                      : colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  tooltip: 'Mantén presionado para dictar',
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
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
