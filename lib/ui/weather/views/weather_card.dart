import 'package:electro_farm/providers/wether_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();

    // Kathmandu default for now (you can later use GPS)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchFromDevice();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<WeatherProvider>();

    if (p.loading && p.weather == null) {
      return const _Shell(child: Center(child: CircularProgressIndicator()));
    }

    if (p.error != null && p.weather == null) {
      return _Shell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weather",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(p.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  context.read<WeatherProvider>().fetchFromDevice(force: true),

              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final w = p.weather;
    if (w == null) return const SizedBox.shrink();

    return _Shell(
      child: Row(
        children: [
          // icon
          SizedBox(
            width: 52,
            height: 52,
            child: Image.network(
              w.iconUrl,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.cloud, size: 40);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${w.name ?? "Unknown"}${w.country != null ? ", ${w.country}" : ""}",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  (w.description ?? w.main ?? "—").toString(),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  children: [
                    Text("🌡️ ${w.temp?.toStringAsFixed(1) ?? "--"}°C"),
                    Text("💧 ${w.humidity ?? "--"}%"),
                    Text("💨 ${w.windSpeed?.toStringAsFixed(1) ?? "--"} m/s"),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Refresh",
            onPressed: () => context.read<WeatherProvider>().fetchLatLon(
              lat: 27.7172,
              lon: 85.3240,
              force: true,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}
