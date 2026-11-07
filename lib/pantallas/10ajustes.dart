import 'package:flutter/material.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  bool _notificationsEnabled = true;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      body: ListView(
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

          // 2. Tema Oscuro
          SwitchListTile(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: colorScheme.primary,
            ),
            title: const Text('Tema Oscuro'),
            value: _isDarkMode,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),

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
      ),
    );
  }
}
