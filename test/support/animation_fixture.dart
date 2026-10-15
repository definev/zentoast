import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:zentoast/zentoast.dart';

/// Identical content and counters for the profile benchmark and visual tests.
class AnimationFixture {
  AnimationFixture({
    this.alignment = Alignment.topRight,
    this.viewerCount = 1,
    this.visibleCount = 3,
    this.width = 320,
  });

  final Alignment alignment;
  final int viewerCount;
  final int visibleCount;
  final double width;
  final boundaryKey = GlobalKey();
  late ToastProvider provider;
  final toasts = <Toast>[];
  int builderCalls = 0;
  int layouts = 0;
  int paints = 0;

  Widget get widget => ToastProvider.create(
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'Ahem'),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            provider = ToastProvider.of(context);
            return RepaintBoundary(
              key: boundaryKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFFE9EDF2)),
                  for (var i = 0; i < viewerCount; i++)
                    ToastViewer(
                      alignment: i == 0 ? alignment : Alignment.bottomLeft,
                      delay: null,
                      visibleCount: visibleCount,
                      width: width,
                      thresholdFullWidth: 600,
                      categories: [ToastCategory('viewer-$i')],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  void show(int count) {
    for (var viewer = 0; viewer < viewerCount; viewer++) {
      for (var i = 0; i < count; i++) {
        final height = [64.0, 88.0, 104.0][i % 3];
        final index = toasts.length;
        final toast = Toast(
          category: ToastCategory('viewer-$viewer'),
          height: height,
          builder: (_) {
            builderCalls++;
            return _PaintProbe(
              fixture: this,
              child: Container(
                key: ValueKey('content-$index'),
                height: height,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB8C3D0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: ColoredBox(color: Color(0xFF22A070)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Toast $index',
                            style: const TextStyle(fontSize: 12, height: 1),
                          ),
                          const Text(
                            'Saved successfully.',
                            style: TextStyle(fontSize: 12, height: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        toasts.add(toast);
        provider.show(toast);
      }
    }
  }

  Map<String, int> get counters => {
    'builder_calls': builderCalls,
    'content_layouts': layouts,
    'content_paints': paints,
  };
}

class _PaintProbe extends SingleChildRenderObjectWidget {
  const _PaintProbe({required this.fixture, required super.child});
  final AnimationFixture fixture;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderProbe(fixture);
}

class _RenderProbe extends RenderProxyBox {
  _RenderProbe(this.fixture);
  final AnimationFixture fixture;

  @override
  void performLayout() {
    fixture.layouts++;
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    fixture.paints++;
    super.paint(context, offset);
  }
}
