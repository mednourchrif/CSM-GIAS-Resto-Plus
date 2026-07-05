import 'package:mobile_app/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    }
    return failure((this as Fail<T>).failure);
  }

  R map<R>({
    required R Function(Success<T> success) success,
    required R Function(Fail<T> failure) failure,
  }) {
    if (this is Success<T>) {
      return success(this as Success<T>);
    }
    return failure(this as Fail<T>);
  }
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

final class Fail<T> extends Result<T> {
  final Failure failure;

  const Fail(this.failure);
}
