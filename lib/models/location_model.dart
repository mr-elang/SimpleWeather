/// Model representing a geographic location returned by Open-Meteo Geocoding API
/// and stored locally for favorites or search history.
class LocationModel {
  final int id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  /// Creates a [LocationModel] from Open-Meteo Geocoding JSON or local storage JSON.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Serializes this [LocationModel] into a JSON map for local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Human-readable subtitle combining administrative region and country.
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}
