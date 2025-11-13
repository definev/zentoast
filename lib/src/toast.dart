import 'dart:async' show Timer;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';
import 'package:oref/oref.dart';

part 'utils.dart';

class Toast {
  Toast._({required this.id, required this.builder, this.height = 64});

  factory Toast({
    required Widget Function(Toast data) builder,
    double height = 64,
  }) {
    final id = UniqueKey();
    return Toast._(id: '${id.hashCode}', builder: builder, height: height);
  }

  final String id;
  final double height;
  final Widget Function(Toast data) builder;

  void hide(BuildContext context) => ToastProvider.of(context).hide(this);
  void show(BuildContext context) => ToastProvider.of(context).show(this);
}

class ToastTheme extends ThemeExtension<ToastTheme> {
  ToastTheme({required this.viewerPadding, required this.gap});

  final EdgeInsets viewerPadding;
  final double gap;

  @override
  ThemeExtension<ToastTheme> copyWith({
    EdgeInsets? viewerPadding,
    double? gap,
  }) {
    return ToastTheme(
      viewerPadding: viewerPadding ?? this.viewerPadding,
      gap: gap ?? this.gap,
    );
  }

  @override
  ThemeExtension<ToastTheme> lerp(covariant ToastTheme? other, double t) {
    return ToastTheme(
      viewerPadding:
          EdgeInsets.lerp(viewerPadding, other?.viewerPadding, t) ??
          viewerPadding,
      gap: lerpDouble(gap, other?.gap, t) ?? gap,
    );
  }
}

class ToastThemeProvider extends StatelessWidget {
  const ToastThemeProvider({super.key, this.data, required this.child});

  final ToastTheme? data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data =
        this.data ?? ToastTheme(viewerPadding: EdgeInsets.all(12), gap: 8);
    return Theme(
      data: theme.copyWith(
        extensions: {
          ...theme.extensions.values.where(
            (extension) => extension is! ToastTheme,
          ),
          data,
        },
      ),
      child: child,
    );
  }
}

class ToastProvider extends InheritedWidget {
  const ToastProvider._({
    required this.data,
    required this.indexToastMap,
    required this.willDeleteToastIndex,
    required super.child,
  });

  static ToastProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToastProvider>()!;

  static Widget create({required Widget child}) {
    return Builder(
      builder: (context) {
        final data = signal<List<Toast>>(context, []);
        final indexToastMap = signal<Map<String, int>>(context, {});
        final willDeleteToastIndex = signal<Set<int>>(context, {});

        return ToastProvider._(
          data: data,
          indexToastMap: indexToastMap,
          willDeleteToastIndex: willDeleteToastIndex,
          child: child,
        );
      },
    );
  }

  final WritableSignal<List<Toast>> data;
  final WritableSignal<Map<String, int>> indexToastMap;
  final WritableSignal<Set<int>> willDeleteToastIndex;

  void show(Toast toast) {
    data([...data(), toast]);
  }

  void hide(Toast toast) {
    final index = data().indexOf(toast);
    if (index == -1) {
      return;
    }

    willDeleteToastIndex({...willDeleteToastIndex(), index});
  }

  @override
  bool updateShouldNotify(covariant ToastProvider oldWidget) => false;
}

class ToastViewer extends StatefulWidget {
  const ToastViewer({
    super.key,
    this.alignment = Alignment.topRight,
    this.delay = const Duration(milliseconds: 2000),
    this.visibleCount = 3,
  });

  final Duration delay;
  final Alignment alignment;
  final int visibleCount;

  @override
  State<ToastViewer> createState() => _ToastViewerState();
}

class _ToastViewerState extends State<ToastViewer> {
  final isHovered = signal(null, false);
  final forceHover = signal(null, false);
  final hasItemDragged = signal(null, false);

  Effect? _wipeToastEffect;
  Effect? _periodicDeleteToastEffect;

  Timer? _cleanUpDeleteTimer;
  Timer? _hoverDebounceTimer;
  Timer? _periodicDeleteToastTimer;
  void _setHoverDebounced(bool value, {Duration? delay}) {
    _hoverDebounceTimer?.cancel();
    _hoverDebounceTimer = Timer(delay ?? const Duration(milliseconds: 200), () {
      if (!untrack(forceHover)) isHovered(value);
    });
  }

