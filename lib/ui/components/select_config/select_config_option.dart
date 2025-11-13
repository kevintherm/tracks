class SelectConfigOption {
  final String id;
  final String label;
  final String? imagePath;
  final String? subtitle;

  const SelectConfigOption({
    required this.id,
    required this.label,
    this.imagePath,
    this.subtitle,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectConfigOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
