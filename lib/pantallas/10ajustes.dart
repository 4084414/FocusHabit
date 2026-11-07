import 'package:flutter/material.dart';
import 'package:focushabit/data/theme_controller.dart';

import '../data/rachas_controller.dart';

/// Pantalla encargada de gestionar los ajustes de la aplicación,
/// tales como notificaciones, cambio de tema claro/oscuro y simulación de rachas.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  bool _notificacionesHabilitadas =
      true; // Estado local para el interruptor de notificaciones

  /// Método auxiliar para formatear objetos DateTime a cadenas legibles de tipo "DD/MM/AAAA".
  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  /// Muestra un selector de fechas (DatePicker) para configurar de forma personalizada
  /// el día de inicio de la racha actual (modo simulación).
  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final rachas = RachasController.instance;
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: rachas.fechaInicio.isAfter(DateTime.now())
          ? DateTime.now()
          : rachas.fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Día que empezaste la racha actual',
      confirmText: 'Guardar',
      cancelText: 'Cancelar',
    );
    if (seleccionada != null) {
      rachas.establecerFechaInicio(
        seleccionada,
      ); // Actualiza la fecha de inicio en el controlador
    }
  }

  /// Muestra un diálogo emergente con un campo de texto numérico
  /// para editar manualmente el récord histórico de la mayor racha.
  Future<void> _editarMayorRacha(BuildContext context) async {
    final rachas = RachasController.instance;
    final controladorTexto = TextEditingController(
      text: rachas.mayorRacha.toString(),
    );

    final nuevoValor = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mayor Racha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Introduce el récord de días de tu mayor racha:'),
            const SizedBox(height: 16),
            TextField(
              controller: controladorTexto,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Días de racha',
                border: OutlineInputBorder(),
                suffixText: 'días',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = int.tryParse(controladorTexto.text.trim());
              if (valor != null && valor >= 0) {
                Navigator.pop(
                  ctx,
                  valor,
                ); // Devuelve el valor numérico introducido
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nuevoValor != null) {
      rachas.establecerMayorRacha(
        nuevoValor,
      ); // Actualiza la mayor racha en el controlador
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquemaColores = tema.colorScheme;
    final rachas = RachasController.instance;
    final controladorTema =
        ThemeController.instance; // Instancia del controlador de temas

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      // Listenable.merge permite escuchar simultáneamente múltiples controladores (rachas y tema)
      body: ListenableBuilder(
        listenable: Listenable.merge([rachas, controladorTema]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // 1. Interruptor para activar o desactivar notificaciones y alertas
              SwitchListTile(
                secondary: Icon(
                  Icons.notifications_none_outlined,
                  color: esquemaColores.primary,
                ),
                title: const Text('Notificaciones y Alertas'),
                value: _notificacionesHabilitadas,
                onChanged: (habilitadas) =>
                    setState(() => _notificacionesHabilitadas = habilitadas),
              ),

              // 2. Interruptor para cambiar entre Tema Claro y Tema Oscuro globalmente
              SwitchListTile(
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: esquemaColores.primary,
                ),
                title: const Text('Tema Oscuro'),
                value: controladorTema.estaEnModoOscuro, // Consulta el estado real en el controlador
                onChanged: (oscuro) {
                  controladorTema.alternarTema(
                    oscuro,
                  ); // Modifica el tema en toda la aplicación
                },
              ),

              const Divider(),

              // Sección informativa orientada a la simulación y trampa de rachas
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: esquemaColores.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configuración de Rachas (Simulación)',
                      style: tema.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: esquemaColores.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Opción para modificar la fecha de inicio de la racha actual
              ListTile(
                leading: Icon(
                  Icons.calendar_month_outlined,
                  color: esquemaColores.primary,
                ),
                title: const Text('Día de inicio de racha actual'),
                subtitle: Text(
                  '${_formatearFecha(rachas.fechaInicio)} (${rachas.rachaActual} ${rachas.rachaActual == 1 ? "día" : "días"} acumulados)',
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _seleccionarFechaInicio(context),
              ),

              // Opción para modificar manualmente el récord histórico de mayor racha
              ListTile(
                leading: Icon(
                  Icons.emoji_events_outlined,
                  color: esquemaColores.primary,
                ),
                title: const Text('Mayor racha histórica'),
                subtitle: Text('${rachas.mayorRacha} días récord'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editarMayorRacha(context),
              ),

              const Divider(),

              // 3. Opción para borrar los datos del usuario (acción peligrosa en rojo)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: esquemaColores.error,
                ),
                title: Text(
                  'Borrar Datos de Usuario',
                  style: TextStyle(color: esquemaColores.error),
                ),
                onTap: () {
                  // Aquí se implementaría la lógica para restablecer los datos
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
