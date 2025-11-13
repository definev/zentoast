part of 'toast.dart';

// ignore: avoid_classes_with_only_static_members
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

typedef MotionFunction1Builder<T1 extends Object> = Widget Function(T1);

extension MotionFunction1<T1 extends Object> on MotionFunction1Builder<T1> {
  Widget motion(MotionArgument<T1> c1) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder: (context, value1, _) => this(value1),
    );
  }
}

typedef MotionFunction2Builder<T1 extends Object, T2 extends Object> =
    Widget Function(T1, T2);

extension MotionFunction2<T1 extends Object, T2 extends Object>
    on MotionFunction2Builder<T1, T2> {
  Widget motion(MotionArgument<T1> c1, MotionArgument<T2> c2) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder: (context, value2, _) => this(value1, value2),
          ),
    );
  }
}

typedef MotionFunction3Builder<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object
> = Widget Function(T1, T2, T3);

extension MotionFunction3<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object
>
    on MotionFunction3Builder<T1, T2, T3> {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder: (context, value3, _) => this(value1, value2, value3),
                ),
          ),
    );
  }
}

typedef MotionFunction4Builder<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object
> = Widget Function(T1, T2, T3, T4);

extension MotionFunction4<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object
>
    on MotionFunction4Builder<T1, T2, T3, T4> {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) =>
                                this(value1, value2, value3, value4),
                      ),
                ),
          ),
    );
  }
}

typedef MotionFunction5Builder<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object
> = Widget Function(T1, T2, T3, T4, T5);

