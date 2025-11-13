import 'package:string_similarity/string_similarity.dart';

/// Generic fuzzy search utility for filtering and ranking items
class FuzzySearch<T> {
  // Helper: check whether pattern is a subsequence of text (characters in order)
  static bool _isSubsequence(String pattern, String text) {
    if (pattern.isEmpty) return true;
    int j = 0;
    for (int i = 0; i < text.length && j < pattern.length; i++) {
      if (text.codeUnitAt(i) == pattern.codeUnitAt(j)) j++;
    }
    return j == pattern.length;
  }

  static List<T> search<T>({
    required List<T> items,
    required String query,
    required String Function(T) getSearchableText,
    double threshold = 0.2,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    final isShortQuery = lowerQuery.length <= 3;

    // First pass: keep candidates that at least contain the characters in order
    final candidates = items.where((item) {
      final text = getSearchableText(item).toLowerCase();
      // For short queries: allow startsWith OR subsequence OR contains (to be permissive)
      if (isShortQuery) {
        return text.startsWith(lowerQuery) ||
            _isSubsequence(lowerQuery, text) ||
            text.contains(lowerQuery);
      } else {
        // For longer queries: require startsWith or contains
        return text.startsWith(lowerQuery) || text.contains(lowerQuery);
      }
    });

    // Score candidates. Boost prefix > subsequence > similarity
    final scored = candidates.map((item) {
      final text = getSearchableText(item).toLowerCase();
      double score;

      if (text == lowerQuery) {
        score = 1.0; // exact match
      } else if (text.startsWith(lowerQuery)) {
        score = 0.98; // strong prefix boost
      } else if (isShortQuery && _isSubsequence(lowerQuery, text)) {
        score = 0.85; // subsequence match boost for short queries
      } else {
        score = StringSimilarity.compareTwoStrings(text, lowerQuery);
      }

      return MapEntry(item, score);
    });

    final scoredFiltered = scored
        .where((entry) => entry.value >= threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scoredFiltered.map((e) => e.key).toList();
  }

  static List<T> searchMultiField<T>({
    required List<T> items,
    required String query,
    required List<String> Function(T) getSearchableFields,
    double threshold = 0.2,
    List<double>? fieldWeights,
  }) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();
    final isShortQuery = lowerQuery.length <= 3;

    final candidates = items.where((item) {
      final fields = getSearchableFields(item);
      return fields.any((f) {
        final text = f.toLowerCase();
        if (isShortQuery) {
          return text.startsWith(lowerQuery) ||
              _isSubsequence(lowerQuery, text) ||
              text.contains(lowerQuery);
        } else {
          return text.startsWith(lowerQuery) || text.contains(lowerQuery);
        }
      });
    });

    final scored = candidates.map((item) {
      final fields = getSearchableFields(item);
      double maxScore = 0.0;

      for (int i = 0; i < fields.length; i++) {
        final fieldText = fields[i].toLowerCase();
        double similarity;

        if (fieldText == lowerQuery) {
          similarity = 1.0;
        } else if (fieldText.startsWith(lowerQuery)) {
          similarity = 0.98;
        } else if (isShortQuery && _isSubsequence(lowerQuery, fieldText)) {
          similarity = 0.85;
        } else {
          similarity =
              StringSimilarity.compareTwoStrings(fieldText, lowerQuery);
        }

        final weight = (fieldWeights != null && i < fieldWeights.length)
            ? fieldWeights[i]
            : 1.0;
        final weighted = similarity * weight;
        if (weighted > maxScore) maxScore = weighted;
      }

      return MapEntry(item, maxScore);
    });

    final scoredFiltered = scored
        .where((entry) => entry.value >= threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scoredFiltered.map((e) => e.key).toList();
  }
}
