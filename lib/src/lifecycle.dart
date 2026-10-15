part of 'toast.dart';

// Membership changes do not mutate reactive provider state during build. Only
// a deferred completion removes a toast, using identity instead of list indices.
class _ToastLifecycle {
  _ToastLifecycle(this.data, this.deleted, this.dragged);
  final ReactiveList<Toast> data;
  final ReactiveSet<int> deleted;
  final ReactiveSet<int> dragged;
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
      final index = data.indexOf(toast);
      if (index < 0) return;
      final deletedToasts = {
        for (final i in deleted)
          if (i < data.length) data[i],
      };
      final draggedToasts = {
        for (final i in dragged)
          if (i < data.length) data[i],
      };
      batch(() {
        data.removeAt(index);
        deleted.clear();
        dragged.clear();
        for (var i = 0; i < data.length; i++) {
          if (deletedToasts.contains(data[i])) deleted.add(i);
          if (draggedToasts.contains(data[i])) dragged.add(i);
        }
      });
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }
}

class _ToastPresentation extends StatefulWidget {
  const _ToastPresentation({
    super.key,
    required this.lifecycle,
    required this.toast,
    required this.builder,
  });
  final _ToastLifecycle lifecycle;
  final Toast toast;
  final Widget Function(BuildContext, Object) builder;

  @override
  State<_ToastPresentation> createState() => _ToastPresentationState();
}

class _ToastPresentationState extends State<_ToastPresentation> {
  @override
  void initState() {
    super.initState();
    widget.lifecycle.register(widget.toast, this);
  }

  @override
  void didUpdateWidget(covariant _ToastPresentation oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    widget.lifecycle.unregister(widget.toast, this);
    super.dispose();
  }
}

class _ToastEntranceStatus {
  bool active = true;
}
