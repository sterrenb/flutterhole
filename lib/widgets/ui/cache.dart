import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO add stacktrace
typedef CacheBuilderCallback<T> = Widget Function(
  BuildContext context,
  T? cache,
  bool isLoading,
  Object? error,
);

/// Provides a cached version of the [provider]'s value.
class CacheBuilder<T> extends HookConsumerWidget {
  const CacheBuilder({
    Key? key,
    required this.provider,
    required this.builder,
  }) : super(key: key);

  final AutoDisposeProvider<AsyncValue<T>> provider;
  final CacheBuilderCallback<T> builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final cache = useValueChanged<AsyncValue, T?>(
      data,
      (_, T? oldResult) {
        final newResult = data.whenOrNull(data: (update) => update);
        return newResult ?? oldResult;
      },
    );

    return builder(
      context,
      cache,
      data.maybeWhen(
        loading: () => true,
        orElse: () => false,
      ),
      data.whenOrNull(error: (e, s) => e),
    );
  }
}
