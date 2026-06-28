import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/db/app_database.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/devices/presentation/device_add_page.dart';
import '../../features/devices/presentation/device_edit_page.dart';
import '../../features/devices/presentation/devices_page.dart';
import '../../features/rooms/presentation/room_edit_page.dart';
import '../../features/rooms/presentation/rooms_page.dart';
import '../../features/settings/presentation/broker_settings_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/settings/presentation/mqtt_debug_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ShellRoute: Alt sekmeleri saran ve sabit bir BottomNavigationBar sunan kabuk yapı
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShellScaffold(child: child);
        },
        routes: [
          // 1. Sekme: Dashboard
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),

          // 2. Sekme: Odalar ve Alt Rotaları
          GoRoute(
            path: '/rooms',
            builder: (context, state) => const RoomsPage(),
            routes: [
              GoRoute(
                path: 'edit', // Tam yol: /rooms/edit
                builder: (context, state) =>
                    RoomEditPage(room: state.extra as Room?),
              ),
            ],
          ),

          // 3. Sekme: Cihazlar ve Alt Rotaları
          GoRoute(
            path: '/devices',
            builder: (context, state) => const DevicesPage(),
            routes: [
              GoRoute(
                path: 'add', // Tam yol: /devices/add
                builder: (context, state) => const DeviceAddPage(),
              ),
              GoRoute(
                path: 'edit/:id', // Tam yol: /devices/edit/cihaz_id_ornek
                builder: (context, state) {
                  final deviceId = state.pathParameters['id'] ?? '';
                  return DeviceEditPage(deviceId: deviceId);
                },
              ),
            ],
          ),

          // 4. Sekme: Ayarlar ve Alt Rotaları
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'broker', // Tam yol: /settings/broker
                builder: (context, state) => const BrokerSettingsPage(),
              ),
              GoRoute(
                path: 'mqtt-debug', // Tam yol: /settings/mqtt-debug
                builder: (context, state) => const MqttDebugPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ShellRoute'un gövdesini oluşturan, sekmeler arası geçişi sağlayan dahili Scaffold
class MainShellScaffold extends StatelessWidget {
  final Widget child;

  const MainShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(state.uri.SkinnerPath),
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Özet'),
          NavigationDestination(
              icon: Icon(Icons.meeting_room_outlined),
              selectedIcon: Icon(Icons.meeting_room),
              label: 'Odalar'),
          NavigationDestination(
              icon: Icon(Icons.developer_board_outlined),
              selectedIcon: Icon(Icons.developer_board),
              label: 'Cihazlar'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Ayarlar'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/rooms')) return 1;
    if (location.startsWith('/devices')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0; // Varsayılan Dashboard
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/rooms');
        break;
      case 2:
        context.go('/devices');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

extension on Uri {
  String get SkinnerPath => path;
}
