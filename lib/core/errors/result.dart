import 'failures.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  final bool isFromCache;

  const Success(this.data, {this.isFromCache = false});
}

class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);
}
