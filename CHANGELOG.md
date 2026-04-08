## 0.2.2
- Fix `ToastViewer` horizontal positioning for `Alignment.topCenter` and `Alignment.bottomCenter`: the toast bar is centered within the padded viewport (including when the bar is narrower than the viewport on wide layouts).
- Add widget tests covering center alignment for wide and narrow surfaces.

## 0.2.1
- Update `oref` to `^2.8.0` with correct and best practices of `oref`. Thanks @medz

## 0.2.0
- Update `oref` to `^2.6.0`

## 0.1.3
- Add `thresholdFullWidth` and `width` parameters to `ToastViewer`

## 0.1.2
- Add demo gif

## 0.1.1
- Add great banner for zentoast :-)

## 0.1.0
- Introduce `ToastCategory` filtering across multiple `ToastViewer` instances
- Document category usage with hands-on README examples

## 0.0.3
- Fix lint

## 0.0.2
- Provide comprehensive documentation for:
  - `Toast`
  - `ToastProvider`
  - `ToastTheme`
  - `ToastThemeProvider`
  - `ToastViewer`

## 0.0.1

- Initial release of `zentoast`
- Provides headless toast primitives: `Toast`, `ToastProvider`, `ToastViewer`
- Adds theming support via `ToastTheme` and `ToastThemeProvider`
- Ships example app showcasing Sonner-style, Brutalist, and Card toast designs
