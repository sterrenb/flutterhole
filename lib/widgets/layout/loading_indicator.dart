import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, this.size}) : super(key: key);

  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(),
    );
  }
}

class LoadingIndicatorIcon extends StatelessWidget {
  const LoadingIndicatorIcon({
    Key? key,
    this.mouseCursor = SystemMouseCursors.click,
  }) : super(key: key);

  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: null,
      enableFeedback: false,
      mouseCursor: mouseCursor,
      icon: LoadingIndicator(
        size: Theme.of(context).textTheme.subtitle1?.fontSize,
      ),
    );
  }
}

class AnimatedLoadingIndicatorIcon extends StatelessWidget {
  const AnimatedLoadingIndicatorIcon({
    Key? key,
    required this.isLoading,
    this.mouseCursor,
  }) : super(key: key);

  final bool isLoading;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    return AnimatedFader(
        child: isLoading
            ? LoadingIndicatorIcon(mouseCursor: mouseCursor)
            : const Text(''));
  }
}

class AnimatedErrorIndicatorIcon extends StatelessWidget {
  const AnimatedErrorIndicatorIcon({
    Key? key,
    required this.error,
    this.mouseCursor,
    this.title,
  }) : super(key: key);

  final Object? error;
  final MouseCursor? mouseCursor;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return AnimatedFader(
        child: error != null
            ? IconButton(
                tooltip: 'Error',
                iconSize:
                    Theme.of(context).textTheme.subtitle1?.fontSize ?? 24.0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  showModal(
                      context: context,
                      builder: (context) => ErrorDialog(
                            title: title ?? 'Error',
                            error: error!,
                          ));
                },
                icon: Icon(
                  KIcons.error,
                  color: Theme.of(context).colorScheme.error,
                ))
            : const Text(''));
  }
}

class AnimatedLoadingErrorIndicatorIcon extends StatelessWidget {
  const AnimatedLoadingErrorIndicatorIcon({
    Key? key,
    required this.isLoading,
    required this.error,
    this.mouseCursor,
    this.title,
  }) : super(key: key);

  final bool isLoading;
  final Object? error;
  final MouseCursor? mouseCursor;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedLoadingIndicatorIcon(
          isLoading: isLoading,
          mouseCursor: mouseCursor,
        ),
        AnimatedErrorIndicatorIcon(
          error: error,
          title: title,
        ),
      ],
    );
  }
}
