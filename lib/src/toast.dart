import 'dart:async' show Timer;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:motor/motor.dart';
import 'package:oref/oref.dart';

part 'utils.dart';

/// A category for grouping and filtering toasts.
///
/// Categories allow you to organize toasts and display them in different
/// [ToastViewer] widgets based on their type. For example, you might want
/// error toasts in one location and success toasts in another.
///
/// Example:
/// ```dart
/// Toast(
///   category: ToastCategory.error,
///   builder: (toast) => ErrorToast(...),
/// ).show(context);
/// ```
class ToastCategory {
  /// Creates a custom toast category.
  ///
  /// [name] is the identifier for this category.
  const ToastCategory(this.name);

  /// General purpose toasts. This is the default category.
  static const general = ToastCategory('general');

  /// Success notification toasts.
  static const success = ToastCategory('success');

  /// Warning notification toasts.
  static const warning = ToastCategory('warning');

  /// Error notification toasts.
  static const error = ToastCategory('error');

  /// The identifier for this category.
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastCategory &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ToastCategory($name)';
}

/// A toast instance that can be shown or hidden.
///
/// Toasts are headless widgets - you provide the UI via the [builder] function.
/// The toast system handles animation, positioning, and lifecycle management.
///
/// Example:
/// ```dart
/// Toast(
///   height: 64,
///   category: ToastCategory.success,
///   builder: (toast) => Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Hello, World!'),
///   ),
/// ).show(context);
/// ```
class Toast {
  Toast._({
    required this.id,
    required this.builder,
    this.height = 64,
    this.category = ToastCategory.general,
  });

  /// Creates a new toast instance.
  ///
  /// [builder] is called to build the toast widget. The [Toast] instance is
  /// passed to the builder so you can call [hide] from within the widget.
  ///
  /// [height] specifies the height of the toast in logical pixels. This is used
  /// for layout calculations and animations. Defaults to 64.
  ///
  /// [category] specifies the category of this toast. Used for filtering toasts
  /// in [ToastViewer]. Defaults to [ToastCategory.general].
  factory Toast({
    required Widget Function(Toast data) builder,
    double height = 64,
    ToastCategory category = ToastCategory.general,
  }) {
    final id = UniqueKey();
    return Toast._(
      id: '${id.hashCode}',
      builder: builder,
      height: height,
      category: category,
    );
  }

  /// Unique identifier for this toast instance.
  final String id;

  /// Height of the toast in logical pixels.
  ///
  /// Used for layout calculations and animations. Should match the actual
  /// height of the widget returned by [builder].
  final double height;

  /// Category of this toast.
  ///
  /// Used by [ToastViewer] to filter which toasts to display.
  /// Defaults to [ToastCategory.general].
  final ToastCategory category;

  /// Builder function that creates the toast widget.
  ///
  /// The [Toast] instance is passed as a parameter, allowing you to call
  /// [hide] from within the widget (e.g., in a close button).
  final Widget Function(Toast data) builder;

  /// Hides this toast with animation.
  ///
  /// The toast will be removed from the stack after the hide animation completes.
  void hide(BuildContext context) => ToastProvider.of(context).hide(this);

  /// Shows this toast in the nearest [ToastViewer].
  ///
  /// The toast will appear with an entrance animation and be added to the
  /// toast stack managed by [ToastProvider].
  void show(BuildContext context) => ToastProvider.of(context).show(this);
}

/// Theme configuration for toast viewers.
///
/// Controls the spacing and padding of toast stacks. This theme can be
/// provided via [ToastThemeProvider] or accessed through `Theme.of(context)`.
///
/// Example:
/// ```dart
/// ToastTheme(
///   viewerPadding: EdgeInsets.all(16),
///   gap: 12,
/// )
/// ```
class ToastTheme extends ThemeExtension<ToastTheme> {
  /// Creates a new toast theme.
  ///
  /// [viewerPadding] is the padding around the entire toast stack.
  /// [gap] is the spacing between individual toasts in the stack.
  const ToastTheme({required this.viewerPadding, required this.gap});

  /// efault toast theme.
  static const kDefault = ToastTheme(viewerPadding: EdgeInsets.all(12), gap: 8);

  /// Padding around the toast viewer container.
  ///
  /// This creates space between the toasts and the edges of the screen
  /// or parent widget.
  final EdgeInsets viewerPadding;

