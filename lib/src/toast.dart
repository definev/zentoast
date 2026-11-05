import 'dart:async' show Timer;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/physics.dart';
import 'package:alien_signals/alien_signals.dart';

part 'utils.dart';
part 'motion.dart';
part 'lifecycle.dart';
part 'store.dart';

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
extension type const ToastCategory(String name) {
  /// General purpose toasts. This is the default category.
  static const general = ToastCategory('general');

  /// Success notification toasts.
  static const success = ToastCategory('success');

  /// Warning notification toasts.
  static const warning = ToastCategory('warning');

  /// Error notification toasts.
  static const error = ToastCategory('error');
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
/// provided via [ToastThemeProvider] and accessed through [ToastThemeProvider.of].
///
/// Example:
/// ```dart
/// ToastTheme(
///   viewerPadding: EdgeInsets.all(16),
///   gap: 12,
/// )
/// ```
@immutable
class ToastTheme {
  /// Creates a new toast theme.
  ///
  /// [viewerPadding] is the padding around the entire toast stack.
  /// [gap] is the spacing between individual toasts in the stack.
  const ToastTheme({
    required this.viewerPadding,
    required this.gap,
    this.motion = const ToastMotionConfig(),
  });

  /// Default toast theme.
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

  /// Motion defaults shared by toast viewers in this theme.
  final ToastMotionConfig motion;

  /// Creates a copy of this theme with the given fields replaced.
  ///
  /// If a parameter is null, the corresponding value from this theme is used.
  ToastTheme copyWith({
    EdgeInsets? viewerPadding,
    double? gap,
    ToastMotionConfig? motion,
  }) {
    return ToastTheme(
      viewerPadding: viewerPadding ?? this.viewerPadding,
      gap: gap ?? this.gap,
      motion: motion ?? this.motion,
    );
  }

  /// Linearly interpolates between two themes.
  ///
  /// Spacing is interpolated linearly; motion switches at the midpoint.
  /// [t] is the interpolation factor, typically between 0.0 and 1.0.
  ToastTheme lerp(ToastTheme? other, double t) {
    if (other == null) return this;
    return ToastTheme(
      viewerPadding: EdgeInsets.lerp(viewerPadding, other.viewerPadding, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      motion: t < 0.5 ? motion : other.motion,
    );
  }
}

/// Provides [ToastTheme] to descendant widgets.
///
/// Wrap your app or a subtree with this widget to configure toast spacing
/// and padding without requiring a Material app or theme.
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
class ToastThemeProvider extends InheritedWidget {
  /// Creates a theme provider for toasts.
  ///
  /// [data] is the theme configuration. Defaults to [ToastTheme.kDefault].
  ///
  /// [child] is the widget subtree that will have access to this theme.
  const ToastThemeProvider({
    super.key,
    this.data = ToastTheme.kDefault,
    required super.child,
  });

  /// Returns the nearest toast theme, or [ToastTheme.kDefault] if absent.
  ///
  /// The calling widget rebuilds when the provider changes its theme.
  static ToastTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToastThemeProvider>()?.data ??
      ToastTheme.kDefault;

  /// The toast theme configuration.
  final ToastTheme data;

  @override
  bool updateShouldNotify(covariant ToastThemeProvider oldWidget) =>
      data != oldWidget.data;
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
  const ToastProvider._({required _ToastStore store, required super.child})
    : _store = store;

  final _ToastStore _store;
  _ToastLifecycle get _lifecycle => _store.lifecycle;

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
  ///   child: MyApp(),
  /// )
  /// ```
  static Widget create({required Widget child}) =>
      _ToastProviderOwner(child: child);

  /// Read-only snapshot of active toasts, including unfinished exits.
  List<Toast> get data => _store.items();

  /// Whether a toast is waiting for its presentations to finish exiting.
  bool isDismissing(Toast toast) => _store.deleted().contains(toast);

  /// Adds a toast to the stack. Showing an already active instance is a no-op.
  ///
  /// The toast will appear in all [ToastViewer] widgets that are configured
  /// to display it.
  ///
  /// Example:
  /// ```dart
  /// final toast = Toast(builder: (t) => Text('Hello'));
  /// ToastProvider.of(context).show(toast);
  /// ```
  void show(Toast toast) => _store.show(toast);

