enum BookingStatus {
  pending,
  active,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String userId;
  final String stationId;
  final String slotId;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final double price;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.stationId,
    required this.slotId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.price,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['\$id'] ?? json['id'] ?? '',
      userId: json['user_id'] ?? '',
      stationId: json['station_id'] ?? '',
      slotId: json['slot_id'] ?? '',
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      price: (json['price'] ?? 0.0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'station_id': stationId,
      'slot_id': slotId,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'price': price,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? stationId,
    String? slotId,
    BookingStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? price,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      slotId: slotId ?? this.slotId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == BookingStatus.active;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  bool get isPending => status == BookingStatus.pending;

  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }
}
