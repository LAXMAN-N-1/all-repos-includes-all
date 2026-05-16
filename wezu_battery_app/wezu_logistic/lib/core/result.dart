import 'package:flutter/material.dart';

/// Result type for operations that can succeed or fail.
/// Forces callers to handle both cases explicitly.
///
/// Usage:
/// ```dart
/// final result = await authRepo.login(email, password);
/// result.when(
///   success: (user) => navigateToDashboard(),
///   failure: (error) => showError(error),
/// );
/// ```
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message, {String? code}) = Failure<T>;

  /// Pattern match on the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) failure,
  });

  /// Returns the data if success, or null if failure.
  T? get dataOrNull;

  /// Returns the error message if failure, or null if success.
  String? get error;

  /// Returns true if the result is a success.
  bool get isSuccess;

  /// Returns true if the result is a failure.
  bool get isFailure;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) failure,
  }) => success(data);

  @override
  T? get dataOrNull => data;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  String? get error => null;
}

class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  const Failure(this.message, {this.code});

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code) failure,
  }) => failure(message, code);

  @override
  T? get dataOrNull => null;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  String? get error => message;
}

/// Represents the various states of an async operation in the UI.
///
/// Usage:
/// ```dart
/// final state = ref.watch(inventoryProvider);
/// state.when(
///   initial: () => SizedBox.shrink(),
///   loading: () => AppLoader(),
///   loaded: (data) => InventoryList(data),
///   error: (msg) => ErrorWidget(msg),
/// );
/// ```
@immutable
sealed class AsyncState<T> {
  const AsyncState();

  factory AsyncState.initial() = AsyncInitial<T>;
  factory AsyncState.loading() = AsyncLoading<T>;
  factory AsyncState.loaded(T data) = AsyncLoaded<T>;
  factory AsyncState.error(String message) = AsyncError<T>;

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) loaded,
    required R Function(String message) error,
  });

  bool get isLoading;

  T? get dataOrNull => null;
}

class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) loaded,
    required R Function(String message) error,
  }) => initial();

  @override
  bool get isLoading => false;
}

class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) loaded,
    required R Function(String message) error,
  }) => loading();

  @override
  bool get isLoading => true;
}

class AsyncLoaded<T> extends AsyncState<T> {
  final T data;
  const AsyncLoaded(this.data);

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) loaded,
    required R Function(String message) error,
  }) => loaded(data);

  @override
  bool get isLoading => false;

  @override
  T? get dataOrNull => data;
}

class AsyncError<T> extends AsyncState<T> {
  final String message;
  const AsyncError(this.message);

  @override
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) loaded,
    required R Function(String message) error,
  }) => error(message);

  @override
  bool get isLoading => false;
}
