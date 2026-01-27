import 'package:electro_farm/ui/flow/app_flow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'services/socket_service.dart';
import 'providers/telemetry_provider.dart';
import 'ui/dashboard_screen.dart';

void main() {
  runApp(const AgriBotApp());
}

class AgriBotApp extends StatelessWidget {
  const AgriBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final socket = SocketService(baseUrl: AppConfig.backendUrl);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TelemetryProvider(socketService: socket),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "AgriBot Dashboard",
        theme: ThemeData(useMaterial3: true),
        // home: const DashboardScreen(),
        home: const AppFlow(),
      ),
    );
  }
}
