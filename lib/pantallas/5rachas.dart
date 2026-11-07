import 'package:flutter/material.dart';

import '../data/rachas_controller.dart';

/// Pantalla encargada de mostrar el resumen de rachas actuales, rachas máximas
/// y el progreso mensual de los hábitos completados.
class PantallaRachas extends StatelessWidget {
  const PantallaRachas({super.key});

  // Lista estática con los nombres de los meses en español para formatear las fechas
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
    // Obtiene el nombre del mes actual a partir del índice (ahora.month - 1) y el año en curso
    final nombreMes = '${_meses[ahora.month - 1]} ${ahora.year}';
    // Calcula cuántos días tiene exactamente el mes actual
    final diasEnMes = DateTime(ahora.year, ahora.month + 1, 0).day;

    return Scaffold(
      appBar: AppBar(title: const Text('Rachas y Progreso')),
      // ListenableBuilder actualiza la vista automáticamente cuando cambian los datos de las rachas
      body: ListenableBuilder(
        listenable: rachas,
        builder: (context, _) {
          final rachaActual = rachas.rachaActual;
          final rachaMaxima = rachas.mayorRacha;
          // Limita los días completados para que no superen el total de días del mes actual
          final diasCompletados = rachaActual > diasEnMes
              ? diasEnMes
              : rachaActual;
          // Calcula el porcentaje de avance del mes y lo acota entre 0 y 100
          final porcentaje = ((diasCompletados / diasEnMes) * 100)
              .clamp(0, 100)
              .round();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Fila con las tarjetas de estadísticas (Racha Actual y Racha Máxima)
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Racha Actual',
                      value:
                          '$rachaActual ${rachaActual == 1 ? "día" : "días"}',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Racha Máxima',
                      value:
                          '$rachaMaxima ${rachaMaxima == 1 ? "día" : "días"}',
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Resumen dinámico del mes en curso
              Text(
                nombreMes,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$porcentaje% completado este mes ($diasCompletados de $diasEnMes días)',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Barra de progreso lineal que representa gráficamente el avance del mes
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (diasCompletados / diasEnMes).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Tarjeta informativa sobre la simulación y ajustes de fecha
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

/// Widget reutilizable para representar tarjetas de estadísticas individuales
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
                // Icono representativo superior con el color primario (#2E7D6B)
                Icon(icon, size: 22, color: colorScheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            // Valor numérico o texto principal de la estadística
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
