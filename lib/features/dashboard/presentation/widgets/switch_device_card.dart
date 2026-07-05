import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../data/db/app_database.dart';

class SwitchDeviceCard extends ConsumerWidget {
  final Device device;

  const SwitchDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Controller üzerinden arka plana (Isolate) komut fırlatıyoruz
          ref.read(mqttDeviceControllerProvider).toggleSwitch(device, !isOn);
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
                      // Controller üzerinden arka plana komut fırlatıyoruz
                      ref
                          .read(mqttDeviceControllerProvider)
                          .toggleSwitch(device, val);
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