  /// Gap between individual toasts in the stack.
  ///
  /// When toasts are collapsed (not hovered), only this gap is visible
  /// between toasts. When expanded (hovered), the full toast height plus
  /// this gap is used.
  final double gap;

  /// Creates a copy of this theme with the given fields replaced.
  ///
  /// If a parameter is null, the corresponding value from this theme is used.
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

  /// Linearly interpolates between two themes.
  ///
  /// Used by Flutter's theme system to animate between theme changes.
  /// [t] is the interpolation factor, typically between 0.0 and 1.0.
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

/// Provides [ToastTheme] to descendant widgets via the theme system.
///
/// Wrap your app or a subtree with this widget to configure toast spacing
/// and padding. If [data] is null, default values are used.
///
/// Example:
/// ```dart
/// ToastThemeProvider(
///   data: ToastTheme(
///     viewerPadding: EdgeInsets.all(16),
///     gap: 12,
///   ),
///   child: MyApp(),
/// )
/// ```
class ToastThemeProvider extends StatelessWidget {
  /// Creates a theme provider for toasts.
  ///
  /// [data] is the theme configuration. If null, defaults to
  /// `ToastTheme(viewerPadding: EdgeInsets.all(12), gap: 8)`.
  ///
  /// [child] is the widget subtree that will have access to this theme.
  const ToastThemeProvider({super.key, this.data, required this.child});

  /// The toast theme configuration.
  ///
  /// If null, default values are used.
  final ToastTheme? data;

  /// The widget subtree that will have access to this theme.
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

/// Provides toast management functionality to descendant widgets.
///
/// This widget manages the toast stack and provides methods to show and hide
/// toasts. Use [create] to wrap your app root, and [of] to access the provider
/// from descendant widgets.
///
/// Example:
/// ```dart
/// void main() {
///   runApp(
///     ToastProvider.create(
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
class ToastProvider extends InheritedWidget {
  const ToastProvider._({
    required this.data,
    required this.willDeleteToastIndex,
    required this.onDragToastIndex,
    required super.child,
  });

  /// Returns the nearest [ToastProvider] ancestor.
  ///
  /// Throws if no [ToastProvider] is found in the widget tree.
  ///
  /// Example:
  /// ```dart
  /// final provider = ToastProvider.of(context);
  /// provider.show(myToast);
  /// ```
  static ToastProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToastProvider>()!;

  /// Creates a [ToastProvider] widget.
  ///
  /// Wrap your app root with this to enable toast functionality throughout
  /// your app. Only one [ToastProvider] is needed per app.
  ///
  /// Example:
  /// ```dart
  /// ToastProvider.create(
  ///   child: MaterialApp(...),
  /// )
  /// ```
  static Widget create({required Widget child}) {
    return Builder(
      builder: (context) {
        final data = ReactiveList<Toast>.scoped(context, const []);
        final willDeleteToastIndex = ReactiveSet<int>.scoped(
          context,
          const <int>{},
        );
        final onDragToastIndex = ReactiveSet<int>.scoped(
          context,
          const <int>{},
        );

        return ToastProvider._(
          data: data,
          willDeleteToastIndex: willDeleteToastIndex,
          onDragToastIndex: onDragToastIndex,
          child: child,
        );
      },
    );
  }

  /// The list of active toasts in the stack.
  ///
  /// This is a reactive list that updates when toasts are added or removed.
  @visibleForTesting
  final ReactiveList<Toast> data;

  /// Set of toast indices that are marked for deletion.
  ///
  /// Used internally to track toasts that are animating out.
  @visibleForTesting
  final ReactiveSet<int> willDeleteToastIndex;

  /// Set of toast indices that are currently being dragged.
  ///
  /// Used internally to pause auto-dismissal during drag gestures.
  @visibleForTesting
  final ReactiveSet<int> onDragToastIndex;

  /// Adds a toast to the stack.
  ///
  /// The toast will appear in all [ToastViewer] widgets that are configured
  /// to display it.
  ///
  /// Example:
  /// ```dart
  /// final toast = Toast(builder: (t) => Text('Hello'));
  /// ToastProvider.of(context).show(toast);
  /// ```
  void show(Toast toast) {
    data.add(toast);
  }

  /// Removes a toast from the stack with animation.
  ///
  /// The toast will animate out and be removed after the animation completes.
  ///
  /// Example:
  /// ```dart
  /// ToastProvider.of(context).hide(toast);
  /// ```
  void hide(Toast toast) {
    final index = data.indexOf(toast);
    if (index == -1) {
      return;
    }
    willDeleteToastIndex.add(index);
  }

