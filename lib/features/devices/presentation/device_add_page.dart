import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart';

class DeviceAddPage extends ConsumerStatefulWidget {
  const DeviceAddPage({super.key});

  @override
  ConsumerState<DeviceAddPage> createState() => _DeviceAddPageState();
}

class _DeviceAddPageState extends ConsumerState<DeviceAddPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _topicSetController = TextEditingController();
  final _topicStateController = TextEditingController();

  String? _selectedRoomId;
  String _selectedType = 'switch'; // 'switch' veya 'sensor'
  IconData _selectedIcon = Icons.lightbulb_outline;

  final List<IconData> _availableIcons = [
    Icons.lightbulb_outline,
    Icons.power,
    Icons.thermostat,
    Icons.water_drop_outlined,
    Icons.air,
    Icons.sensors,
    Icons.door_front_door_outlined,
    Icons.tv,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _topicSetController.dispose();
    _topicStateController.dispose();
    super.dispose();
  }

  /// Basit bir metni MQTT topic formatına (slug) çevirir (Türkçe karakter destekli)
  String _generateSlug(String text) {
    const trMap = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'Ç': 'c',
      'Ğ': 'g',
      'İ': 'i',
      'Ö': 'o',
      'Ş': 's',
      'Ü': 'u'
    };
    String result = text;
    trMap.forEach((key, value) => result = result.replaceAll(key, value));
    return result
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  void _autoGenerateTopics() {
    if (_selectedRoomId == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen önce oda seçin ve cihaz adını girin.')),
      );
      return;
    }

    final rooms = ref.read(roomsProvider).value ?? [];
    final room = rooms.firstWhere((r) => r.id == _selectedRoomId);

    final rSlug = _generateSlug(room.name);
    final dSlug = _generateSlug(_nameController.text);

    setState(() {
      _topicStateController.text = 'home/$rSlug/$dSlug/state';
      if (_selectedType == 'switch') {
        _topicSetController.text = 'home/$rSlug/$dSlug/set';
      } else {
        _topicSetController.text =
            ''; // Sensörler için set komutu opsiyonel/gereksiz
      }
    });
  }

  Future<void> _saveDevice() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoomId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen bir oda seçin.')));
        return;
      }

      final deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}';

      final companion = DevicesCompanion(
        id: drift.Value(deviceId),
        roomId: drift.Value(_selectedRoomId!),
        name: drift.Value(_nameController.text.trim()),
        type: drift.Value(_selectedType),
        topicSet: drift.Value(
            _selectedType == 'switch' ? _topicSetController.text.trim() : null),
        topicState: drift.Value(_topicStateController.text.trim()),
        iconCodePoint: drift.Value(_selectedIcon.codePoint),
        createdAt: drift.Value(DateTime.now()),
        isOn: const drift.Value(false),
      );

      await ref.read(deviceRepositoryProvider).addDevice(companion);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cihaz eklendi')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Cihaz Ekle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Oda Seçimi
            roomsAsync.when(
              data: (rooms) {
                if (rooms.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                          'Lütfen cihaz eklemeden önce en az bir oda oluşturun.',
                          style: TextStyle(color: Colors.red)),
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Oda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.meeting_room)),
                  value: _selectedRoomId,
                  items: rooms
                      .map((r) =>
                          DropdownMenuItem(value: r.id, child: Text(r.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRoomId = val),
                  validator: (val) =>
                      val == null ? 'Oda seçimi zorunludur' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Hata: $err'),
            ),
            const SizedBox(height: 16),

            // Cihaz Adı
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Cihaz Adı',
                  hintText: 'Örn: Tavan Lambası',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge)),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Cihaz adı girin' : null,
            ),
            const SizedBox(height: 16),

            // Cihaz Tipi
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Cihaz Tipi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category)),
              value: _selectedType,
              items: const [
                DropdownMenuItem(
                    value: 'switch', child: Text('Anahtar (Aç/Kapat)')),
                DropdownMenuItem(
                    value: 'sensor', child: Text('Sensör (Veri Okuma)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 24),

            // Topic Üretici Buton
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _autoGenerateTopics,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Topicleri Otomatik Üret'),
              ),
            ),

            // Topic State
            TextFormField(
              controller: _topicStateController,
              decoration: const InputDecoration(
                  labelText: 'State Topic',
                  hintText: 'home/salon/lamba/state',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.publish)),
              validator: (value) => value == null || value.isEmpty
                  ? 'State Topic zorunludur'
                  : null,
            ),
            const SizedBox(height: 16),

            // Topic Set (Sadece Switch için zorunlu)
            TextFormField(
              controller: _topicSetController,
              enabled: _selectedType == 'switch',
              decoration: InputDecoration(
                labelText: 'Set Topic',
                hintText: 'home/salon/lamba/set',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.download),
                filled: _selectedType != 'switch',
              ),
              validator: (value) {
                if (_selectedType == 'switch' &&
                    (value == null || value.isEmpty)) {
                  return 'Anahtar cihazlar için Set Topic zorunludur';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // İkon Seçimi
            Text('Cihaz İkonu', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return ChoiceChip(
                      label: Icon(icon,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (selected) =>
                          setState(() => _selectedIcon = icon),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saveDevice,
              icon: const Icon(Icons.save),
              label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Kaydet', style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
