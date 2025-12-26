class Ingredient {
  final String id;
  final String name;
  final String amount;
  final List<String> substitutes;
  final bool isInPantry;

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    this.substitutes = const [],
    this.isInPantry = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'substitutes': substitutes,
    'isInPantry': isInPantry,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json['id'] as String,
    name: json['name'] as String,
    amount: json['amount'] as String,
    substitutes: (json['substitutes'] as List?)?.cast<String>() ?? [],
    isInPantry: json['isInPantry'] as bool? ?? false,
  );

  Ingredient copyWith({
    String? id,
    String? name,
    String? amount,
    List<String>? substitutes,
    bool? isInPantry,
  }) => Ingredient(
    id: id ?? this.id,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    substitutes: substitutes ?? this.substitutes,
    isInPantry: isInPantry ?? this.isInPantry,
  );
}
