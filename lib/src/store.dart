part of 'toast.dart';

// Signals stay private. Widget listeners observe structural changes, never
// animation ticks or pointer coordinates.
class _ToastStore {
  final items = signal<List<Toast>>(const []);
  final deleted = signal<Set<Toast>>(const {});
  final dragged = signal<Set<Toast>>(const {});
  final _dragOwners = <Toast, Set<Object>>{};
  late final lifecycle = _ToastLifecycle(this);

  void show(Toast toast) {
    if (!items().contains(toast)) {
      items.set(List.unmodifiable([...items(), toast]));
    }
  }

  void hide(Toast toast) {
    if (!items().contains(toast) || deleted().contains(toast)) return;
    lifecycle.hide(toast);
    deleted.set(Set.unmodifiable({...deleted(), toast}));
  }

  bool isDragging(Toast toast, Object owner) =>
      _dragOwners[toast]?.contains(owner) ?? false;

  void setDragging(Toast toast, Object owner, bool value) {
    if (!items().contains(toast)) return;
    if (value) {
      (_dragOwners[toast] ??= {}).add(owner);
    } else {
      _dragOwners[toast]?.remove(owner);
      if (_dragOwners[toast]?.isEmpty ?? false) _dragOwners.remove(toast);
    }
    final dragging = _dragOwners.containsKey(toast);
    if (dragged().contains(toast) == dragging) return;
    final next = {...dragged()};
    dragging ? next.add(toast) : next.remove(toast);
    dragged.set(Set.unmodifiable(next));
  }

  void remove(Toast toast) {
    _dragOwners.remove(toast);
    startBatch();
    try {
      items.set(List.unmodifiable(items().where((item) => item != toast)));
      deleted.set(Set.unmodifiable({...deleted()}..remove(toast)));
      dragged.set(Set.unmodifiable({...dragged()}..remove(toast)));
    } finally {
      endBatch();
    }
  }

  void dispose() {
    _dragOwners.clear();
    lifecycle.dispose();
  }
}

// An explicit projection is enough for zentoast; no widget hooks or custom
// Element lifecycle are needed. The owner stops the effect in State.dispose.
class _SignalListenable extends ChangeNotifier {
  _SignalListenable(void Function() read) {
    var initial = true;
    _effect = effect(() {
      read();
      if (!initial) notifyListeners();
    });
    initial = false;
  }

  late final Effect _effect;

  @override
  void dispose() {
    _effect();
    super.dispose();
  }
}

class _ToastProviderOwner extends StatefulWidget {
  const _ToastProviderOwner({required this.child});
  final Widget child;

  @override
  State<_ToastProviderOwner> createState() => _ToastProviderOwnerState();
}

class _ToastProviderOwnerState extends State<_ToastProviderOwner> {
  final _store = _ToastStore();

  @override
  Widget build(BuildContext context) =>
      ToastProvider._(store: _store, child: widget.child);

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }
}
