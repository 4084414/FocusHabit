import 'package:flutter/material.dart';

import '7alertas.dart'; // Importar el archivo de alertas

class PantallaEstadisticas extends StatelessWidget {
  const PantallaEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas y Rendimiento')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const StatCard(
            title: 'Completados',
            value: '29 hábitos esta semana',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 8),
          const StatCard(
            title: 'Tasa de Éxito',
            value: '87% (+4% vs mes anterior)',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 8),
          const StatCard(
            title: 'Tiempo Enfoque',
            value: '14.5h acumuladas',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 8),
          // Tarjeta interactiva para ir a Alertas de Postura
          StatCard(
            title: 'Alertas IA',
            value: '12 posturas incorrectas',
            icon: Icons.health_and_safety_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaAlertasPostura(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap; // Callback opcional para navegación

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, size: 20)
            : null,
      ),
    );
  }
}
