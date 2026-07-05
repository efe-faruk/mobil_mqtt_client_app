class RoomModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final int sortOrder;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.sortOrder,
    required this.createdAt,
  });

  RoomModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
