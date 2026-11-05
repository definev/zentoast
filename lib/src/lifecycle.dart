part of 'toast.dart';

// Membership changes do not mutate reactive provider state during build. Only
// a deferred completion removes a toast, using identity instead of list indices.
class _ToastLifecycle {
  _ToastLifecycle(this.store);
  final _ToastStore store;
  final _presentations = <Toast, Set<Object>>{};
  final _pending = <Toast, Set<Object>>{};
  final _scheduled = <Toast>{};
  bool _disposed = false;

  void dispose() {
    _disposed = true;
    _presentations.clear();
    _pending.clear();
  }

  void resume(Toast toast, Object presentation) {
    _pending[toast]?.add(presentation);
  }

  void register(Toast toast, Object presentation) {
    (_presentations[toast] ??= {}).add(presentation);
    _pending[toast]?.add(presentation);
  }

  void unregister(Toast toast, Object presentation) {
    _presentations[toast]?.remove(presentation);
    if (_presentations[toast]?.isEmpty ?? false) _presentations.remove(toast);
    _pending[toast]?.remove(presentation);
    if (store.isDragging(toast, presentation)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) store.setDragging(toast, presentation, false);
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    }
    _scheduleRemoval(toast);
  }

  void hide(Toast toast) {
    _pending.putIfAbsent(toast, () => {...?_presentations[toast]});
    _scheduleRemoval(toast);
  }

  void complete(Toast toast, Object presentation) {
    _pending[toast]?.remove(presentation);
    _scheduleRemoval(toast);
  }

  void _scheduleRemoval(Toast toast) {
    if (!_pending.containsKey(toast) || !_scheduled.add(toast)) return;
    // Post-frame permits new presentations in the same frame to register.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled.remove(toast);
      if (_disposed) return;
      if (_pending[toast]?.isNotEmpty ?? true) return;
      _pending.remove(toast);
      _presentations.remove(toast);
      store.remove(toast);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }
}

class _ToastPresentation extends StatefulWidget {
  const _ToastPresentation({
    super.key,
    required this.lifecycle,
    required this.toast,
    required this.hold,
    required this.builder,
  });
  final _ToastLifecycle lifecycle;
  final Toast toast;
  final bool hold;
  final Widget Function(BuildContext, _ToastPresentationState) builder;

  @override
  State<_ToastPresentation> createState() => _ToastPresentationState();
}

class _ToastPresentationState extends State<_ToastPresentation> {
  bool firstAppear = true;
  bool entering = true;
  final dragPosition = ValueNotifier(0.0);
  Timer? _entrance;

  void _finishHold() {
    if (mounted && firstAppear) setState(() => firstAppear = false);
  }

  @override
  void initState() {
    super.initState();
    widget.lifecycle.register(widget.toast, this);
    _entrance = Timer(
      widget.hold ? const Duration(milliseconds: 300) : Duration.zero,
      _finishHold,
    );
  }

  @override
  void didUpdateWidget(covariant _ToastPresentation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.hold && firstAppear) {
      _entrance?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishHold());
    }
    if (oldWidget.lifecycle != widget.lifecycle ||
        oldWidget.toast != widget.toast) {
      oldWidget.lifecycle.unregister(oldWidget.toast, this);
      widget.lifecycle.register(widget.toast, this);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, this);

  @override
  void dispose() {
    _entrance?.cancel();
    dragPosition.dispose();
    widget.lifecycle.unregister(widget.toast, this);
    super.dispose();
  }
}