  /// Removes a toast from the stack with animation.
  ///
  /// The toast will animate out and be removed after the animation completes.
  ///
  /// Example:
  /// ```dart
  /// ToastProvider.of(context).hide(toast);
  /// ```
  void hide(Toast toast) => _store.hide(toast);

  @override
  bool updateShouldNotify(covariant ToastProvider oldWidget) =>
      !identical(_store, oldWidget._store);
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
    this.width,
    this.thresholdFullWidth,
    this.motion,
  });

  /// Duration before a toast automatically dismisses.
  ///
  /// Auto-dismissal is paused when:
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

  /// Overrides [ToastTheme.motion] for this viewer.
  final ToastMotionConfig? motion;

  @override
  State<ToastViewer> createState() => _ToastViewerState();
}

class _ToastViewerState extends State<ToastViewer> {
  final _isHovered = signal(false);
  final _paused = signal(false);
  final _timers = _ToastViewerTimers();
  _SignalListenable? _changes;
  _SignalListenable? _dragChanges;
  late _ToastStore _store;
  Effect? _autoDismiss;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = ToastProvider.of(context)._store;
    if (_autoDismiss == null || !identical(store, _store)) {
      _store = store;
      _changes?.dispose();
      _dragChanges?.dispose();
      _dragChanges = _SignalListenable(() {
        _store.dragged();
      });
      _changes = _SignalListenable(() {
        _store.items();
        _store.deleted();
        _isHovered();
        _paused();
      });
      _restartAutoDismiss();
    }
  }

  @override
  void didUpdateWidget(covariant ToastViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delay != oldWidget.delay ||
        !listEquals(widget.categories, oldWidget.categories)) {
      _restartAutoDismiss();
    }
  }

  List<Toast> _filter(List<Toast> items) {
    final categories = widget.categories;
    return categories == null || categories.isEmpty
        ? items
        : items.where((toast) => categories.contains(toast.category)).toList();
  }

  void _restartAutoDismiss() {
    _autoDismiss?.call();
    _autoDismiss = effect<void Function()?>(() {
      _timers.periodicDelete?.cancel();
      final items = _store.items();
      final deleted = _store.deleted();
      final dragged = _store.dragged();
      final paused = _paused();
      // Preserve the existing timer behavior; hover expansion is independent
      // of tap-to-pause. Changing that interaction is a separate change.
      if (dragged.isNotEmpty || paused || widget.delay == null) return null;
      final candidates = _filter(
        items,
      ).where((toast) => !deleted.contains(toast));
      if (candidates.isEmpty) return null;
      _timers.periodicDelete = Timer(widget.delay!, () {
        final current = _filter(
          _store.items(),
        ).where((toast) => !_store.deleted().contains(toast));
        if (current.isNotEmpty) _store.hide(current.first);
      });
      return () => _timers.periodicDelete?.cancel();
    });
  }

  void _setHoverDebounced(bool value) {
    _timers.hoverDebounce?.cancel();
    if (_paused()) return;
    _timers.hoverDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!_paused()) _isHovered.set(value);
    });
  }

  @override
  void dispose() {
    _autoDismiss?.call();
    _changes?.dispose();
    _dragChanges?.dispose();
    _timers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toastProvider = ToastProvider.of(context);
    final alignment = widget.alignment;
    final visibleCount = widget.visibleCount;
    final toastTheme = ToastThemeProvider.of(context);
    final motionConfig = widget.motion ?? toastTheme.motion;
    final policy = motionConfig.policy == ToastMotionPolicy.system
        ? (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
              ? ToastMotionPolicy.reduced
              : ToastMotionPolicy.full
        : motionConfig.policy;
    final reduced = policy == ToastMotionPolicy.reduced;
    final immediate = policy == ToastMotionPolicy.none;
    final (isTop, isBottom, isLeft, isRight, isCenterX) = (
      alignment.y < 0,
      alignment.y > 0,
      alignment.x < 0,
      alignment.x > 0,
      alignment.x == 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final width = size.width < (widget.thresholdFullWidth ?? 600)
            ? size.width
            : (widget.width ?? 400);
        final toastWidth = width - toastTheme.viewerPadding.horizontal;
        final stackInnerWidth =
            size.width - toastTheme.viewerPadding.horizontal;

        return ListenableBuilder(
          listenable: _changes!,
          builder: (context, _) {
            final allToasts = toastProvider.data;
            final masterIndexes = [
              for (var i = 0; i < allToasts.length; i++)
                if (widget.categories == null ||
                    widget.categories!.isEmpty ||
                    widget.categories!.contains(allToasts[i].category))
                  i,
            ];
            final deleted = _store.deleted();
            final hovered = _isHovered() || _paused();
            final gap = toastTheme.gap;

            final positions = List.filled(masterIndexes.length, (0, 0.0));
            var visualIndex = 0;
            var expandedOffset = 0.0;
            for (var i = masterIndexes.length - 1; i >= 0; i--) {
              final masterIndex = masterIndexes[i];
              positions[i] = (visualIndex, expandedOffset);
              if (!deleted.contains(allToasts[masterIndex])) {
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
                      _ToastPresentation(
                        key: ValueKey(allToasts[masterIndex].id),
                        lifecycle: toastProvider._lifecycle,
                        toast: allToasts[masterIndex],
                        hold: !reduced && !immediate,
                        builder: (context, presentation) {
                          final toast = allToasts[masterIndex];
                          final (positionedIndex, expandedHeight) =
                              positions[filteredIndex];
                          final baseHeight = hovered
                              ? expandedHeight
                              : gap * positionedIndex;
                          final baseScale = hovered
                              ? 1.0
                              : 1.0 - 0.03 * positionedIndex;
                          final baseOpacity = positionedIndex >= visibleCount
                              ? 0.0
                              : 1.0;
                          final isMarkDeleted = deleted.contains(toast);
                          final manualDragPosition = presentation.dragPosition;

                          void endDrag({
                            DragEndDetails? details,
                            bool reset = false,
                          }) {
                            _store.setDragging(toast, presentation, false);
                            final v = details?.primaryVelocity;
                            if (v == null) {
                              if (reset) manualDragPosition.value = 0.0;
                              return;
                            }
                            if ((alignment.y > 0 && v > 50) ||
                                (alignment.y < 0 && v < 50)) {
                              toastProvider.hide(toast);
                            } else {
                              manualDragPosition.value = 0.0;
                            }
                          }

                          final isFirstAppear = presentation.firstAppear;
                          final holding = isFirstAppear && !isMarkDeleted;
                          final transformY = reduced || immediate
                              ? baseHeight
                              : holding
                              ? -34.0
                              : isMarkDeleted
                              ? -(toast.height + gap * 2) + baseHeight
                              : baseHeight;
                          final scale = holding && !reduced && !immediate
                              ? 0.97
                              : (reduced || immediate ? 1.0 : baseScale);
                          final opacity =
                              isMarkDeleted || (holding && !immediate)
                              ? 0.0
                              : baseOpacity;
                          final transition = reduced
                              ? const ToastMotionTransition(
                                  position: ToastMotionSpec.linear(
                                    Duration.zero,
                                  ),
                                  scale: ToastMotionSpec.linear(Duration.zero),
                                  opacity: ToastMotionSpec.curved(
                                    Duration(milliseconds: 150),
                                    Curves.easeOut,
                                  ),
                                )
                              : isMarkDeleted
                              ? motionConfig.exit
                              : presentation.entering
                              ? motionConfig.enter
                              : motionConfig.reposition;
                          // Keep content outside the animation callbacks. Its inherited
                          // and reactive dependencies still rebuild normally.
                          final content = GestureDetector(
                            onTap: () {
                              if (!_isHovered()) _paused.set(!_paused());
                            },
                            onVerticalDragStart: (_) {
                              manualDragPosition.value = 0.0;
                              _store.setDragging(toast, presentation, true);
                            },
                            onVerticalDragUpdate: (details) =>
                                manualDragPosition.value =
                                    manualDragPosition.value + details.delta.dy,
                            onVerticalDragCancel: () => endDrag(reset: true),
                            onVerticalDragEnd: (details) =>
                                endDrag(details: details),
                            child: SizedBox(
                              height: toast.height + gap,
                              child: ColoredBox(
                                color: const Color(0x00000000),
                                child: Align(
                                  alignment: alignment,
                                  child: toast.builder(toast),
                                ),
                              ),
                            ),
                          );
                          final drag = ListenableBuilder(
                            listenable: Listenable.merge([
                              manualDragPosition,
                              _dragChanges!,
                            ]),
                            child: content,
                            builder: (context, content) {
                              final dragPosition = manualDragPosition.value;
                              return _ToastMotionBuilder(
                                arguments: [
                                  _MotionTarget(
                                    dragPosition,
                                    _store.isDragging(toast, presentation) ||
                                            reduced ||
                                            immediate
                                        ? const ToastMotionSpec.linear(
                                            Duration.zero,
                                          )
                                        : motionConfig.dragReturn.position,
                                  ),
                                  _MotionTarget(
                                    dragPosition * alignment.y.sign > 20
                                        ? 0.0
                                        : 1.0,
                                    reduced
                                        ? const ToastMotionSpec.curved(
                                            Duration(milliseconds: 150),
                                            Curves.easeOut,
                                          )
                                        : motionConfig.dragReturn.opacity,
                                  ),
                                ],
                                snap: [reduced || immediate, immediate],
                                builder: (context, values, child) =>
                                    Transform.translate(
                                      offset: Offset(0, values[0]),
                                      child: Opacity(
                                        opacity: values[1]
                                            .clamp(0, 1)
                                            .toDouble(),
                                        child: child,
                                      ),
                                    ),
                                child: content!,
                              );
                            },
                          );
                          final interactiveChild = MouseRegion(
                            onEnter: (_) => _setHoverDebounced(true),
                            onExit: (_) => _setHoverDebounced(false),
                            child: drag,
                          );

                          // Anchor once. Translation changes paint rather than
                          // requesting Stack layout on every animation tick.
                          return Positioned(
                            top: isTop ? 0 : null,
                            bottom: isBottom ? 0 : null,
                            left: isCenterX
                                ? (stackInnerWidth - toastWidth) / 2
                                : (isLeft ? 0 : null),
                            right: isRight ? 0 : null,
                            width: toastWidth,
                            child: _ToastMotionBuilder(
                              snap: [
                                reduced || immediate,
                                reduced || immediate,
                                immediate,
                              ],
                              onUnsettled: isMarkDeleted
                                  ? () => toastProvider._lifecycle.resume(
                                      toast,
                                      presentation,
                                    )
                                  : null,
                              onSettled: isMarkDeleted
                                  ? () => toastProvider._lifecycle.complete(
                                      toast,
                                      presentation,
                                    )
                                  : !holding && presentation.entering
                                  ? () => presentation.entering = false
                                  : null,
                              arguments: [
                                _MotionTarget(transformY, transition.position),
                                _MotionTarget(scale, transition.scale),
                                _MotionTarget(opacity, transition.opacity),
                              ],
                              builder: (context, values, child) {
                                final transformY = values[0];
                                final scale = values[1];
                                final clampedOpacity = values[2]
                                    .clamp(0, 1)
                                    .toDouble();
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    isTop
                                        ? transformY
                                        : (isBottom ? -transformY : 0),
                                  ),
                                  child: IgnorePointer(
                                    ignoring: clampedOpacity == 0,
                                    child: RepaintBoundary(
                                      key: ValueKey(toast.id),
                                      child: Transform.scale(
                                        scale: scale,
                                        child: Opacity(
                                          opacity: clampedOpacity,
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: interactiveChild,
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
  Timer? hoverDebounce;
  Timer? periodicDelete;

  void dispose() {
    hoverDebounce?.cancel();
    periodicDelete?.cancel();
  }
}
