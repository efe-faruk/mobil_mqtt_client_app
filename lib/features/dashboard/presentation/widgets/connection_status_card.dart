import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';

class ConnectionStatusCard extends ConsumerWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // IsolateCommunicator'dan gelen durumu (String) dinliyoruz
    final status = ref.watch(mqttConnectionStatusProvider);

    // Duruma göre UI bileşenlerini belirlemek için değişkenler
    Color bgColor;
    Color iconColor;
    IconData iconData;
    String title;
    String subtitle;
    bool showSpinner = false;

    switch (status) {
      case 'connected':
        bgColor = Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.onPrimaryContainer;
        iconData = Icons.cloud_done_rounded;
        title = 'Sisteme Bağlı';
        subtitle = 'Cihazlarla iletişim aktif';
        break;
      case 'connecting':
        bgColor = Theme.of(context).colorScheme.tertiaryContainer;
        iconColor = Theme.of(context).colorScheme.onTertiaryContainer;
        iconData = Icons.cloud_sync_rounded;
        title = 'Bağlanıyor...';
        subtitle = 'Broker ile iletişim kuruluyor';
        showSpinner = true;
        break;
      case 'fault':
        bgColor = Theme.of(context).colorScheme.errorContainer;
        iconColor = Theme.of(context).colorScheme.onErrorContainer;
        iconData = Icons.error_outline_rounded;
        title = 'Bağlantı Hatası';
        subtitle = 'Lütfen ayarları kontrol edin';
        break;
      case 'disconnected':
      default:
        bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
        iconData = Icons.cloud_off_rounded;
        title = 'Çevrimdışı';
        subtitle = 'MQTT servisi şu an inaktif';
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: iconColor.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
            if (showSpinner)
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
