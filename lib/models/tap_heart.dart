class TapHeart {
  final String id;
  final String surfaceId;
  final double x;
  final double contentY;

  const TapHeart({
    required this.id,
    required this.surfaceId,
    required this.x,
    required this.contentY,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'surfaceId': surfaceId,
    'x': x,
    'contentY': contentY,
  };

  factory TapHeart.fromMap(Map<String, dynamic> map) => TapHeart(
    id: map['id'] as String? ?? '',
    surfaceId: map['surfaceId'] as String? ?? 'legacy',
    x: (map['x'] as num? ?? 0.5).clamp(0.0, 1.0).toDouble(),
    contentY: map['contentY'] is num
        ? (map['contentY'] as num).toDouble()
        : ((map['y'] as num? ?? 0.5).clamp(0.0, 1.0) * 800).toDouble(),
  );
}
