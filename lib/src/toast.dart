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
  ToastTheme({required this.viewerPadding, required this.gap});

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
    required this.indexToastMap,
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
        final data = signal<List<Toast>>(context, []);
        final indexToastMap = signal<Map<String, int>>(context, {});
        final willDeleteToastIndex = signal<Set<int>>(context, {});
        final onDragToastIndex = signal<Set<int>>(context, {});

        return ToastProvider._(
          data: data,
          indexToastMap: indexToastMap,
          willDeleteToastIndex: willDeleteToastIndex,
          onDragToastIndex: onDragToastIndex,
          child: child,
        );
      },
    );
  }

  /// The list of active toasts in the stack.
  ///
  /// This is a reactive signal that updates when toasts are added or removed.
  final WritableSignal<List<Toast>> data;

  /// Maps toast IDs to their indices in the stack.
  ///
  /// Used internally for tracking toast positions during animations.
  final WritableSignal<Map<String, int>> indexToastMap;

  /// Set of toast indices that are marked for deletion.
  ///
  /// Used internally to track toasts that are animating out.
  final WritableSignal<Set<int>> willDeleteToastIndex;

  /// Set of toast indices that are currently being dragged.
  ///
  /// Used internally to pause auto-dismissal during drag gestures.
  final WritableSignal<Set<int>> onDragToastIndex;

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
    data([...data(), toast]);
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
    final index = data().indexOf(toast);
    if (index == -1) {
      return;
    }

    willDeleteToastIndex({...willDeleteToastIndex(), index});
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
class ToastViewer extends StatefulWidget {
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
  });

  /// Duration before a toast automatically dismisses.
  ///
  /// Auto-dismissal is paused when:
  /// - The user hovers over the toast stack
  /// - The user taps a toast
  /// - The user is dragging a toast
  final Duration delay;

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

  @override
  State<ToastViewer> createState() => _ToastViewerState();
}

class _ToastViewerState extends State<ToastViewer> {
  final isHovered = signal(null, false);
  final paused = signal(null, false);

  Effect? _wipeToastEffect;
  Effect? _periodicDeleteToastEffect;

  Timer? _cleanUpDeleteTimer;
  Timer? _hoverDebounceTimer;
  Timer? _periodicDeleteToastTimer;
  void _setHoverDebounced(bool value, {Duration? delay}) {
    _hoverDebounceTimer?.cancel();
    if (untrack(paused.call)) return;
    _hoverDebounceTimer = Timer(delay ?? const Duration(milliseconds: 200), () {
      if (!untrack(paused.call)) isHovered(value);
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
                onEnter: (event) => _setHoverDebounced(true),
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
                                paused(!paused());
                              }
                            },
                            onVerticalDragStart: (details) {
                              manualDragPosition(0.0);
                              globalPosition(details.globalPosition);
                              onDrag(true);
                              toastProvider.onDragToastIndex({
                                ...toastProvider.onDragToastIndex(),
                                index,
                              });
                            },
                            onVerticalDragCancel: () {
                              manualDragPosition(0.0);
                              globalPosition(Offset.zero);
                              onDrag(false);
                              toastProvider.onDragToastIndex(
                                {...toastProvider.onDragToastIndex()}
                                  ..remove(index),
                              );
                            },
                            onVerticalDragEnd: (details) {
                              globalPosition(Offset.zero);
                              onDrag(false);
                              toastProvider.onDragToastIndex(
                                {...toastProvider.onDragToastIndex()}
                                  ..remove(index),
                              );

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
      final dragged = toastProvider.onDragToastIndex().isNotEmpty;
      final paused = this.paused();
      if (dragged || paused) return;

      _periodicDeleteToastTimer = Timer(widget.delay, () {
        final dataValue = untrack(toastProvider.data.call);
        final willDeleteToastIndex = untrack(
          toastProvider.willDeleteToastIndex.call,
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

    final allToasts = watch(context, toastProvider.data.call);
    
    // Filter toasts based on categories if specified
    // Also create a map from filtered index to master index
    final List<Toast> toasts;
    final Map<int, int> filteredToMasterIndex;
    
    if (widget.categories == null || widget.categories!.isEmpty) {
      toasts = allToasts;
      // Identity mapping: filtered index = master index
      filteredToMasterIndex = Map.fromIterable(
        List.generate(allToasts.length, (i) => i),
        key: (i) => i,
        value: (i) => i,
      );
    } else {
      toasts = [];
      filteredToMasterIndex = {};
      for (var masterIndex = 0; masterIndex < allToasts.length; masterIndex++) {
        final toast = allToasts[masterIndex];
        if (widget.categories!.contains(toast.category)) {
          filteredToMasterIndex[toasts.length] = masterIndex;
          toasts.add(toast);
        }
      }
    }
    
    int calculatePositionedIndex(int filteredIndex) {
      final masterIndex = filteredToMasterIndex[filteredIndex]!;
      final deletedIndexes = toastProvider.willDeleteToastIndex();
      final deletedGreaterThanMasterIndex =
          deletedIndexes.where((index) => index > masterIndex).length;
      return toasts.length - filteredIndex - deletedGreaterThanMasterIndex - 1;
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
                for (final (filteredIndex, toast) in toasts.indexed)
                  SignalBuilder(
                    builder: (context) {
                      final masterIndex = filteredToMasterIndex[filteredIndex]!;
                      final positionedIndex = calculatePositionedIndex(filteredIndex);
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
                            toast.id: masterIndex,
                          });
                        }
                      });

                      final isMarkDeleted = toastProvider
                          .willDeleteToastIndex()
                          .contains(masterIndex);
                      final isFirstAppear = indexToast() == -1;
                      final hovered = isHovered() || paused();
                      final gap = toastTheme.gap;

                      double calculateHeight() {
                        double height = 0;
                        List<Toast> visualToasts = [];
                        for (var i = toasts.length - 1; i >= 0; i--) {
                          final masterIndexForI = filteredToMasterIndex[i]!;
                          if (toastProvider //
                              .willDeleteToastIndex()
                              .contains(masterIndexForI)) {
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
                        masterIndex,
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
