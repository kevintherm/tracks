/// Base exercise option model
/// Can be used across different contexts (workout creation, schedule assignment, etc.)
class ExerciseOption {
  final String id;
  final String label;
  final String? imagePath;
  final String? subtitle;

  const ExerciseOption({
    required this.id,
    required this.label,
    this.imagePath,
    this.subtitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
