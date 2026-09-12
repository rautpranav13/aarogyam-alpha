/// Extension helpers for collections.
library core_extensions;

extension FFListNullsExtension<T> on Iterable<T?> {
  List<T> get withoutNulls =>
      where((e) => e != null).cast<T>().toList();
}

extension FFMapNullsExtension<K, V> on Map<K, V?> {
  Map<K, V> get withoutNulls => Map.fromEntries(
      entries
          .where((e) => e.value != null)
          .map((e) => MapEntry(e.key, e.value as V)));
}
