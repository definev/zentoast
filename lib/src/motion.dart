part of 'toast.dart';

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
/// Advanced overrides use Motion from `package:motor/motor.dart`.
/// Motions must reach their target and complete. `Motion.none` holds its start
/// value; use [ToastMotionPolicy.none] to apply targets immediately.
@immutable
class ToastMotionTransition {
  const ToastMotionTransition({
    this.position = const Motion.snappySpring(),
    this.scale = const Motion.snappySpring(),
    this.opacity = const Motion.snappySpring(),
  });

  /// Motion for vertical translation.
  final Motion position;

  /// Motion for scale.
  final Motion scale;

  /// Motion for opacity.
  final Motion opacity;

  /// Creates a copy with only the supplied properties replaced.
  ToastMotionTransition copyWith({
    Motion? position,
    Motion? scale,
    Motion? opacity,
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
    this.position = const Motion.snappySpring(),
    this.opacity = const Motion.snappySpring(),
  });

  /// Motion for vertical translation.
  final Motion position;

  /// Motion for opacity.
  final Motion opacity;

  /// Creates a copy with only the supplied properties replaced.
  ToastDragReturnMotion copyWith({Motion? position, Motion? opacity}) =>
      ToastDragReturnMotion(
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
