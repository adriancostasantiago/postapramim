import 'package:postapramim/core/error/failures.dart';

/// Result Pattern: encapsula sucesso (Right/Success) ou falha (Left/Failure).
/// Usado em todo o retorno de UseCases e Repositories.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.data);
    if (self is ResultFailure<T>) return onFailure(self.failure);
    throw StateError('Result inválido');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
