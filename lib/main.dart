import 'package:electro_farm/app_shell.dart';
import 'package:electro_farm/providers/wether_provider.dart';
import 'package:electro_farm/ui/flow/app_flow.dart';
import 'package:electro_farm/ui/inspections/providers/frames_provider.dart';
import 'package:electro_farm/ui/inspections/providers/inpection_run_provider.dart';
import 'package:electro_farm/ui/inspections/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'services/socket_service.dart';
import 'providers/telemetry_provider.dart';

void main() {
  runApp(const AgriBotApp());
}

class AgriBotApp extends StatelessWidget {
  const AgriBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final socket = SocketService(baseUrl: AppConfig.backendUrl);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF0A264D),
      scaffoldBackgroundColor: const Color(0xFFF7F8FA),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TelemetryProvider(socketService: socket),
        ),
        ChangeNotifierProvider(create: (_) => RunsProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => FramesProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: "Electro Farm",
        theme: base.copyWith(
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
        home: const AppShell(),
      ),
    );
  }
}
