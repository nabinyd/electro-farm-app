import 'package:electro_farm/custom_component/constant.dart';
import 'package:electro_farm/providers/arm_joint_provider.dart';
import 'package:electro_farm/providers/esp_camera_provider.dart';
import 'package:electro_farm/providers/pi_camera_frame_provider.dart';
import 'package:electro_farm/providers/control_bridge_provider.dart';
import 'package:electro_farm/providers/inspection_provider.dart';
import 'package:electro_farm/providers/vision_processor_provider.dart';
import 'package:electro_farm/providers/wether_provider.dart';
import 'package:electro_farm/splash_screen.dart';
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
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TelemetryProvider(socketService: socket),
        ),
        ChangeNotifierProvider(
          create: (_) => PiCameraFrameProvider(socketService: socket),
        ),
        ChangeNotifierProvider(
          create: (_) => EspCameraProvider(socketService: socket),
        ),
        ChangeNotifierProvider(
          create: (_) => VisionProcessorProvider(socketService: socket),
        ),
        ChangeNotifierProvider(
          create: (_) => InspectionProvider(socket: socket),
        ),
        ChangeNotifierProvider(
          create: (_) => ArmJointControlProvider(socket: socket),
        ),
        ChangeNotifierProvider(create: (_) => ControlProvider(socket)),
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
        home: const SplashScreen(),
      ),
    );
  }
}
