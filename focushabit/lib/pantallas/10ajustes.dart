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
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes y Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // 1. Notificaciones
          SwitchListTile(
            secondary: const Icon(Icons.notifications_none_outlined),
            title: const Text('Notificaciones y Alertas'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),

          // 2. Tema Oscuro
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Tema Oscuro'),
            value: _isDarkMode,
            onChanged: (val) => setState(() => _isDarkMode = val),
          ),

          // 3. Borrar datos (Simple, sin diálogos complejos)
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Borrar Datos de Usuario',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
