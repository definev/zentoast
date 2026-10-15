part of 'toast.dart';

final class MotionPresets {
  static Motion get instant => const Motion.linear(Duration.zero);
  static Motion get snap => const Motion.snappySpring();
}

class MotionArgument<T> {
  const MotionArgument(
    this.value,
    this.converter, [
    this.motion = const Motion.bouncySpring(),
  ]);

  const factory MotionArgument.custom(
    T value,
    MotionConverter<T> converter, [
    Motion motion,
  ]) = MotionArgument;

  static MotionArgument<double> single(
    double value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<double>(value, MotionConverter.single, motion);
  static MotionArgument<Offset> offset(
    Offset value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<Offset>(value, MotionConverter.offset, motion);
  static MotionArgument<Alignment> alignment(
    Alignment value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<Alignment>(value, MotionConverter.alignment, motion);
  static MotionArgument<Color> color(
    Color value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<Color>(value, MotionConverter.colorRgb, motion);
  static MotionArgument<Size> size(
    Size value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<Size>(value, MotionConverter.size, motion);
  static MotionArgument<Rect> rect(
    Rect value, [
    Motion motion = const Motion.bouncySpring(),
  ]) => MotionArgument<Rect>(value, MotionConverter.rect, motion);

  final T value;
  final Motion motion;
  final MotionConverter<T> converter;
}

// Independent Motor controllers share one build callback. Each property keeps
// its own motion and velocity when retargeted; only the widget rebuild is shared.
class _ToastMotionBuilder extends StatefulWidget {
  const _ToastMotionBuilder({
    required this.arguments,
    required this.builder,
    required this.child,
    this.snap,
    this.onSettled,
    this.onUnsettled,
  });

  final List<MotionArgument<double>> arguments;
  final ValueWidgetBuilder<List<double>> builder;
  final Widget child;
  final List<bool>? snap;
  final VoidCallback? onSettled;
  final VoidCallback? onUnsettled;

  @override
  State<_ToastMotionBuilder> createState() => _ToastMotionBuilderState();
}

class _ToastMotionBuilderState extends State<_ToastMotionBuilder>
    with TickerProviderStateMixin {
  late final List<MotionController<double>> _controllers;
  late final Listenable _listenable;
  bool _completionScheduled = false;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final argument in widget.arguments)
        MotionController<double>(
          motion: argument.motion,
          vsync: this,
          initialValue: argument.value,
          converter: argument.converter,
        ),
    ];
    _listenable = Listenable.merge(_controllers);
    for (final controller in _controllers) {
      controller.addListener(_checkSettled);
    }
    _checkSettled();
  }

  @override
  void didUpdateWidget(covariant _ToastMotionBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.arguments.length == _controllers.length);
    for (var i = 0; i < _controllers.length; i++) {
      final previous = oldWidget.arguments[i];
      final next = widget.arguments[i];
      final controller = _controllers[i];
      // Match Motor's BaseMotionBuilder update order, including preserving
      // velocity when the motion or the target changes during an animation.
      if (previous.converter != next.converter) {
        controller.converter = next.converter;
      }
      if (previous.motion != next.motion) controller.motion = next.motion;
      if (widget.snap?[i] ?? false) {
        if (controller.isAnimating || controller.value != next.value) {
          controller.value = next.value;
        }
      } else if (previous.value != next.value) {
        controller.animateTo(next.value);
      }
    }
    if (_controllers.any((controller) => controller.isAnimating)) {
      widget.onUnsettled?.call();
    }
    _checkSettled();
  }

  void _checkSettled() {
    if (_completionScheduled ||
        widget.onSettled == null ||
        _controllers.any((controller) => controller.isAnimating)) {
      return;
    }
    _completionScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _completionScheduled = false;
      if (mounted &&
          !_controllers.any((controller) => controller.isAnimating)) {
        widget.onSettled?.call();
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _listenable,
    child: widget.child,
    builder: (context, child) => widget.builder(context, [
      for (final controller in _controllers) controller.value,
    ], child),
  );

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_checkSettled);
      controller.dispose();
    }
    super.dispose();
  }
}
