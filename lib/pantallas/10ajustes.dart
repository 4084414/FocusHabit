import 'package:flutter/material.dart';
import 'package:focushabit/data/theme_controller.dart';

import '../data/rachas_controller.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  bool _notificationsEnabled = true;

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

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
      rachas.setFechaInicio(seleccionada);
    }
  }

  Future<void> _editarMayorRacha(BuildContext context) async {
    final rachas = RachasController.instance;
    final controller = TextEditingController(
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
              controller: controller,
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
              final valor = int.tryParse(controller.text.trim());
              if (valor != null && valor >= 0) {
                Navigator.pop(ctx, valor);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (nuevoValor != null) {
      rachas.setMayorRacha(nuevoValor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rachas = RachasController.instance;
    final themeController =
        ThemeController.instance; // <--- Instancia del controlador

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          rachas,
          themeController,
        ]), // <--- Escucha ambos controladores
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // 1. Notificaciones
              SwitchListTile(
                secondary: Icon(
                  Icons.notifications_none_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Notificaciones y Alertas'),
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),

              // 2. Tema Oscuro (Conectado al ThemeController)
              SwitchListTile(
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Tema Oscuro'),
                value: themeController
                    .isDarkMode, // <--- Valor real del controlador
                onChanged: (val) {
                  themeController.toggleTheme(
                    val,
                  ); // <--- Cambia el tema globalmente
                },
              ),

              const Divider(),

              // Sección para configurar las rachas (modo simulación / trampa)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configuración de Rachas (Simulación)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_month_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Día de inicio de racha actual'),
                subtitle: Text(
                  '${_formatearFecha(rachas.fechaInicio)} (${rachas.rachaActual} ${rachas.rachaActual == 1 ? "día" : "días"} acumulados)',
                ),
                trailing: const Icon(Icons.edit_calendar_outlined),
                onTap: () => _seleccionarFechaInicio(context),
              ),
              ListTile(
                leading: Icon(
                  Icons.emoji_events_outlined,
                  color: colorScheme.primary,
                ),
                title: const Text('Mayor racha histórica'),
                subtitle: Text('${rachas.mayorRacha} días récord'),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editarMayorRacha(context),
              ),

              const Divider(),

              // 3. Borrar datos
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  'Borrar Datos de Usuario',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