extension MotionFunction5<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object
>
    on MotionFunction5Builder<T1, T2, T3, T4, T5> {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => this(
                                    value1,
                                    value2,
                                    value3,
                                    value4,
                                    value5,
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}

typedef MotionFunction6Builder<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object
> = Widget Function(T1, T2, T3, T4, T5, T6);

extension MotionFunction6<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object
>
    on MotionFunction6Builder<T1, T2, T3, T4, T5, T6> {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) => this(
                                          value1,
                                          value2,
                                          value3,
                                          value4,
                                          value5,
                                          value6,
                                        ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}

typedef MotionFunction7Builder<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object,
  T7 extends Object
> = Widget Function(T1, T2, T3, T4, T5, T6, T7);

extension MotionFunction7<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object,
  T7 extends Object
>
    on MotionFunction7Builder<T1, T2, T3, T4, T5, T6, T7> {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (context, value7, _) => this(
                                                    value1,
                                                    value2,
                                                    value3,
                                                    value4,
                                                    value5,
                                                    value6,
                                                    value7,
                                                  ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}

extension MotionFunction8<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object,
  T7 extends Object,
  T8 extends Object
>
    on Widget Function(T1, T2, T3, T4, T5, T6, T7, T8) {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7,
    MotionArgument<T8> c8,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (context, value7, _) =>
                                                      MotionBuilder<T8>(
                                                        value: c8.value,
                                                        motion: c8.motion,
                                                        converter: c8.converter,
                                                        builder:
                                                            (
                                                              context,
                                                              value8,
                                                              _,
                                                            ) => this(
                                                              value1,
                                                              value2,
                                                              value3,
                                                              value4,
                                                              value5,
                                                              value6,
                                                              value7,
                                                              value8,
                                                            ),
                                                      ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}

extension MotionFunction9<
  T1 extends Object,
  T2 extends Object,
  T3 extends Object,
  T4 extends Object,
  T5 extends Object,
  T6 extends Object,
  T7 extends Object,
  T8 extends Object,
  T9 extends Object
>
    on Widget Function(T1, T2, T3, T4, T5, T6, T7, T8, T9) {
  Widget motion(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7,
    MotionArgument<T8> c8,
    MotionArgument<T9> c9,
  ) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (
                                                    context,
                                                    value7,
                                                    _,
                                                  ) => MotionBuilder<T8>(
                                                    value: c8.value,
                                                    motion: c8.motion,
                                                    converter: c8.converter,
                                                    builder:
                                                        (context, value8, _) =>
                                                            MotionBuilder<T9>(
                                                              value: c9.value,
                                                              motion: c9.motion,
                                                              converter:
                                                                  c9.converter,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    value9,
                                                                    _,
                                                                  ) => this(
                                                                    value1,
                                                                    value2,
                                                                    value3,
                                                                    value4,
                                                                    value5,
                                                                    value6,
                                                                    value7,
                                                                    value8,
                                                                    value9,
                                                                  ),
                                                            ),
                                                  ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}

extension MotionModifier on Widget {
  Widget motion<T extends Object>(
    MotionArgument<T> c1, {
    required Widget Function(BuildContext context, T value, Widget child)
    builder,
  }) {
    return MotionBuilder<T>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder: (context, value, _) => builder(context, value, this),
    );
  }

  Widget motion2<T1 extends Object, T2 extends Object>(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => builder(context, value1, value2, this),
          ),
    );
  }

  Widget motion3<T1 extends Object, T2 extends Object, T3 extends Object>(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) =>
                          builder(context, value1, value2, value3, this),
                ),
          ),
    );
  }

  Widget motion4<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => builder(
                              context,
                              value1,
                              value2,
                              value3,
                              value4,
                              this,
                            ),
                      ),
                ),
          ),
    );
  }

  Widget motion5<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object,
    T5 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      T5 value5,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => builder(
                                    context,
                                    value1,
                                    value2,
                                    value3,
                                    value4,
                                    value5,
                                    this,
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }

  Widget motion6<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object,
    T5 extends Object,
    T6 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      T5 value5,
      T6 value6,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) => builder(
                                          context,
                                          value1,
                                          value2,
                                          value3,
                                          value4,
                                          value5,
                                          value6,
                                          this,
                                        ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }

  Widget motion7<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object,
    T5 extends Object,
    T6 extends Object,
    T7 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      T5 value5,
      T6 value6,
      T7 value7,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (context, value7, _) =>
                                                      builder(
                                                        context,
                                                        value1,
                                                        value2,
                                                        value3,
                                                        value4,
                                                        value5,
                                                        value6,
                                                        value7,
                                                        this,
                                                      ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }

  Widget motion8<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object,
    T5 extends Object,
    T6 extends Object,
    T7 extends Object,
    T8 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7,
    MotionArgument<T8> c8, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      T5 value5,
      T6 value6,
      T7 value7,
      T8 value8,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (context, value7, _) =>
                                                      MotionBuilder<T8>(
                                                        value: c8.value,
                                                        motion: c8.motion,
                                                        converter: c8.converter,
                                                        builder:
                                                            (
                                                              context,
                                                              value8,
                                                              _,
                                                            ) => builder(
                                                              context,
                                                              value1,
                                                              value2,
                                                              value3,
                                                              value4,
                                                              value5,
                                                              value6,
                                                              value7,
                                                              value8,
                                                              this,
                                                            ),
                                                      ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }

  Widget motion9<
    T1 extends Object,
    T2 extends Object,
    T3 extends Object,
    T4 extends Object,
    T5 extends Object,
    T6 extends Object,
    T7 extends Object,
    T8 extends Object,
    T9 extends Object
  >(
    MotionArgument<T1> c1,
    MotionArgument<T2> c2,
    MotionArgument<T3> c3,
    MotionArgument<T4> c4,
    MotionArgument<T5> c5,
    MotionArgument<T6> c6,
    MotionArgument<T7> c7,
    MotionArgument<T8> c8,
    MotionArgument<T9> c9, {
    required Widget Function(
      BuildContext context,
      T1 value1,
      T2 value2,
      T3 value3,
      T4 value4,
      T5 value5,
      T6 value6,
      T7 value7,
      T8 value8,
      T9 value9,
      Widget child,
    )
    builder,
  }) {
    return MotionBuilder<T1>(
      value: c1.value,
      motion: c1.motion,
      converter: c1.converter,
      builder:
          (context, value1, _) => MotionBuilder<T2>(
            value: c2.value,
            motion: c2.motion,
            converter: c2.converter,
            builder:
                (context, value2, _) => MotionBuilder<T3>(
                  value: c3.value,
                  motion: c3.motion,
                  converter: c3.converter,
                  builder:
                      (context, value3, _) => MotionBuilder<T4>(
                        value: c4.value,
                        motion: c4.motion,
                        converter: c4.converter,
                        builder:
                            (context, value4, _) => MotionBuilder<T5>(
                              value: c5.value,
                              motion: c5.motion,
                              converter: c5.converter,
                              builder:
                                  (context, value5, _) => MotionBuilder<T6>(
                                    value: c6.value,
                                    motion: c6.motion,
                                    converter: c6.converter,
                                    builder:
                                        (context, value6, _) =>
                                            MotionBuilder<T7>(
                                              value: c7.value,
                                              motion: c7.motion,
                                              converter: c7.converter,
                                              builder:
                                                  (
                                                    context,
                                                    value7,
                                                    _,
                                                  ) => MotionBuilder<T8>(
                                                    value: c8.value,
                                                    motion: c8.motion,
                                                    converter: c8.converter,
                                                    builder:
                                                        (context, value8, _) =>
                                                            MotionBuilder<T9>(
                                                              value: c9.value,
                                                              motion: c9.motion,
                                                              converter:
                                                                  c9.converter,
                                                              builder:
                                                                  (
                                                                    context,
                                                                    value9,
                                                                    _,
                                                                  ) => builder(
                                                                    context,
                                                                    value1,
                                                                    value2,
                                                                    value3,
                                                                    value4,
                                                                    value5,
                                                                    value6,
                                                                    value7,
                                                                    value8,
                                                                    value9,
                                                                    this,
                                                                  ),
                                                            ),
                                                  ),
                                            ),
                                  ),
                            ),
                      ),
                ),
          ),
    );
  }
}
