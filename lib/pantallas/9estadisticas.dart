import 'package:flutter/material.dart';

import '7alertas.dart'; // Importa el archivo de alertas para permitir la navegación

/// Pantalla encargada de mostrar un resumen general de las estadísticas y rendimiento del usuario
/// (hábitos completados, tasa de éxito, tiempo de enfoque y alertas de IA).
class PantallaEstadisticas extends StatelessWidget {
  const PantallaEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas y Rendimiento')),
      // ListView que organiza verticalmente las tarjetas de estadísticas con separación
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Tarjeta que muestra los hábitos completados durante la semana
          const StatCard(
            title: 'Completados',
            value: '29 hábitos esta semana',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 8),

          // Tarjeta que muestra la tasa de éxito general y su comparación con el mes anterior
          const StatCard(
            title: 'Tasa de Éxito',
            value: '87% (+4% vs mes anterior)',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 8),

          // Tarjeta que muestra el tiempo acumulado en sesiones de enfoque
          const StatCard(
            title: 'Tiempo Enfoque',
            value: '14.5h acumuladas',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 8),

          // Tarjeta interactiva con acción de navegación para abrir la pantalla de Alertas de Postura
          StatCard(
            title: 'Alertas IA',
            value: '12 posturas incorrectas',
            icon: Icons.health_and_safety_outlined,
            onTap: () {
              // Navega hacia la pantalla de alertas de postura al pulsar la tarjeta
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

/// Componente reutilizable (Widget) para representar una tarjeta de estadística
/// con icono, título, valor y un comportamiento táctil opcional.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback?
  onTap; // Callback opcional para manejar eventos de toque y navegación

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
        onTap: onTap, // Activa el evento táctil si se proporciona un callback
        // Icono representativo situado a la izquierda con el color primario (#2E7D6B)
        leading: Icon(icon, color: colorScheme.primary),
        // Título de la tarjeta en negrita
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        // Subtítulo con el valor o métrica detallada
        subtitle: Text(value),
        // Muestra un icono de flecha hacia la derecha (chevron) únicamente si la tarjeta es interactiva
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, size: 20)
            : null,
      ),
    );
  }
}
