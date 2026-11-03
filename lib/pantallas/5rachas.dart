import 'package:flutter/material.dart';

class PantallaRachas extends StatelessWidget {
  const PantallaRachas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rachas y Progreso')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          // 1. Tarjetas de estadísticas de racha
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Racha Actual',
                  value: '5 días',
                  icon: Icons.local_fire_department,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Racha Máxima',
                  value: '18 días',
                  icon: Icons.emoji_events,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // 2. Resumen del mes simplificado
          Text(
            'Noviembre 2026',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '75% completado este mes',
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Icon(icon, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