  MotionFunction3Builder<Offset, double, double> _buildToastCard(
    BuildContext context,
    Toast toast,
    int index,
    double width,
  ) {
    final toastTheme = Theme.of(context).extension<ToastTheme>()!;

    return (Offset transform, double scale, double opacity) => Positioned(
      bottom: switch (widget.alignment) {
        Alignment.bottomLeft || Alignment.bottomRight => transform.dy,
        _ => null,
      },
      left: switch (widget.alignment) {
        Alignment.bottomLeft || Alignment.topLeft => transform.dx,
        _ => null,
      },
      top: switch (widget.alignment) {
        Alignment.topLeft || Alignment.topRight => transform.dy,
        _ => null,
      },
      right: switch (widget.alignment) {
        Alignment.bottomRight || Alignment.topRight => transform.dx,
        _ => null,
      },
      width: width - toastTheme.viewerPadding.horizontal,
      child: IgnorePointer(
        ignoring: opacity.clamp(0, 1) == 0,
        child: RepaintBoundary(
          key: ValueKey(toast.id),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity.clamp(0, 1),
              child: MouseRegion(
                onEnter: (event) => isHovered(true),
                onExit: (event) => _setHoverDebounced(false),
                child: Builder(
                  builder: (context) {
                    final toastProvider = ToastProvider.of(context);

                    final globalPosition = signal(context, Offset.zero);
                    final manualDragPosition = signal(context, 0.0);
                    final onDrag = signal(context, false);

                    return (double userDragPosition, double opacity) {
                      return Transform.translate(
                        offset: Offset(0, userDragPosition),
                        child: Opacity(
                          opacity: opacity.clamp(0, 1),
                          child: GestureDetector(
                            onTap: () {
                              if (isHovered() == false) {
                                forceHover(!forceHover());
                              }
                            },
                            onVerticalDragStart: (details) {
                              manualDragPosition(0.0);
                              globalPosition(details.globalPosition);
                              onDrag(true);
                            },
                            onVerticalDragCancel: () {
                              manualDragPosition(0.0);
                              globalPosition(Offset.zero);
                              onDrag(false);
                            },
                            onVerticalDragEnd: (details) {
                              globalPosition(Offset.zero);
                              onDrag(false);

                              if (details.primaryVelocity case final v?) {
                                if ((widget.alignment.y > 0 && v > 50) ||
                                    (widget.alignment.y < 0 && v < 50)) {
                                  toastProvider.hide(toast);
                                } else {
                                  manualDragPosition(0.0);
                                }
                              }
                            },
                            onVerticalDragUpdate: (details) {
                              final delta =
                                  details.globalPosition - globalPosition();
                              manualDragPosition(delta.dy);
                            },
                            child: SizedBox(
                              height: toast.height + toastTheme.gap,
                              child: ColoredBox(
                                color: Colors.transparent,
                                child: Align(
                                  alignment: widget.alignment,
                                  child: toast.builder(toast),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }.motion(
                      MotionArgument.single(
                        manualDragPosition(),
                        switch (onDrag()) {
                          false => const Motion.snappySpring(),
                          true => MotionPresets.instant,
                        },
                      ),
                      MotionArgument.single(switch (manualDragPosition()) {
                        > 20 when widget.alignment.y > 0 => 0.0,
                        < -20 when widget.alignment.y < 0 => 0.0,
                        _ => 1.0,
                      }, const Motion.snappySpring()),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _wipeToastEffect?.dispose();
    _periodicDeleteToastEffect?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toastProvider = ToastProvider.of(context);

    _wipeToastEffect ??= effect(context, () {
      onEffectCleanup(() => _cleanUpDeleteTimer?.cancel());
      onEffectDispose(() => _cleanUpDeleteTimer?.cancel());
      final deletedIndexes = toastProvider.willDeleteToastIndex();
      final toasts = toastProvider.data();

      if (deletedIndexes.length == toasts.length && deletedIndexes.isNotEmpty) {
        _cleanUpDeleteTimer?.cancel();
        _cleanUpDeleteTimer = null;
        _cleanUpDeleteTimer = Timer(
          const Duration(milliseconds: 250),
          () => batch(() {
            toastProvider.data([]);
            toastProvider.willDeleteToastIndex({});
          }),
        );
      }
    });
    _periodicDeleteToastEffect ??= effect(context, () {
      onEffectCleanup(() => _periodicDeleteToastTimer?.cancel());
      onEffectDispose(() => _periodicDeleteToastTimer?.cancel());

      /// Retrigger effect when willDeleteToastIndex changes
      final _ = toastProvider.willDeleteToastIndex();
      final _ = toastProvider.data();
      final dragged = hasItemDragged();
      final paused = forceHover();
      if (dragged || paused) return;

      _periodicDeleteToastTimer = Timer(widget.delay, () {
        final dataValue = untrack(toastProvider.data);
        final willDeleteToastIndex = untrack(
          toastProvider.willDeleteToastIndex,
        );
        if (dataValue.isEmpty) return;

        var index = 0;
        while (willDeleteToastIndex.contains(index) &&
            index < dataValue.length) {
          index++;
        }
        if (index < dataValue.length) {
          toastProvider.hide(dataValue[index]);
        }
      });
    });

    final theme = Theme.of(context);
    final toastTheme = theme.extension<ToastTheme>()!;

    final toasts = watch(context, toastProvider.data);
    int calculatePositionedIndex(int realIndex) {
      final deletedIndexes = toastProvider.willDeleteToastIndex();
      final deletedGreaterThanRealIndex =
          deletedIndexes.where((index) => index > realIndex).length;
      return toasts.length - realIndex - deletedGreaterThanRealIndex - 1;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        final width = size.width < 600.0 ? size.width : 400.0;

        return Align(
          alignment: widget.alignment,
          child: Padding(
            padding: toastTheme.viewerPadding,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final (index, toast) in toasts.indexed)
                  SignalBuilder(
                    builder: (context) {
                      final positionedIndex = calculatePositionedIndex(index);
                      final indexToast = writableComputed<int>(
                        context,
                        get:
                            (old) =>
                                toastProvider.indexToastMap()[toast.id] ?? -1,
                        set:
                            (value) => toastProvider.indexToastMap({
                              ...toastProvider.indexToastMap(),
                              toast.id: value,
                            }),
                      );
                      effect(context, () async {
                        if (indexToast() == -1) {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          toastProvider.indexToastMap({
                            ...toastProvider.indexToastMap(),
                            toast.id: index,
                          });
                        }
                      });

                      final isMarkDeleted = toastProvider
                          .willDeleteToastIndex()
                          .contains(index);
                      final isFirstAppear = indexToast() == -1;
                      final hovered = isHovered() || forceHover();
                      final gap = toastTheme.gap;

                      double calculateHeight() {
                        double height = 0;
                        List<Toast> visualToasts = [];
                        for (var i = toasts.length - 1; i >= 0; i--) {
                          if (toastProvider //
                              .willDeleteToastIndex()
                              .contains(i)) {
                            continue;
                          }
                          visualToasts.add(toasts[i]);
                        }

                        for (var i = 0; i < positionedIndex; i++) {
                          height +=
                              hovered ? (visualToasts[i].height) + gap : gap;
                        }
                        return height;
                      }

                      final transformY = switch (hovered) {
                        _ when isFirstAppear => -34.0,
                        _ when isMarkDeleted =>
                          -(toast.height + toastTheme.gap * 2) +
                              calculateHeight(),
                        _ => calculateHeight(),
                      };

                      final scale = switch (hovered) {
                        _ when isFirstAppear => 0.97,
                        true => 1.0,
                        false => 1.0 - 0.03 * positionedIndex,
                      };
                      final opacity = switch (hovered) {
                        _ when isMarkDeleted => 0.0,
                        _ when isFirstAppear => 0.0,
                        _ when positionedIndex >= widget.visibleCount => 0.0,
                        true => 1.0,
                        false => 1.0,
                      };

                      return _buildToastCard(
                        context,
                        toast,
                        index,
                        width,
                      ).motion(
                        MotionArgument.offset(
                          Offset(0.0, transformY),
                          switch (isFirstAppear) {
                            true => const CurvedMotion(
                              Durations.medium1,
                              Curves.easeOutExpo,
                            ),
                            false => const Motion.snappySpring(
                              duration: Duration(milliseconds: 500),
                            ),
                          },
                        ),
                        MotionArgument.single(scale, switch (isFirstAppear) {
                          true => (const Motion.snappySpring()).segment(
                            length: 0.1,
                          ),
                          false => const Motion.snappySpring(
                            duration: Duration(milliseconds: 500),
                          ),
                        }),
                        MotionArgument.single(opacity, switch (isFirstAppear) {
                          true => (const Motion.linear(Durations.medium1)),
                          false => const Motion.snappySpring(),
                        }),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
