class DeviceModel {
  final String id;
  final String roomId;
  final String name;
  final String type; // 'switch' or 'sensor'
  final String? topicSet;
  final String topicState;
  final String? lastValue;
  final bool? isOn;
  final int iconCodePoint;
  final DateTime createdAt;

  DeviceModel({
    required this.id,
    required this.roomId,
    required this.name,
    required this.type,
    this.topicSet,
    required this.topicState,
    this.lastValue,
    this.isOn,
    required this.iconCodePoint,
    required this.createdAt,
  });

  DeviceModel copyWith({
    String? id,
    String? roomId,
    String? name,
    String? type,
    String? topicSet,
    String? topicState,
    String? lastValue,
    bool? isOn,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      type: type ?? this.type,
      topicSet: topicSet ?? this.topicSet,
      topicState: topicState ?? this.topicState,
      lastValue: lastValue ?? this.lastValue,
      isOn: isOn ?? this.isOn,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
