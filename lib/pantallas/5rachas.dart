import 'package:flutter/material.dart';

import '../data/rachas_controller.dart';

class PantallaRachas extends StatelessWidget {
  const PantallaRachas({super.key});

  static const List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final rachas = RachasController.instance;

    final ahora = DateTime.now();
    final nombreMes = '${_meses[ahora.month - 1]} ${ahora.year}';
    final diasEnMes = DateTime(ahora.year, ahora.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(title: const Text('Rachas y Progreso')),
      body: ListenableBuilder(
        listenable: rachas,
        builder: (context, _) {
          final rachaActual = rachas.rachaActual;
          final rachaMaxima = rachas.mayorRacha;
          final diasCompletados = rachaActual > diasEnMes ? diasEnMes : rachaActual;
          final porcentaje = ((diasCompletados / diasEnMes) * 100).clamp(0, 100).round();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Tarjetas de estadísticas de racha dinámicas
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Racha Actual',
                      value: '$rachaActual ${rachaActual == 1 ? "día" : "días"}',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Racha Máxima',
                      value: '$rachaMaxima ${rachaMaxima == 1 ? "día" : "días"}',
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Resumen del mes dinámico
              Text(
                nombreMes,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$porcentaje% completado este mes ($diasCompletados de $diasEnMes días)',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (diasCompletados / diasEnMes).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Indicador de simulación disponible
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.tune, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Puedes ajustar la fecha de inicio y la racha máxima desde la pestaña de Ajustes.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  icon,
                  size: 22,
                  color: colorScheme.primary, // Usa el verde #2E7D6B del tema
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
