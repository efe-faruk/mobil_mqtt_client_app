import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../models/broker_config.dart';

class BrokerSettingsPage extends ConsumerStatefulWidget {
  const BrokerSettingsPage({super.key});

  @override
  ConsumerState<BrokerSettingsPage> createState() => _BrokerSettingsPageState();
}

class _BrokerSettingsPageState extends ConsumerState<BrokerSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _clientIdController;
  late TextEditingController _keepAliveController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  bool _useAuth = false;

  @override
  void initState() {
    super.initState();
    // Riverpod üzerinden mevcut ayarları bir kereliğine okuyoruz
    final config = ref.read(brokerConfigProvider);

    _hostController = TextEditingController(text: config.host);
    _portController = TextEditingController(text: config.port.toString());
    _clientIdController = TextEditingController(text: config.clientId);
    _keepAliveController =
        TextEditingController(text: config.keepAliveSeconds.toString());
    _usernameController = TextEditingController(text: config.username);
    _passwordController = TextEditingController(text: config.password);
    _useAuth = config.useAuth;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _clientIdController.dispose();
    _keepAliveController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final newConfig = BrokerConfig(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        clientId: _clientIdController.text.trim(),
        keepAliveSeconds: int.parse(_keepAliveController.text.trim()),
        useAuth: _useAuth,
        username: _useAuth ? _usernameController.text.trim() : '',
        password: _useAuth ? _passwordController.text.trim() : '',
      );

      // Notifier üzerinden yeni ayarları kaydedip State'i güncelliyoruz
      ref.read(brokerConfigProvider.notifier).updateConfig(newConfig).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Broker ayarları kaydedildi')),
          );
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Ayarları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 1. Sunucu Bilgileri Kartı
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sunucu Bilgileri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'Broker Host (IP veya Domain)',
                        hintText: 'Örn: 192.168.1.100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dns_outlined),
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Host adresi boş olamaz'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _portController,
                            decoration: const InputDecoration(
                              labelText: 'Port',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Boş';
                              if (int.tryParse(value) == null)
                                return 'Geçersiz';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _keepAliveController,
                            decoration: const InputDecoration(
                              labelText: 'Keep Alive (Sn)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Zorunlu';
                              if (int.tryParse(value) == null)
                                return 'Geçersiz';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _clientIdController,
                      decoration: const InputDecoration(
                        labelText: 'Client ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Client ID boş olamaz'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Kimlik Doğrulama Kartı
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güvenlik',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SwitchListTile(
                      title: const Text('Kimlik Doğrulaması Kullan'),
                      subtitle: const Text('Kullanıcı adı ve şifre gerektirir'),
                      contentPadding: EdgeInsets.zero,
                      value: _useAuth,
                      onChanged: (val) {
                        setState(() {
                          _useAuth = val;
                        });
                      },
                    ),
                    if (_useAuth) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            _useAuth && (value == null || value.isEmpty)
                                ? 'Kullanıcı adı gereklidir'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            _useAuth && (value == null || value.isEmpty)
                                ? 'Şifre gereklidir'
                                : null,
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 3. Kaydet Butonu
            FilledButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Ayarları Kaydet',
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
