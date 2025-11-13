# Zentoast Example

A comprehensive example demonstrating the capabilities of the `zentoast` headless toast library.

## Running the Example

```bash
cd example
flutter run
```

## Featured Toast Styles

This example showcases three different toast design systems:

### 1. **Sonner-style Toasts**
Clean, modern toasts inspired by Sonner with left border accent, icon indicators, and smooth shadows.

### 2. **Brutalist Toasts**
Bold, attention-grabbing toasts with thick borders, uppercase text, and stark shadows for maximum impact.

### 3. **Card Toasts**
Rich media toasts with larger height, perfect for displaying images, detailed content, or interactive elements.

## Key Demonstrations

- **Multiple Toast Positions**: Shows toasts at both `topLeft` and `bottomRight` simultaneously
- **Toast Variants**: Success, Info, and Warning states with unique colors and icons
- **Interactive Features**: 
  - Swipe to dismiss
  - Tap to pause auto-dismiss
  - Close buttons
- **Custom Heights**: Standard 64px toasts and large 300px card toasts
- **Theme Configuration**: Custom gap spacing and viewer padding
- **Auto-dismiss**: Configurable delay with default of 2 seconds

## Code Structure

```dart
example/
├── lib/
│   └── main.dart         # Complete example implementation
├── pubspec.yaml          # Dependencies
└── README.md            # This file
```

## Learn More

For detailed documentation on creating your own custom toasts and advanced configurations, see the [main package documentation](../README.md).
