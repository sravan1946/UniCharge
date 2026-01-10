class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // parking, charging, hybrid
  final double pricePerHour;
  final bool batterySwap;
  final String address;
  final int totalSlots;
  final int availableSlots;
  final double rating;
  final List<String> amenities;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.pricePerHour,
    required this.batterySwap,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.rating,
    this.amenities = const [],
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['\$id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'hybrid',
      pricePerHour: (json['price_per_hour'] ?? 0.0).toDouble(),
      batterySwap: json['battery_swap'] ?? false,
      address: json['address'] ?? '',
      totalSlots: json['total_slots'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'price_per_hour': pricePerHour,
      'battery_swap': batterySwap,
      'address': address,
      'total_slots': totalSlots,
      'available_slots': availableSlots,
      'rating': rating,
      'amenities': amenities,
    };
  }

  Station copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? type,
    double? pricePerHour,
    bool? batterySwap,
    String? address,
    int? totalSlots,
    int? availableSlots,
    double? rating,
    List<String>? amenities,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      batterySwap: batterySwap ?? this.batterySwap,
      address: address ?? this.address,
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      rating: rating ?? this.rating,
      amenities: amenities ?? this.amenities,
    );
  }
}
