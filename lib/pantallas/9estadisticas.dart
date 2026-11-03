import 'package:flutter/material.dart';

class PantallaEstadisticas extends StatelessWidget {
  const PantallaEstadisticas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas y Rendimiento')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // 1. Métricas simplificadas en tarjetas individuales
          StatCard(
            title: 'Completados',
            value: '29 hábitos esta semana',
            icon: Icons.check_circle_outline,
          ),
          SizedBox(height: 8),
          StatCard(
            title: 'Tasa de Éxito',
            value: '87% (+4% vs mes anterior)',
            icon: Icons.trending_up,
          ),
          SizedBox(height: 8),
          StatCard(
            title: 'Tiempo Enfoque',
            value: '14.5h acumuladas',
            icon: Icons.timer_outlined,
          ),
          SizedBox(height: 8),
          StatCard(
            title: 'Alertas IA',
            value: '12 posturas incorrectas',
            icon: Icons.health_and_safety_outlined,
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

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
