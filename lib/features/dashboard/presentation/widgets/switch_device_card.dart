import 'package:flutter/material.dart';
import '../../../../data/db/app_database.dart';

class SwitchDeviceCard extends StatelessWidget {
  final Device device;

  const SwitchDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isOn = device.isOn ?? false;

    // Aktif duruma göre renk paletini belirliyoruz
    final bgColor = isOn
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainer;

    final iconColor = isOn
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final textColor = isOn
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // İleride InkWell ile tıklama eklenecek
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // TODO: MQTT Publish komutu gönderilecek
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    IconData(device.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: iconColor,
                  ),
                  Switch(
                    value: isOn,
                    onChanged: (val) {
                      // TODO: MQTT Publish komutu gönderilecek
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOn ? 'Açık' : 'Kapalı',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: iconColor.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
