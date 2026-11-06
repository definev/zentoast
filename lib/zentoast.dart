library;

/// Public entry point for the zentoast package.
///
/// Import this file to access the toast API:
///   import 'package:zentoast/zentoast.dart';
///
/// Do not import files from `src/` directly; they are considered private to the package.

export 'src/toast.dart'
    show
        Toast,
        ToastCategory,
        ToastProvider,
        ToastMotionSpec,
        ToastMotionConfig,
        ToastMotionTransition,
        ToastDragReturnMotion,
        ToastMotionPolicy,
        ToastTheme,
        ToastThemeProvider,
        ToastViewer;
