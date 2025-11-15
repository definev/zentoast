![banner.png](https://github.com/definev/zentoast/blob/main/assets/banner.png?raw=true)

# zentoast

**A headless, fully customizable toast system for Flutter.**
You design the UI — **zentoast** takes care of animation, physics, queuing, gestures, and multi-position viewers. Perfect for building Sonner-like toasts, message banners, or fully custom notification UIs.

[Demo here 🚀](https://zentoast.vercel.app/)

![demo.gif](https://github.com/definev/zentoast/blob/main/assets/demo.gif?raw=true)

## Features

- ✨ **Headless Architecture** – Bring your own widgets & design
- 🎯 **Flexible Positioning** – Display toasts anywhere on screen
- 🎨 **Extremely Customizable** – Full control over layout, styling & behavior
- 🏃 **Fluid Animations** – Motor-powered, physics-based animation system
- 👆 **Rich Gestures** – Drag to dismiss, tap to pause, swipe interactions
- 🔧 **Theming Support** – Global settings via `ToastTheme`
- 📦 **Multiple Viewers** – Independent stacks with synchronized smoothness

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  zentoast: ^latest_version
```

Import:

```dart
import 'package:zentoast/zentoast.dart';
```

---

## Quick Start

Wrap your app with `ToastProvider` and configure a `ToastViewer`:

```dart
void main() {
  runApp(
    ToastProvider.create(
      child: MyApp(),
    ),
  );
}
```

### Minimal Example

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ToastThemeProvider(
        data: ToastTheme(
          gap: 8,
          viewerPadding: EdgeInsets.all(12),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: child ?? SizedBox()),
            SafeArea(
              child: ToastViewer(
                alignment: Alignment.topRight,
                delay: Duration(seconds: 3),
                visibleCount: 3,
              ),
            ),
          ],
        ),
      ),
      home: HomePage(),
    );
  }
}
```

### Triggering a Toast

```dart
ElevatedButton(
  onPressed: () {
    Toast(
      height: 64,
      builder: (toast) => Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Success! Your changes have been saved.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => toast.hide(context),
            ),
          ],
        ),
      ),
    ).show(context);
  },
  child: Text('Show Toast'),
)
```

---

## Building Your Own Toast UI

`zentoast` is **headless**, meaning you provide the UI.
Here’s a custom toast example:

```dart
class CustomToast extends StatelessWidget {
  const CustomToast({
    super.key,
    required this.title,
    required this.message,
    required this.onClose,
    this.icon,
    this.color = Colors.blue,
  });

  final String title;
  final String message;
  final VoidCallback onClose;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color),
              SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  SizedBox(height: 4),
                  Text(message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      )),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
```

Usage:

```dart
Toast(
  height: 80,
  builder: (toast) => CustomToast(
    title: 'New Message',
    message: 'You have received a new message from John',
    icon: Icons.message,
    color: Colors.purple,
    onClose: () => toast.hide(context),
  ),
).show(context);
```

---

## Positioning

Place toasts anywhere with `alignment`:

```dart
ToastViewer(alignment: Alignment.topLeft)
ToastViewer(alignment: Alignment.bottomCenter)
ToastViewer(alignment: Alignment.topRight)
ToastViewer(alignment: Alignment.bottomRight)
```

---

## Multiple Viewers

You can show independent toasts in multiple corners for each toast category:

```dart
Stack(
  children: [
    Positioned.fill(child: child),

    SafeArea(
      child: ToastViewer(
        alignment: Alignment.topRight,
        delay: Duration(seconds: 3),
        // Display all toast no filter
        categories: null,
      ),
    ),

    SafeArea(
      child: ToastViewer(
        alignment: Alignment.bottomCenter,
        delay: Duration(seconds: 5),
        // Display only `Toast` with specific category
        categories: [
          ToastCategory.success,
          ToastCategory.error,
        ],
      ),
    ),
  ],
)
```

Animations stay smooth even when dismissing multiple stacks simultaneously.

---

## Categorize Toast

Organize notifications by `ToastCategory` so each `ToastViewer` can focus on
the messages it cares about. Every toast defaults to `ToastCategory.general`,
and you can introduce new categories with a simple `const ToastCategory('name')`.

```dart
const billingCategory = ToastCategory('billing');

void _showCategorizedToasts(BuildContext context) {
  Toast(
    category: ToastCategory.success,
    builder: (toast) => SuccessToast(onClose: () => toast.hide(context)),
  ).show(context);

  Toast(
    category: ToastCategory.error,
    builder: (toast) => ErrorToast(onClose: () => toast.hide(context)),
  ).show(context);

  Toast(
    category: billingCategory,
    builder: (toast) => BillingToast(onClose: () => toast.hide(context)),
  ).show(context);
}

Widget build(BuildContext context) {
  return ToastProvider.create(
    child: Stack(
      children: [
        ToastViewer(
          alignment: Alignment.topRight,
          categories: const [
            ToastCategory.success,
            ToastCategory.error,
          ],
        ),
        ToastViewer(
          alignment: Alignment.bottomLeft,
          categories: const [billingCategory],
          delay: const Duration(milliseconds: 300),
        ),
      ],
    ),
  );
}
```

With this setup, success and error notifications render at the top-right,
while billing alerts stay anchored at the bottom-left with a custom delay.

---

## Theming

```dart
ToastThemeProvider(
  data: ToastTheme(
    gap: 12,
    viewerPadding: EdgeInsets.all(16),
  ),
  child: YourApp(),
)
```

---

## Advanced Configuration

```dart
Toast(
  height: 100,
  category: ToastCategory.success, // Config customize category
  builder: (toast) => YourToastWidget(
    onClose: () => toast.hide(context),
  ),
);

ToastViewer(
  alignment: Alignment.topRight,
  delay: Duration(seconds: 4),
  visibleCount: 3,
  categories: [ToastCategory.success, ToastCategory('card')],
);
```

---

## Gesture Support

zentoast includes gesture interaction with no extra setup:

* **Swipe to dismiss** (vertical)
* **Touch to pause auto-dismiss**
* **Drag to remove**
* Smooth physics response powered by *motor*

---

## Example App

See `/example` for:

* Sonner-like toasts
* Brutalist / Card variants
* Multi-position demos
* Gesture demos
* Advanced theming and animations

---

## API Overview

### Core Classes

* **`Toast`** – Creates a toast instance
* **`ToastProvider`** – Global manager for the toast stack
* **`ToastViewer`** – Renders a toast queue with animations
* **`ToastTheme`** – Global styling config
* **`ToastThemeProvider`** – Provides theme to descendants

### Key Methods

* `Toast.show(context)` – Show a toast
* `Toast.hide(context)` – Hide the toast
* `ToastProvider.of(context)` – Access provider manually

---

## Contributing

Contributions are welcome!
Please open an issue or submit a PR.

---

## License

MIT License. See `LICENSE` for details.