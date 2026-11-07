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
            titulo: 'Completados',
            valor: '29 hábitos esta semana',
            icono: Icons.check_circle_outline,
          ),
          const SizedBox(height: 8),

          // Tarjeta que muestra la tasa de éxito general y su comparación con el mes anterior
          const StatCard(
            titulo: 'Tasa de Éxito',
            valor: '87% (+4% vs mes anterior)',
            icono: Icons.trending_up,
          ),
          const SizedBox(height: 8),

          // Tarjeta que muestra el tiempo acumulado en sesiones de enfoque
          const StatCard(
            titulo: 'Tiempo Enfoque',
            valor: '14.5h acumuladas',
            icono: Icons.timer_outlined,
          ),
          const SizedBox(height: 8),

          // Tarjeta interactiva con acción de navegación para abrir la pantalla de Alertas de Postura
          StatCard(
            titulo: 'Alertas IA',
            valor: '12 posturas incorrectas',
            icono: Icons.health_and_safety_outlined,
            alTocar: () {
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
  final String titulo;
  final String valor;
  final IconData icono;
  final VoidCallback?
  alTocar; // Callback opcional para manejar eventos de toque y navegación

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final esquemaColores = Theme.of(context).colorScheme;
    final temaTexto = Theme.of(context).textTheme;

    return Card(
      child: ListTile(
        onTap: alTocar, // Activa el evento táctil si se proporciona un callback
        // Icono representativo situado a la izquierda con el color primario (#2E7D6B)
        leading: Icon(icono, color: esquemaColores.primary),
        // Título de la tarjeta en negrita
        title: Text(
          titulo,
          style: temaTexto.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        // Subtítulo con el valor o métrica detallada
        subtitle: Text(valor),
        // Muestra un icono de flecha hacia la derecha (chevron) únicamente si la tarjeta es interactiva
        trailing: alTocar != null
            ? const Icon(Icons.chevron_right, size: 20)
            : null,
      ),
    );
  }
}
