class TapHeart {
  final String id;
  final String surfaceId;
  final double x;
  final double y;

  const TapHeart({
    required this.id,
    required this.surfaceId,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'surfaceId': surfaceId,
    'x': x,
    'y': y,
  };

  factory TapHeart.fromMap(Map<String, dynamic> map) => TapHeart(
    id: map['id'] as String? ?? '',
    surfaceId: map['surfaceId'] as String? ?? 'legacy',
    x: (map['x'] as num? ?? 0.5).clamp(0.0, 1.0).toDouble(),
    y: (map['y'] as num? ?? 0.5).clamp(0.0, 1.0).toDouble(),
  );
}
