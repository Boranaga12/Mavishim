class WheelModel {
  final String id;
  final String title;
  final String iconName;
  final List<String> options;
  final bool isCustom;

  WheelModel({
    required this.id,
    required this.title,
    required this.iconName,
    required List<String> options,
    this.isCustom = false,
  }) : options = List.unmodifiable(options);

  WheelModel copyWith({String? title, List<String>? options}) {
    return WheelModel(
      id: id,
      title: title ?? this.title,
      iconName: iconName,
      options: options ?? this.options,
      isCustom: isCustom,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'iconName': iconName,
    'options': options,
    'isCustom': isCustom,
  };

  factory WheelModel.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    return WheelModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'star',
      options: rawOptions is List
          ? rawOptions.whereType<String>().toList()
          : const [],
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }
}
