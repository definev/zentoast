part of 'toast.dart';

/// A scalar animation used by toast transitions, independent of other packages.
///
/// Springs preserve current velocity when redirected. Curves restart from the
/// current value with the configured duration. Zero-duration curves snap.
@immutable
sealed class ToastMotionSpec {
  const ToastMotionSpec._();

  /// A spring described by perceptual duration and bounce, not a fixed deadline.
  /// Bounce must be greater than -1 and less than 1 so the spring settles.
  const factory ToastMotionSpec.spring({Duration duration, double bounce}) =
      _ToastSpringMotion;

  /// A spring using Flutter's physical constants. Damping must be positive.
  const factory ToastMotionSpec.customSpring(SpringDescription spring) =
      _ToastPhysicalSpringMotion;

  /// A fixed-duration interpolation. Zero duration applies the target directly.
  const factory ToastMotionSpec.curved(Duration duration, [Curve curve]) =
      _ToastCurveMotion;

  /// A fixed-duration linear interpolation.
  const factory ToastMotionSpec.linear(Duration duration) = _ToastCurveMotion;

  Simulation _simulation(double start, double end, double velocity);
}

final class _ToastSpringMotion extends ToastMotionSpec {
  const _ToastSpringMotion({
    this.duration = const Duration(milliseconds: 500),
    this.bounce = 0.15,
  }) : assert(bounce > -1 && bounce < 1),
       super._();

  final Duration duration;
  final double bounce;

  @override
  Simulation _simulation(double start, double end, double velocity) {
    if (duration <= Duration.zero ||
        !bounce.isFinite ||
        bounce <= -1 ||
        bounce >= 1) {
      throw ArgumentError(
        'Spring duration must be positive and -1 < bounce < 1.',
      );
    }
    return SpringSimulation(
      SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      start,
      end,
      velocity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _ToastSpringMotion &&
      duration == other.duration &&
      bounce == other.bounce;
  @override
  int get hashCode => Object.hash(duration, bounce);
}

final class _ToastPhysicalSpringMotion extends ToastMotionSpec {
  const _ToastPhysicalSpringMotion(this.spring) : super._();

  final SpringDescription spring;

  @override
  Simulation _simulation(double start, double end, double velocity) {
    if (!spring.mass.isFinite ||
        spring.mass <= 0 ||
        !spring.stiffness.isFinite ||
        spring.stiffness <= 0 ||
        !spring.damping.isFinite ||
        spring.damping <= 0) {
      throw ArgumentError(
        'Spring mass, stiffness and damping must be finite and positive.',
      );
    }
    return SpringSimulation(spring, start, end, velocity);
  }

  @override
  bool operator ==(Object other) =>
      other is _ToastPhysicalSpringMotion &&
      spring.mass == other.spring.mass &&
      spring.stiffness == other.spring.stiffness &&
      spring.damping == other.spring.damping;
  @override
  int get hashCode =>
      Object.hash(spring.mass, spring.stiffness, spring.damping);
}

final class _ToastCurveMotion extends ToastMotionSpec {
  const _ToastCurveMotion(this.duration, [this.curve = Curves.linear])
    : super._();
  final Duration duration;
  final Curve curve;

  @override
  Simulation _simulation(double start, double end, double velocity) =>
      _ToastCurveSimulation(duration, curve, start, end);

  @override
  bool operator ==(Object other) =>
      other is _ToastCurveMotion &&
      duration == other.duration &&
      curve == other.curve;
  @override
  int get hashCode => Object.hash(duration, curve);
}

class _ToastCurveSimulation extends Simulation {
  _ToastCurveSimulation(Duration duration, this.curve, this.start, this.end)
    : seconds = duration.inMicroseconds / Duration.microsecondsPerSecond {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration', 'Must not be negative');
    }
  }
  final double seconds;
  final Curve curve;
  final double start;
  final double end;

  @override
  double x(double time) {
    // Preserve the previous zero-duration boundary when switching a direct
    // drag into a spring. Its sampled velocity is part of the existing golden
    // trajectories; changing that impulse belongs in a separate motion change.
    if (seconds == 0) return time < 0 ? start : end;
    if (time > seconds) return end;
    return start +
        (end - start) * curve.transform((time / seconds).clamp(0.0, 1.0));
  }

  @override
  double dx(double time) {
    // Compatibility with the original curve controller's finite-difference
    // sampling (including its velocity scale). Keep retargeting unchanged.
    final delta = tolerance.distance;
    return (x(time + delta) - x(time - delta)) / delta * 2;
  }

  @override
  bool isDone(double time) => time > seconds;
}

/// Whether automatic toast motion follows the system accessibility setting.
enum ToastMotionPolicy {
  /// Honor MediaQuery.disableAnimations; use full motion without MediaQuery.
  system,

