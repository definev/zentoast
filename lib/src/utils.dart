part of 'toast.dart';

class _MotionTarget {
  const _MotionTarget(this.value, this.motion);
  final double value;
  final ToastMotionSpec motion;
}

// Independent Flutter controllers share one build callback. Each property keeps
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

  final List<_MotionTarget> arguments;
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
  late final List<AnimationController> _controllers;
  late final Listenable _listenable;
  bool _completionScheduled = false;

  @override
  void initState() {
    super.initState();
    _controllers = [
      for (final argument in widget.arguments)
        AnimationController.unbounded(
          vsync: this,
          value: argument.value,
          animationBehavior: AnimationBehavior.preserve,
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
      // Motion changes redirect the old target first. A subsequent target
      // change starts from that simulation's current value and velocity.
      if (previous.motion != next.motion && controller.isAnimating) {
        _animate(controller, previous.value, next.motion);
      }
      if (widget.snap?[i] ?? false) {
        if (controller.isAnimating || controller.value != next.value) {
          controller.value = next.value;
        }
      } else if (previous.value != next.value) {
        _animate(controller, next.value, next.motion);
      }
    }
    if (_controllers.any((controller) => controller.isAnimating)) {
      widget.onUnsettled?.call();
    }
    _checkSettled();
  }

  void _animate(
    AnimationController controller,
    double target,
    ToastMotionSpec motion,
  ) {
    final simulation = motion._simulation(
      controller.value,
      target,
      controller.velocity,
    );
    controller.animateWith(simulation);
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
