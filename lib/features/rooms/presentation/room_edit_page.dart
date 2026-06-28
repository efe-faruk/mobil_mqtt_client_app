import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/app_providers.dart';
import '../../../data/db/app_database.dart'; // Room ve RoomsCompanion için

class RoomEditPage extends ConsumerStatefulWidget {
  final Room? room; // Eğer null ise Ekleme modu, dolu ise Düzenleme modu

  const RoomEditPage({super.key, this.room});

  @override
  ConsumerState<RoomEditPage> createState() => _RoomEditPageState();
}

class _RoomEditPageState extends ConsumerState<RoomEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _sortOrderController;

  late IconData _selectedIcon;

  // Kullanıcının seçebileceği bazı hazır ikonlar
  final List<IconData> _availableIcons = [
    Icons.meeting_room,
    Icons.chair,
    Icons.bed,
    Icons.restaurant,
    Icons.bathtub,
    Icons.tv,
    Icons.garage,
    Icons.balcony,
    Icons.work,
  ];

  @override
  void initState() {
    super.initState();
    // Eğer düzenleme modundaysak mevcut bilgileri dolduruyoruz
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _sortOrderController =
        TextEditingController(text: widget.room?.sortOrder.toString() ?? '0');
    _selectedIcon = widget.room != null
        ? IconData(widget.room!.iconCodePoint, fontFamily: 'MaterialIcons')
        : _availableIcons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(roomRepositoryProvider);
      final isEdit = widget.room != null;

      // Benzersiz bir ID üretiyoruz (Yeni ekleme için)
      final roomId = isEdit
          ? widget.room!.id
          : 'room_${DateTime.now().millisecondsSinceEpoch}';

      // Drift için Companion nesnesi oluşturuyoruz
      final companion = RoomsCompanion(
        id: drift.Value(roomId),
        name: drift.Value(_nameController.text.trim()),
        iconCodePoint: drift.Value(_selectedIcon.codePoint),
        sortOrder: drift.Value(int.tryParse(_sortOrderController.text) ?? 0),
        createdAt:
            drift.Value(isEdit ? widget.room!.createdAt : DateTime.now()),
      );

      if (isEdit) {
        await repo.updateRoom(companion);
      } else {
        await repo.addRoom(companion);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Oda güncellendi' : 'Yeni oda eklendi'),
          ),
        );
        context.pop(); // Sayfadan çık
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Odayı Düzenle' : 'Yeni Oda Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // İkon Seçici Yuvarlak Alan
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedIcon,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Oda Adı
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Oda Adı',
                hintText: 'Örn: Oturma Odası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen bir oda adı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Sıralama (Sort Order)
            TextFormField(
              controller: _sortOrderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sıra Numarası',
                hintText: 'Örn: 0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sort),
                helperText: 'Odalar listelenirken bu sıraya göre dizilir',
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    int.tryParse(value) == null) {
                  return 'Lütfen geçerli bir sayı girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // İkon Seçim Paleti
            Text(
              'Oda İkonu Seçin',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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
                      label: Icon(
                        icon,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      onSelected: (selected) {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Kaydet Butonu
            FilledButton.icon(
              onPressed: _saveRoom,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Kaydet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
