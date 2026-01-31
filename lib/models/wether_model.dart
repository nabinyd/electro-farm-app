class WeatherData {
  final String? name;
  final String? country;
  final double? lat;
  final double? lon;

  final String? main;
  final String? description;
  final String? icon;

  final double? temp;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? humidity;

  final double? windSpeed;

  WeatherData({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.main,
    required this.description,
    required this.icon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromApi(Map<String, dynamic> json) {
    // backend shape: { ok, cached, data: { location, weather, temp, wind, ... } }
    final data = (json["data"] ?? {}) as Map<String, dynamic>;
    final location = (data["location"] ?? {}) as Map<String, dynamic>;
    final weather = (data["weather"] ?? {}) as Map<String, dynamic>;
    final temp = (data["temp"] ?? {}) as Map<String, dynamic>;
    final wind = (data["wind"] ?? {}) as Map<String, dynamic>;

    return WeatherData(
      name: location["name"]?.toString(),
      country: location["country"]?.toString(),
      lat: (location["lat"] as num?)?.toDouble(),
      lon: (location["lon"] as num?)?.toDouble(),
      main: weather["main"]?.toString(),
      description: weather["description"]?.toString(),
      icon: weather["icon"]?.toString(),
      temp: (temp["current"] as num?)?.toDouble(),
      feelsLike: (temp["feels_like"] as num?)?.toDouble(),
      tempMin: (temp["min"] as num?)?.toDouble(),
      tempMax: (temp["max"] as num?)?.toDouble(),
      humidity: (temp["humidity"] as num?)?.toInt(),
      windSpeed: (wind["speed"] as num?)?.toDouble(),
    );
  }

  String get iconUrl {
    // OpenWeather icon
    final i = icon ?? "01d";
    return "https://openweathermap.org/img/wn/$i@2x.png";
  }
}
