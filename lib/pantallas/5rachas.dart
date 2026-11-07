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
    final temaTexto = Theme.of(context).textTheme;
    final esquemaColores = Theme.of(context).colorScheme;
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
                      titulo: 'Racha Actual',
                      valor:
                          '$rachaActual ${rachaActual == 1 ? "día" : "días"}',
                      icono: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      titulo: 'Racha Máxima',
                      valor:
                          '$rachaMaxima ${rachaMaxima == 1 ? "día" : "días"}',
                      icono: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Resumen dinámico del mes en curso
              Text(
                nombreMes,
                style: temaTexto.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$porcentaje% completado este mes ($diasCompletados de $diasEnMes días)',
                style: temaTexto.bodyMedium?.copyWith(
                  color: esquemaColores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              // Barra de progreso lineal que representa gráficamente el avance del mes
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (diasCompletados / diasEnMes).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: esquemaColores.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    esquemaColores.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Tarjeta informativa sobre la simulación y ajustes de fecha
              Card(
                elevation: 0,
                color: esquemaColores.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.tune, color: esquemaColores.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Puedes ajustar la fecha de inicio y la racha máxima desde la pestaña de Ajustes.',
                          style: temaTexto.bodySmall?.copyWith(
                            color: esquemaColores.onSurfaceVariant,
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
  final String titulo;
  final String valor;
  final IconData icono;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final temaTexto = Theme.of(context).textTheme;
    final esquemaColores = Theme.of(context).colorScheme;

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
                    titulo,
                    style: temaTexto.bodyMedium?.copyWith(
                      color: esquemaColores.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Icono representativo superior con el color primario (#2E7D6B)
                Icon(icono, size: 22, color: esquemaColores.primary),
              ],
            ),
            const SizedBox(height: 12),
            // Valor numérico o texto principal de la estadística
            Text(
              valor,
              style: temaTexto.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
