import 'package:string_similarity/string_similarity.dart';

/// Generic fuzzy search utility for filtering and ranking items
class FuzzySearch<T> {
  /// Performs a fuzzy hybrid search on a list of items
  /// 
  /// [items] - List of items to search through
  /// [query] - Search query string
  /// [getSearchableText] - Function to extract searchable text from an item
  /// [threshold] - Minimum similarity threshold (0.0 - 1.0), default 0.2
  /// 
  /// Returns a list of items sorted by relevance
  static List<T> search<T>({
    required List<T> items,
    required String query,
    required String Function(T) getSearchableText,
    double threshold = 0.2,
  }) {
    if (query.isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase();
    final isShortQuery = query.length <= 3;

    // First pass: Filter by prefix (for short queries) or contains (for longer queries)
    final prefixFiltered = items.where((item) {
      final text = getSearchableText(item).toLowerCase();
      if (isShortQuery) {
        return text.startsWith(lowerQuery);
      } else {
        return text.startsWith(lowerQuery) || text.contains(lowerQuery);
      }
    });

    // Second pass: Score by similarity
    final scored = prefixFiltered.map(
      (item) => MapEntry(
        item,
        getSearchableText(item).toLowerCase().similarityTo(lowerQuery),
      ),
    );

    // Third pass: Filter by threshold and sort by score
    final scoredFiltered = scored
        .where((entry) => entry.value > threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scoredFiltered.map((entry) => entry.key).toList();
  }

  /// Performs a fuzzy hybrid search with multiple searchable fields
  /// 
  /// [items] - List of items to search through
  /// [query] - Search query string
  /// [getSearchableFields] - Function to extract list of searchable texts from an item
  /// [threshold] - Minimum similarity threshold (0.0 - 1.0), default 0.2
  /// [fieldWeights] - Optional weights for each field (must match fields count)
  /// 
  /// Returns a list of items sorted by relevance
  static List<T> searchMultiField<T>({
    required List<T> items,
    required String query,
    required List<String> Function(T) getSearchableFields,
    double threshold = 0.2,
    List<double>? fieldWeights,
  }) {
    if (query.isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase();
    final isShortQuery = query.length <= 3;

    // First pass: Filter items that match in any field
    final prefixFiltered = items.where((item) {
      final fields = getSearchableFields(item);
      return fields.any((field) {
        final text = field.toLowerCase();
        if (isShortQuery) {
          return text.startsWith(lowerQuery);
        } else {
          return text.startsWith(lowerQuery) || text.contains(lowerQuery);
        }
      });
    });

    // Second pass: Score each item by best field match
    final scored = prefixFiltered.map((item) {
      final fields = getSearchableFields(item);
      double maxScore = 0.0;

      for (int i = 0; i < fields.length; i++) {
        final similarity = fields[i].toLowerCase().similarityTo(lowerQuery);
        final weight = fieldWeights != null && i < fieldWeights.length
            ? fieldWeights[i]
            : 1.0;
        final weightedScore = similarity * weight;
        
        if (weightedScore > maxScore) {
          maxScore = weightedScore;
        }
      }

      return MapEntry(item, maxScore);
    });

    // Third pass: Filter by threshold and sort by score
    final scoredFiltered = scored
        .where((entry) => entry.value > threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scoredFiltered.map((entry) => entry.key).toList();
  }
}
