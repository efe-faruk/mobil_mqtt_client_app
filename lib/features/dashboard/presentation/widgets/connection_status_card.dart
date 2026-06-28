import 'package:flutter/material.dart';

class ConnectionStatusCard extends StatelessWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bağlantı Bekleniyor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'MQTT servisi henüz başlatılmadı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            // İleride buraya "Bağlan" butonu veya spinner eklenebilir
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
