import 'dart:ui';

import 'window_controller_impl.dart';

/// The [WindowController] instance that is used to control this window.
abstract class WindowController {
  WindowController();

  factory WindowController.fromWindowId(int id) {
    return WindowControllerMainImpl(id);
  }

  factory WindowController.main() {
    return WindowControllerMainImpl(0);
  }

  /// The id of the window.
  /// 0 means the main window.
  int get windowId;

  /// Close the window.
  Future<void> close();

  /// Show the window.
  Future<void> show({bool isNotification});

  /// Hide the window.
  Future<void> hide();

  /// Set the window frame rect.
  Future<void> setFrame(Rect frame);

  Future<void> setBoundsWithAnimation(Rect frame);

  /// Center the window on the screen.
  Future<void> center();

  /// Set the window's title.
  Future<void> setTitle(String title);

  /// Whether the window can be resized. Available only on macOS.
  ///
  /// Most useful for ensuring windows *cannot* be resized. Windows are
  /// resizable by default, so there is no need to explicitly define a window
  /// as resizable by calling this function.
  Future<void> resizable(bool resizable);

  Future<void> startDragging();

  Future<void> setNewReact(double width, double height);

  /// Available only on macOS.
  Future<void> setFrameAutosaveName(String name);

  Future<void> setOpacity(double opacity);

  Future<Rect> getBounds(double devicePixelRatio);

  Future<void> focus();

  Future<void> upNotification();

  Future<void> downNotification();
}