  @override
  bool updateShouldNotify(covariant ToastProvider oldWidget) => false;
}

/// A widget that displays a stack of toasts with animations and gestures.
///
/// Place this widget in your widget tree to render toasts. You can have
/// multiple [ToastViewer] widgets with different alignments to show toasts
/// in different positions.
///
/// [categories] allows filtering which toasts are displayed. If null or empty,
/// all toasts are shown. If provided, only toasts matching one of the specified
/// categories will be displayed.
///
/// Example:
/// ```dart
/// // Show all toasts
/// ToastViewer(
///   alignment: Alignment.topRight,
///   delay: Duration(seconds: 3),
///   visibleCount: 3,
/// )
///
/// // Show only error and warning toasts
/// ToastViewer(
///   alignment: Alignment.bottomLeft,
///   categories: [ToastCategory.error, ToastCategory.warning],
/// )
/// ```
class ToastViewer extends StatelessWidget {
  /// Creates a toast viewer widget.
  ///
  /// [alignment] determines where on the screen the toasts appear.
  /// Defaults to [Alignment.topRight].
  ///
  /// [delay] is the duration before a toast automatically dismisses.
  /// Defaults to 2 seconds.
  ///
  /// [visibleCount] is the maximum number of toasts to show when not hovered.
  /// When hovered, all toasts are visible. Defaults to 3.
  ///
  /// [categories] filters which toast categories to display. If null or empty,
  /// all toasts are shown. If provided, only toasts matching one of the
  /// specified categories will be displayed.
  const ToastViewer({
    super.key,
    this.alignment = Alignment.topRight,
    this.delay = const Duration(milliseconds: 2000),
    this.visibleCount = 3,
    this.categories,
    this.width,
    this.thresholdFullWidth,
  });

  /// Duration before a toast automatically dismisses.
  ///
  /// Auto-dismissal is paused when:
  /// - The user hovers over the toast stack
  /// - The user taps a toast
  /// - The user is dragging a toast
  /// If null, auto-dismissal is disabled.
  final Duration? delay;

  /// Alignment of the toast stack on the screen.
  ///
  /// Common values:
  /// - [Alignment.topRight] - Top right corner (default)
  /// - [Alignment.topLeft] - Top left corner
  /// - [Alignment.bottomRight] - Bottom right corner
  /// - [Alignment.bottomLeft] - Bottom left corner
  /// - [Alignment.topCenter] - Top center
  /// - [Alignment.bottomCenter] - Bottom center
  final Alignment alignment;

  /// Maximum number of toasts visible when not hovered.
  ///
  /// When the user hovers over the toast stack, all toasts become visible.
  /// When not hovered, only the most recent [visibleCount] toasts are shown.
  /// Older toasts are hidden with opacity animations.
  final int visibleCount;

  /// Categories of toasts to display in this viewer.
  ///
  /// If null or empty, all toasts are shown regardless of category.
  /// If provided, only toasts with a category matching one of the specified
  /// categories will be displayed.
  ///
  /// Example:
  /// ```dart
  /// // Show only error and warning toasts
  /// ToastViewer(
  ///   categories: [ToastCategory.error, ToastCategory.warning],
  /// )
  /// ```
  final List<ToastCategory>? categories;

  /// Width of the toast.
  final double? width;

  /// Threshold for full width.
  final double? thresholdFullWidth;

