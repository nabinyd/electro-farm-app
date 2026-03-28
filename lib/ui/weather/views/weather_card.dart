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
      // TODO: only fetch if not already fetched recently (e.g. within 1 min)
      // context.read<WeatherProvider>().fetchFromDevice();
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.network(
              w.iconUrl,
              errorBuilder: (_, _, _) => const Icon(Icons.cloud),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.name ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${w.temp?.toStringAsFixed(1) ?? "--"}°C • ${w.humidity ?? "--"}%",
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
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
