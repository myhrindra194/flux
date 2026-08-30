enum DataSource { remote, cache }

class DataResult<T> {
  final T data;
  final DataSource source;

  const DataResult({required this.data, required this.source});

  bool get isFromCache => source == DataSource.cache;
}
