import 'package:flutter/material.dart';

class PantallaAlertasPostura extends StatelessWidget {
  const PantallaAlertasPostura({super.key});

  final List<Map<String, dynamic>> _alerts = const [
    {
      'issue': 'Inclinación de cabeza pronunciada',
      'timestamp': '11:42 AM',
      'severity': 'high',
      'duration': '3 min',
    },
    {
      'issue': 'Slouching detected (Espalda encorvada)',
      'timestamp': '11:15 AM',
      'severity': 'high',
      'duration': '5 min',
    },
    {
      'issue': 'Hombros desalineados',
      'timestamp': '10:30 AM',
      'severity': 'medium',
      'duration': '2 min',
    },
    {
      'issue': 'Distancia muy corta a la pantalla',
      'timestamp': '09:50 AM',
      'severity': 'medium',
      'duration': '1 min',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de Postura')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final isHighSeverity = alert['severity'] == 'high';
          final isLast = index == _alerts.length - 1;

          final warningColor = isHighSeverity
              ? Colors.red.shade400
              : Colors.amber.shade700;
          final backgroundColor = isHighSeverity
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.amber.withValues(alpha: 0.1);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isHighSeverity
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline,
                        color: warningColor,
                        size: 20,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerLow,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alert['timestamp']!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Duración: ${alert['duration']}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alert['issue']!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
