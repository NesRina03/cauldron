class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final List<String> substitutes;
  final bool isInPantry;

  Ingredient({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.unit = '',
    this.substitutes = const [],
    this.isInPantry = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'substitutes': substitutes,
        'isInPantry': isInPantry,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String? ?? '',
        substitutes: (json['substitutes'] as List?)?.cast<String>() ?? [],
        isInPantry: json['isInPantry'] as bool? ?? false,
      );

  Ingredient copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    List<String>? substitutes,
    bool? isInPantry,
  }) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        substitutes: substitutes ?? this.substitutes,
        isInPantry: isInPantry ?? this.isInPantry,
      );
}
