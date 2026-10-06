import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'calculation_history_item.dart';

class CalculationHistoryRepository {
  CalculationHistoryRepository({
    this.maxRecentItems = 200,
  });

  static const String _storageKey =
      'scientific_calculator_history_v1';

  final int maxRecentItems;

  Future<List<CalculationHistoryItem>> load() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String? raw =
        preferences.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return <CalculationHistoryItem>[];
    }

    try {
      final Object? decoded = jsonDecode(raw);

      if (decoded is! List<dynamic>) {
        return <CalculationHistoryItem>[];
      }

      final List<CalculationHistoryItem> items =
          <CalculationHistoryItem>[];

      for (final dynamic value in decoded) {
        if (value is Map<String, dynamic>) {
          final CalculationHistoryItem item =
              CalculationHistoryItem.fromJson(value);

          if (item.id.isNotEmpty &&
              item.expression.isNotEmpty) {
            items.add(item);
          }
        } else if (value is Map) {
          final Map<String, dynamic> converted =
              value.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(
              key.toString(),
              value,
            ),
          );

          final CalculationHistoryItem item =
              CalculationHistoryItem.fromJson(converted);

          if (item.id.isNotEmpty &&
              item.expression.isNotEmpty) {
            items.add(item);
          }
        }
      }

      items.sort(
        (
          CalculationHistoryItem a,
          CalculationHistoryItem b,
        ) =>
            b.createdAt.compareTo(a.createdAt),
      );

      return items;
    } catch (_) {
      return <CalculationHistoryItem>[];
    }
  }

  Future<CalculationHistoryItem> add({
    required String expression,
    required String result,
    String mode = 'COMP',
  }) async {
    final String cleanExpression =
        expression.trim();
    final String cleanResult = result.trim();

    if (cleanExpression.isEmpty ||
        cleanResult.isEmpty ||
        cleanResult == 'Error') {
      throw const FormatException(
        'Only successful calculations can be saved.',
      );
    }

    final List<CalculationHistoryItem> items =
        await load();

    final int existingIndex = items.indexWhere(
      (CalculationHistoryItem item) =>
          item.expression == cleanExpression &&
          item.result == cleanResult &&
          item.mode == mode,
    );

    bool wasFavorite = false;
    String? previousId;

    if (existingIndex >= 0) {
      wasFavorite = items[existingIndex].isFavorite;
      previousId = items[existingIndex].id;
      items.removeAt(existingIndex);
    }

    final DateTime now = DateTime.now();

    final CalculationHistoryItem item =
        CalculationHistoryItem(
      id: previousId ??
          '${now.microsecondsSinceEpoch}_'
              '${cleanExpression.hashCode.abs()}',
      expression: cleanExpression,
      result: cleanResult,
      mode: mode,
      createdAt: now,
      isFavorite: wasFavorite,
    );

    items.insert(0, item);

    await _save(_trim(items));

    return item;
  }

  Future<void> toggleFavorite(String id) async {
    final List<CalculationHistoryItem> items =
        await load();

    final int index = items.indexWhere(
      (CalculationHistoryItem item) =>
          item.id == id,
    );

    if (index < 0) return;

    items[index] = items[index].copyWith(
      isFavorite: !items[index].isFavorite,
    );

    await _save(items);
  }

  Future<void> delete(String id) async {
    final List<CalculationHistoryItem> items =
        await load();

    items.removeWhere(
      (CalculationHistoryItem item) =>
          item.id == id,
    );

    await _save(items);
  }

  Future<void> clearNonFavorites() async {
    final List<CalculationHistoryItem> items =
        await load();

    final List<CalculationHistoryItem> favorites =
        items
            .where(
              (CalculationHistoryItem item) =>
                  item.isFavorite,
            )
            .toList();

    await _save(favorites);
  }

  Future<void> clearAll() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }

  List<CalculationHistoryItem> _trim(
    List<CalculationHistoryItem> items,
  ) {
    final List<CalculationHistoryItem> favorites =
        items
            .where(
              (CalculationHistoryItem item) =>
                  item.isFavorite,
            )
            .toList();

    final List<CalculationHistoryItem> recent =
        items
            .where(
              (CalculationHistoryItem item) =>
                  !item.isFavorite,
            )
            .take(maxRecentItems)
            .toList();

    final List<CalculationHistoryItem> combined =
        <CalculationHistoryItem>[
      ...favorites,
      ...recent,
    ];

    combined.sort(
      (
        CalculationHistoryItem a,
        CalculationHistoryItem b,
      ) =>
          b.createdAt.compareTo(a.createdAt),
    );

    return combined;
  }

  Future<void> _save(
    List<CalculationHistoryItem> items,
  ) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      items
          .map(
            (CalculationHistoryItem item) =>
                item.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }
}
