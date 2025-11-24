class Filter<T> {
  String name;
  List<T> Function(List<T> filtered) onTransform;

  Filter({required this.name, required this.onTransform});
}
