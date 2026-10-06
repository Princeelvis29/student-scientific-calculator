class CalculationHistoryItem {
  const CalculationHistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.mode,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String expression;
  final String result;
  final String mode;
  final DateTime createdAt;
  final bool isFavorite;

  CalculationHistoryItem copyWith({
    String? id,
    String? expression,
    String? result,
    String? mode,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return CalculationHistoryItem(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'expression': expression,
      'result': result,
      'mode': mode,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory CalculationHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final DateTime parsedTime =
        DateTime.tryParse(
          json['createdAt']?.toString() ?? '',
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return CalculationHistoryItem(
      id: json['id']?.toString() ?? '',
      expression: json['expression']?.toString() ?? '',
      result: json['result']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'COMP',
      createdAt: parsedTime,
      isFavorite: json['isFavorite'] == true,
    );
  }
}
