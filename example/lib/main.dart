import 'package:flutter/material.dart';
import 'package:oref/oref.dart';
import 'package:zentoast/zentoast.dart';

final toastAlignment = signal(null, Alignment.bottomRight);

void main() {
  runApp(ToastProvider.create(child: const MyApp()));
}

enum ToastVariant { success, info, warning }

class SonnerToast extends StatelessWidget {
  const SonnerToast({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.height,
    required this.onClose,
  });

  final ToastVariant variant;
  final String title;
  final String message;
  final double height;
  final VoidCallback onClose;

  Color get _accentColor => switch (variant) {
    ToastVariant.success => const Color(0xFF16A34A),
    ToastVariant.info => const Color(0xFF2563EB),
    ToastVariant.warning => const Color(0xFFF59E0B),
  };

  IconData get _icon => switch (variant) {
    ToastVariant.success => Icons.check_circle_rounded,
    ToastVariant.info => Icons.info_rounded,
    ToastVariant.warning => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: Container(
        height: height,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: _accentColor, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(_icon, color: _accentColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.black54,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrutalistToast extends StatelessWidget {
  const BrutalistToast({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.height,
    required this.onClose,
  });

  final ToastVariant variant;
  final String title;
  final String message;
  final double height;
  final VoidCallback onClose;

  Color get _bgColor => switch (variant) {
    ToastVariant.success => const Color(0xFFB8FF66),
    ToastVariant.info => const Color(0xFF8AE1FF),
    ToastVariant.warning => const Color(0xFFFFE666),
  };

  IconData get _icon => switch (variant) {
    ToastVariant.success => Icons.task_alt,
    ToastVariant.info => Icons.info_outline,
    ToastVariant.warning => Icons.warning_amber_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Icon(_icon, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Text(
                  'DISMISS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardToast extends StatelessWidget {
  const CardToast({
    super.key,
    required this.variant,
    required this.title,
    required this.message,
    required this.height,
    required this.onClose,
  });

  final ToastVariant variant;
  final String title;
  final String message;
  final double height;
  final VoidCallback onClose;

  Color get _accentColor => switch (variant) {
    ToastVariant.success => const Color(0xFF16A34A),
    ToastVariant.info => const Color(0xFF2563EB),
    ToastVariant.warning => const Color(0xFFF59E0B),
  };

  IconData get _icon => switch (variant) {
    ToastVariant.success => Icons.check_circle_rounded,
    ToastVariant.info => Icons.info_rounded,
    ToastVariant.warning => Icons.warning_amber_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: height,
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_icon, color: _accentColor, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toaster')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            SignalBuilder(
              builder:
                  (context) => SegmentedButton(
                    segments: [
                      ButtonSegment(
                        value: Alignment.topLeft,
                        label: Text('Top Left'),
                      ),
                      ButtonSegment(
                        value: Alignment.topRight,
                        label: Text('Top Right'),
                      ),
                      ButtonSegment(
                        value: Alignment.bottomLeft,
                        label: Text('Bottom Left'),
                      ),
                      ButtonSegment(
                        value: Alignment.bottomRight,
                        label: Text('Bottom Right'),
                      ),
                    ],
                    selected: {toastAlignment()},
                    onSelectionChanged:
                        (value) => toastAlignment(
                          value.firstOrNull ?? toastAlignment(),
                        ),
                  ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => SonnerToast(
                            variant: ToastVariant.success,
                            title: 'Success',
                            message: 'Your changes have been saved.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Show Success'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => SonnerToast(
                            variant: ToastVariant.info,
                            title: 'Information',
                            message: 'Heads up! Something to be aware of.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Show Information'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => SonnerToast(
                            variant: ToastVariant.warning,
                            title: 'Warning',
                            message: 'Please double-check your input.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Show Warning'),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => BrutalistToast(
                            variant: ToastVariant.success,
                            title: 'Success',
                            message: 'Loud and proud. Changes saved.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Brutalist Success'),
                ),
                FilledButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => BrutalistToast(
                            variant: ToastVariant.info,
                            title: 'Information',
                            message: 'FYI — keep an eye on this.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Brutalist Information'),
                ),
                FilledButton(
                  onPressed: () {
                    Toast(
                      builder:
                          (toast) => BrutalistToast(
                            variant: ToastVariant.warning,
                            title: 'Warning',
                            message: 'Stop. Recheck your inputs!',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Brutalist Warning'),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      height: 300,
                      builder:
                          (toast) => CardToast(
                            variant: ToastVariant.success,
                            title: 'Card Success',
                            message:
                                'This is a card-style toast with an image and custom text. It has a larger height for more content.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Card Success'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      height: 300,
                      builder:
                          (toast) => CardToast(
                            variant: ToastVariant.info,
                            title: 'Card Information',
                            message:
                                'Card toast with placeholder image. Custom text here.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Card Information'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Toast(
                      height: 300,
                      builder:
                          (toast) => CardToast(
                            variant: ToastVariant.warning,
                            title: 'Card Warning',
                            message:
                                'Warning in card style. Larger height, image included.',
                            height: toast.height,
                            onClose: () => toast.hide(context),
                          ),
                    ).show(context);
                  },
                  child: const Text('Card Warning'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toaster',
      home: HomePage(),

      /// Add this if you want global toast
      builder:
          (context, child) => ToastThemeProvider(
            data: ToastTheme(gap: 10, viewerPadding: EdgeInsets.all(12)),
            child: Stack(
              children: [
                Positioned.fill(child: child ?? SizedBox()),
                SafeArea(
                  child: ToastViewer(alignment: watch(context, toastAlignment)),
                ),
              ],
            ),
          ),
    );
  }
}
