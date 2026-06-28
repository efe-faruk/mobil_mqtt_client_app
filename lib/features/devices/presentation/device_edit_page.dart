import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart';

class DeviceEditPage extends ConsumerStatefulWidget {
  final String deviceId;

  const DeviceEditPage({super.key, required this.deviceId});

  @override
  ConsumerState<DeviceEditPage> createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends ConsumerState<DeviceEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _topicSetController;
  late TextEditingController _topicStateController;

  Device? _device;
  String? _selectedRoomId;
  String _selectedType = 'switch';
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
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _topicSetController = TextEditingController();
    _topicStateController = TextEditingController();

    // Cihaz verisini listesinden buluyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final devices = ref.read(devicesProvider).value ?? [];
      try {
        final device = devices.firstWhere((d) => d.id == widget.deviceId);
        setState(() {
          _device = device;
          _nameController.text = device.name;
          _topicSetController.text = device.topicSet ?? '';
          _topicStateController.text = device.topicState;
          _selectedRoomId = device.roomId;
          _selectedType = device.type;
          _selectedIcon =
              IconData(device.iconCodePoint, fontFamily: 'MaterialIcons');
        });
      } catch (e) {
        // Cihaz bulunamazsa geri dön
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cihaz bulunamadı')));
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _topicSetController.dispose();
    _topicStateController.dispose();
    super.dispose();
  }

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
    if (_selectedRoomId == null || _nameController.text.isEmpty) return;

    final rooms = ref.read(roomsProvider).value ?? [];
    final room = rooms.firstWhere((r) => r.id == _selectedRoomId);

    final rSlug = _generateSlug(room.name);
    final dSlug = _generateSlug(_nameController.text);

    setState(() {
      _topicStateController.text = 'home/$rSlug/$dSlug/state';
      if (_selectedType == 'switch') {
        _topicSetController.text = 'home/$rSlug/$dSlug/set';
      } else {
        _topicSetController.text = '';
      }
    });
  }

  Future<void> _updateDevice() async {
    if (_formKey.currentState!.validate() && _device != null) {
      final companion = DevicesCompanion(
        id: drift.Value(_device!.id),
        roomId: drift.Value(_selectedRoomId!),
        name: drift.Value(_nameController.text.trim()),
        type: drift.Value(_selectedType),
        topicSet: drift.Value(
            _selectedType == 'switch' ? _topicSetController.text.trim() : null),
        topicState: drift.Value(_topicStateController.text.trim()),
        iconCodePoint: drift.Value(_selectedIcon.codePoint),
        // createdAt ve isOn gibi değerleri veritabanı korur, update işleminde güncellemeyiz
      );

      await ref.read(deviceRepositoryProvider).updateDevice(companion);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cihaz güncellendi')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_device == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cihazı Düzenle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            roomsAsync.when(
              data: (rooms) => DropdownButtonFormField<String>(
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
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Hata: $err'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Cihaz Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge)),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Cihaz adı girin' : null,
            ),
            const SizedBox(height: 16),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _autoGenerateTopics,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Topicleri Otomatik Üret'),
              ),
            ),
            TextFormField(
              controller: _topicStateController,
              decoration: const InputDecoration(
                  labelText: 'State Topic',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.publish)),
              validator: (value) => value == null || value.isEmpty
                  ? 'State Topic zorunludur'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _topicSetController,
              enabled: _selectedType == 'switch',
              decoration: InputDecoration(
                labelText: 'Set Topic',
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
              onPressed: _updateDevice,
              icon: const Icon(Icons.save),
              label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Güncelle', style: TextStyle(fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }
}
