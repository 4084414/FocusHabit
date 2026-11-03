import 'package:flutter/material.dart';

class PantallaHoy extends StatelessWidget {
  const PantallaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        actions: const [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '🔥 5 days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            '¡Hola de novo! 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Título de hábitos
          Text(
            'Hábitos de hoy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          // Lista simple de hábitos
          HabitCard(title: 'Beber 2L de agua', icon: Icons.water_drop),
          HabitCard(title: 'Hacer ejercicio', icon: Icons.fitness_center),
          HabitCard(title: 'Leer 15 minutos', icon: Icons.book),
        ],
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const HabitCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
