import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_window_example/rt_toast_entry.dart';

import 'desktop_multi_window_provider.dart';
import 'external_windows.dart';
import 'rt_toast_model.dart';

class ToastManager {
  static final instance = ToastManager();
  static const int maxNotifications = 3;
  static const Duration notificationDuration = Duration(seconds: 4);
  final List<RTToastEntry> _notifications = [];
  final Queue<RTToastModel> _notificationQueue = Queue<RTToastModel>();
  bool _isProcessing = false;

  ToastManager() {
    DesktopMultiWindowProvider.instance.handle.listen((mapCall) {
      try {
        final fromWindowId = mapCall.keys.first;
        final call = mapCall.values.first;
        _handleMethodCallback(call, fromWindowId);
      } catch (e) {}
    });
  }

  Future<dynamic> _handleMethodCallback(
    MethodCall call,
    int fromWindowId,
  ) async {
    if (call.method.toString() == "notificationReady") {
      final windowId = call.arguments;
      final index =
          _notifications.indexWhere((elem) => elem.window.windowId == windowId);
      if (index != -1) {
        final notification = _notifications[index];
        notification.timer = Timer(
          notificationDuration,
          () {
            _removeEntry(notification);
          },
        );

        if (_notifications.length > 1) {
          _onUpNotification(List.of(_notifications)..removeAt(index));
        }
      }
    } else if (call.method.toString() == "removeNotification") {
      final windowId = call.arguments;
      final index =
          _notifications.indexWhere((elem) => elem.window.windowId == windowId);
      if (index != -1) {
        _removeAt(index, true);
      }
    } else if (call.method.toString() == "onTapNotification") {
      final windowId = call.arguments['windowId'];
      final action = call.arguments['action'];
      final index = _notifications.indexWhere(
        (elem) => elem.window.windowId == windowId,
      );
      if (index != -1) {
        final notification = _notifications[index];
        notification.onTap(notification.window, action);
      }
    }
  }

  void showNotification(RTToastModel model) {
    _notificationQueue.addLast(model);
    _startProcessing(model);
  }

  void _startProcessing(RTToastModel model) {
    if (_isProcessing) return;
    _isProcessing = true;
    _processNotifications(model);
  }

  void _processNotifications(RTToastModel model) async {
    while (_notificationQueue.isNotEmpty) {
      RTToastModel modell = _notificationQueue.removeFirst();

      await _showNotification(modell);

      await _checkReadyNext();

      await Future.delayed(const Duration(milliseconds: 350));
    }
    _isProcessing = false;
  }

  Future<void> _checkReadyNext() async {
    while (!(_notifications.lastOrNull?.timer?.isActive == true)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _animatedOpacity(WindowController window) async {
    double opacity = 1;
    while (opacity - 0.15 >= 0) {
      opacity = opacity - 0.15;
      window.setOpacity(opacity);
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _showNotification(RTToastModel model) async {
    if (_notifications.length >= maxNotifications) {
      await _removeAt(0, false);
    }
    final jsonModel = model.toJson();

    final window = await DesktopMultiWindowProvider.createWindow(
      type: ExternalWindowType.notification,
      jsonArguments: {
        'model': jsonEncode(jsonModel),
      },
    );
    late final RTToastEntry entry;
    entry = RTToastEntry(
      onRemove: (window, userRemove) async {
        await _animatedOpacity(window);
        await window.hide();
        if (Platform.isWindows) {
          await window.close();
        }


        if (userRemove) {
          for (int index = 0; index < _notifications.length; index++) {
            final elem = _notifications[index];
            if (index == _notifications.length - 1 ||
                elem.window.windowId == window.windowId ||
                elem.willSoonDeleted ||
                elem.timer?.isActive != true) {
              continue;
            }
            await DesktopMultiWindow.invokeMethod(
              elem.window.windowId,
              "bottom",
            );
          }
        }
        _notifications.remove(entry);
      },
      window: window,
      onTap: (WindowController window, String action) async {
        if (model.onTap != null) {
          model.onTap!(action);
        }
        await _animatedOpacity(window);

        await window.hide();
        if (Platform.isWindows) {
          await window.close();
        }

        for (int index = 0; index < _notifications.length; index++) {
          final elem = _notifications[index];
          if (index == _notifications.length - 1 ||
              elem.window.windowId == window.windowId ||
              elem.willSoonDeleted ||
              elem.timer?.isActive != true) {
            continue;
          }
          await DesktopMultiWindow.invokeMethod(
            elem.window.windowId,
            "bottom",
          );
        }
      },
    );
    _notifications.add(entry);

    final devicePixelRatio = 1.0;
    final size = Platform.isWindows
        ? Size(350 * devicePixelRatio, 100 * devicePixelRatio)
        : const Size(350, 100);
    await window.setFrame(const Offset(0, 0) & size);

    await window.show(isNotification: true);

    if(Platform.isLinux) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> _removeEntry(RTToastEntry entry) async {
    entry.willSoonDeleted = true;
    entry.timer?.cancel();
    await entry.onRemove(entry.window, false);
  }

  Future<void> _removeAt(int index, bool userRemove) async {
    if (!userRemove) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    final entry = _notifications[index];
    if (entry.timer?.isActive == true && !entry.willSoonDeleted) {
      entry.timer?.cancel();
      await entry.onRemove(entry.window, userRemove);
    }
  }

  Future<void> _onUpNotification(List<RTToastEntry> _notifications) async {
    final cached = List.unmodifiable(_notifications);
    for (final RTToastEntry elem in cached) {
      if (elem.willSoonDeleted || elem.timer?.isActive != true) {
        continue;
      }
      try {
        await DesktopMultiWindow.invokeMethod(
          elem.window.windowId,
          "up",
        );
      } catch (e) {
        print(
            'windowId =============================== ${elem.window.windowId}');
      }
    }
  }

  void dispose() {
    DesktopMultiWindow.setMethodHandler(null);
    for (final entry in _notifications) {
      entry.timer?.cancel();
    }
    _notifications.clear();
  }
}