  /// Always use the configured motions.
  full,

  /// Snap position/scale and fade over 150 milliseconds.
  reduced,

  /// Apply every target immediately, including opacity.
  none,
}

/// Independent motions for a toast's position, scale and opacity.
///
/// Each property uses a zentoast-owned [ToastMotionSpec].
/// Use [ToastMotionPolicy.none] to apply all targets immediately.
@immutable
class ToastMotionTransition {
  const ToastMotionTransition({
    this.position = const ToastMotionSpec.spring(),
    this.scale = const ToastMotionSpec.spring(),
    this.opacity = const ToastMotionSpec.spring(),
  });

  /// Motion for vertical translation.
  final ToastMotionSpec position;

  /// Motion for scale.
  final ToastMotionSpec scale;

  /// Motion for opacity.
  final ToastMotionSpec opacity;

  /// Creates a copy with only the supplied properties replaced.
  ToastMotionTransition copyWith({
    ToastMotionSpec? position,
    ToastMotionSpec? scale,
    ToastMotionSpec? opacity,
  }) => ToastMotionTransition(
    position: position ?? this.position,
    scale: scale ?? this.scale,
    opacity: opacity ?? this.opacity,
  );

  @override
  bool operator ==(Object other) =>
      other is ToastMotionTransition &&
      position == other.position &&
      scale == other.scale &&
      opacity == other.opacity;
  @override
  int get hashCode => Object.hash(position, scale, opacity);
}

/// Motion applied when a drag returns; direct dragging always follows the finger.
@immutable
class ToastDragReturnMotion {
  const ToastDragReturnMotion({
    this.position = const ToastMotionSpec.spring(),
    this.opacity = const ToastMotionSpec.spring(),
  });

  /// Motion for vertical translation.
  final ToastMotionSpec position;

  /// Motion for opacity.
  final ToastMotionSpec opacity;

  /// Creates a copy with only the supplied properties replaced.
  ToastDragReturnMotion copyWith({
    ToastMotionSpec? position,
    ToastMotionSpec? opacity,
  }) => ToastDragReturnMotion(
    position: position ?? this.position,
    opacity: opacity ?? this.opacity,
  );

  @override
  bool operator ==(Object other) =>
      other is ToastDragReturnMotion &&
      position == other.position &&
      opacity == other.opacity;
  @override
  int get hashCode => Object.hash(position, opacity);
}

/// Toast motion grouped by the transition being performed.
///
/// Full-motion defaults preserve the original 300 ms entrance hold and snappy
/// springs (500 ms perceptual duration). Spring completion can take longer than
/// its perceptual duration. Exits remain mounted until every viewer completes.
@immutable
class ToastMotionConfig {
  const ToastMotionConfig({
    this.enter = const ToastMotionTransition(),
    this.exit = const ToastMotionTransition(),
    this.reposition = const ToastMotionTransition(),
    this.dragReturn = const ToastDragReturnMotion(),
    this.policy = ToastMotionPolicy.system,
  });

  /// Entrance after the initial hold.
  final ToastMotionTransition enter;

  /// Dismissal, overriding an unfinished entrance.
  final ToastMotionTransition exit;

  /// Stack changes and expansion/collapse after entrance settles.
  final ToastMotionTransition reposition;

  /// Return after a canceled or non-dismissing drag.
  final ToastDragReturnMotion dragReturn;

  /// Accessibility policy, resolved independently by each viewer.
  final ToastMotionPolicy policy;

  /// Creates a copy with only the supplied phases or policy replaced.
  ToastMotionConfig copyWith({
    ToastMotionTransition? enter,
    ToastMotionTransition? exit,
    ToastMotionTransition? reposition,
    ToastDragReturnMotion? dragReturn,
    ToastMotionPolicy? policy,
  }) => ToastMotionConfig(
    enter: enter ?? this.enter,
    exit: exit ?? this.exit,
    reposition: reposition ?? this.reposition,
    dragReturn: dragReturn ?? this.dragReturn,
    policy: policy ?? this.policy,
  );

  @override
  bool operator ==(Object other) =>
      other is ToastMotionConfig &&
      enter == other.enter &&
      exit == other.exit &&
      reposition == other.reposition &&
      dragReturn == other.dragReturn &&
      policy == other.policy;
  @override
  int get hashCode => Object.hash(enter, exit, reposition, dragReturn, policy);
}
