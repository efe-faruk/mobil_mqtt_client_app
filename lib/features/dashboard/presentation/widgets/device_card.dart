import 'package:flutter/material.dart';
import '../../../../data/db/app_database.dart';
import 'sensor_device_card.dart';
import 'switch_device_card.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    if (device.type == 'switch') {
      return SwitchDeviceCard(device: device);
    } else if (device.type == 'sensor') {
      return SensorDeviceCard(device: device);
    } else {
      // Desteklenmeyen bir tip gelirse boş bir güvenlik kutusu göster
      return const SizedBox.shrink();
    }
  }
}