  @override
  Widget build(BuildContext context) {
    final toastProvider = ToastProvider.of(context);
    final isHovered = signal(context, false);
    final paused = signal(context, false);
    final timers = useMemoized(context, _ToastViewerTimers.new);
    onUnmounted(context, timers.dispose);

    List<int> filterToastIndexes(List<Toast> allToasts) {
      final categories = this.categories;
      if (categories == null || categories.isEmpty) {
        return List<int>.generate(allToasts.length, (i) => i);
      }

      final masterIndexes = <int>[];
      for (var i = 0; i < allToasts.length; i++) {
        if (categories.contains(allToasts[i].category)) masterIndexes.add(i);
      }

      return masterIndexes;
    }

    void setHoverDebounced(bool value, {Duration? delay}) {
      timers.hoverDebounce?.cancel();
      if (untrack(paused.call)) return;
      timers.hoverDebounce = Timer(
        delay ?? const Duration(milliseconds: 200),
        () {
          if (!untrack(paused.call)) isHovered.set(value);
        },
      );
    }

    void resetCleanUpDelete() {
      timers.cleanUpDelete?.cancel();
      timers.cleanUpDelete = null;
    }

    void resetPeriodicDelete() {
      timers.periodicDelete?.cancel();
      timers.periodicDelete = null;
    }

    effect(context, () {
      onEffectCleanup(resetCleanUpDelete);
      onEffectDispose(resetCleanUpDelete);
      final deletedIndexes = toastProvider.willDeleteToastIndex;

      if (deletedIndexes.isNotEmpty &&
          deletedIndexes.length == toastProvider.data.length) {
        resetCleanUpDelete();
        timers.cleanUpDelete = Timer(
          const Duration(milliseconds: 250),
          () => batch(() {
            toastProvider.data.clear();
            toastProvider.willDeleteToastIndex.clear();
          }),
        );
      }
    });
    effect(context, () {
      onEffectCleanup(resetPeriodicDelete);
      onEffectDispose(resetPeriodicDelete);
      toastProvider.willDeleteToastIndex.length;
      toastProvider.data.length;
      if (toastProvider.onDragToastIndex.isNotEmpty || paused()) return;
      if (delay == null) return;

      timers.periodicDelete = Timer(delay!, () {
        final allToasts = untrack(() => toastProvider.data);
        if (allToasts.isEmpty) return;

        final masterIndexes = filterToastIndexes(allToasts);
        if (masterIndexes.isEmpty) return;

        final willDeleteToastIndex = untrack(
          () => toastProvider.willDeleteToastIndex,
        );
        for (final masterIndex in masterIndexes) {
          if (!willDeleteToastIndex.contains(masterIndex)) {
            toastProvider.hide(allToasts[masterIndex]);
            break;
          }
        }
      });
    });

    final toastTheme =
        Theme.of(context).extension<ToastTheme>() ?? ToastTheme.kDefault;
    final isTop = alignment.y < 0;
    final isBottom = alignment.y > 0;
    final isLeft = alignment.x < 0;
    final isRight = alignment.x > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width =
            size.width < (thresholdFullWidth ?? 600)
                ? size.width
                : (this.width ?? 400);
        final toastWidth = width - toastTheme.viewerPadding.horizontal;

        return SignalBuilder(
          builder: (context) {
            final allToasts = toastProvider.data;
            final masterIndexes = filterToastIndexes(allToasts);
            final willDeleteToastIndex = toastProvider.willDeleteToastIndex;
            final hovered = isHovered() || paused();
            final gap = toastTheme.gap;

            final positions = List.filled(masterIndexes.length, (0, 0.0));
            var visualIndex = 0;
            var expandedOffset = 0.0;
            for (var i = masterIndexes.length - 1; i >= 0; i--) {
              final masterIndex = masterIndexes[i];
              positions[i] = (visualIndex, expandedOffset);
              if (!willDeleteToastIndex.contains(masterIndex)) {
                expandedOffset += allToasts[masterIndex].height + gap;
                visualIndex++;
              }
            }

            return Align(
              alignment: alignment,
              child: Padding(
                padding: toastTheme.viewerPadding,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final (filteredIndex, masterIndex)
                        in masterIndexes.indexed)
                      SignalBuilder(
                        key: ValueKey(allToasts[masterIndex].id),
                        builder: (context) {
                          final toast = allToasts[masterIndex];
                          final (positionedIndex, expandedHeight) =
                              positions[filteredIndex];
                          final baseHeight =
                              hovered ? expandedHeight : gap * positionedIndex;
                          final baseScale =
                              hovered ? 1.0 : 1.0 - 0.03 * positionedIndex;
                          final baseOpacity =
                              positionedIndex >= visibleCount ? 0.0 : 1.0;
                          final isMarkDeleted = willDeleteToastIndex.contains(
                            masterIndex,
                          );

                          final firstAppear = signal(context, true);
                          effect(context, () {
                            if (!firstAppear()) return;
                            final timer = Timer(
                              Durations.medium2,
                              () => firstAppear.set(false),
                            );
                            onEffectDispose(timer.cancel);
                          });

                          final manualDragPosition = signal(context, 0.0);

                          void endDrag({
                            DragEndDetails? details,
                            bool reset = false,
                          }) {
                            toastProvider.onDragToastIndex.remove(masterIndex);
                            final v = details?.primaryVelocity;
                            if (v == null) {
                              if (reset) manualDragPosition.set(0.0);
                              return;
                            }
                            if ((alignment.y > 0 && v > 50) ||
                                (alignment.y < 0 && v < 50)) {
                              toastProvider.hide(toast);
                            } else {
                              manualDragPosition.set(0.0);
                            }
                          }

                          final isFirstAppear = firstAppear();
                          final transformY =
                              isFirstAppear
                                  ? -34.0
                                  : isMarkDeleted
                                  ? -(toast.height + gap * 2) + baseHeight
                                  : baseHeight;
                          final scale = isFirstAppear ? 0.97 : baseScale;
                          final opacity =
                              (isMarkDeleted || isFirstAppear)
                                  ? 0.0
                                  : baseOpacity;

                          final dragPosition = manualDragPosition();
                          final dragOpacity =
                              dragPosition * alignment.y.sign > 20 ? 0.0 : 1.0;

                          return ((
                            Offset transform,
                            double scale,
                            double opacity,
                          ) {
                            final clampedOpacity =
                                opacity.clamp(0, 1).toDouble();
                            return Positioned(
                              top: isTop ? transform.dy : null,
                              bottom: isBottom ? transform.dy : null,
                              left: isLeft ? transform.dx : null,
                              right: isRight ? transform.dx : null,
                              width: toastWidth,
                              child: IgnorePointer(
                                ignoring: clampedOpacity == 0,
                                child: RepaintBoundary(
                                  key: ValueKey(toast.id),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: clampedOpacity,
                                      child: MouseRegion(
                                        onEnter: (_) => setHoverDebounced(true),
                                        onExit: (_) => setHoverDebounced(false),
                                        child: ((
                                          double userDragPosition,
                                          double opacity,
                                        ) {
                                          return Transform.translate(
                                            offset: Offset(0, userDragPosition),
                                            child: Opacity(
                                              opacity:
                                                  opacity
                                                      .clamp(0, 1)
                                                      .toDouble(),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (!isHovered()) {
                                                    paused.set(!paused());
                                                  }
                                                },
                                                onVerticalDragStart: (_) {
                                                  manualDragPosition.set(0.0);
                                                  toastProvider.onDragToastIndex
                                                      .add(masterIndex);
                                                },
                                                onVerticalDragUpdate: (
                                                  details,
                                                ) {
                                                  manualDragPosition.set(
                                                    manualDragPosition() +
                                                        details.delta.dy,
                                                  );
                                                },
                                                onVerticalDragCancel:
                                                    () => endDrag(reset: true),
                                                onVerticalDragEnd:
                                                    (details) => endDrag(
                                                      details: details,
                                                    ),
                                                child: SizedBox(
                                                  height: toast.height + gap,
                                                  child: ColoredBox(
                                                    color: Colors.transparent,
                                                    child: Align(
                                                      alignment: alignment,
                                                      child: toast.builder(
                                                        toast,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).motion(
                                          MotionArgument.single(
                                            dragPosition,
                                            toastProvider.onDragToastIndex
                                                    .contains(masterIndex)
                                                ? MotionPresets.instant
                                                : const Motion.snappySpring(),
                                          ),
                                          MotionArgument.single(
                                            dragOpacity,
                                            const Motion.snappySpring(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).motion(
                            MotionArgument.offset(
                              Offset(0.0, transformY),
                              isFirstAppear
                                  ? const CurvedMotion(
                                    Durations.medium1,
                                    Curves.easeOutExpo,
                                  )
                                  : const Motion.snappySpring(
                                    duration: Duration(milliseconds: 500),
                                  ),
                            ),
                            MotionArgument.single(
                              scale,
                              isFirstAppear
                                  ? (const Motion.snappySpring()).segment(
                                    length: 0.1,
                                  )
                                  : const Motion.snappySpring(
                                    duration: Duration(milliseconds: 500),
                                  ),
                            ),
                            MotionArgument.single(
                              opacity,
                              isFirstAppear
                                  ? const Motion.linear(Durations.medium1)
                                  : const Motion.snappySpring(),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ToastViewerTimers {
  Timer? cleanUpDelete;
  Timer? hoverDebounce;
  Timer? periodicDelete;

  void dispose() {
    cleanUpDelete?.cancel();
    hoverDebounce?.cancel();
    periodicDelete?.cancel();
  }
}
