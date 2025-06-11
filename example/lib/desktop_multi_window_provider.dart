import 'dart:async';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'package:flutter/services.dart';

import 'external_windows.dart';



class DesktopMultiWindowProvider {
  static final DesktopMultiWindowProvider _instance =
      DesktopMultiWindowProvider._();

  static DesktopMultiWindowProvider get instance => _instance;

  DesktopMultiWindowProvider._() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) {
      return _handleMethodCallback(call, fromWindowId);
    });
  }

  Future<dynamic> _handleMethodCallback(
    MethodCall call,
    int fromWindowId,
  ) async {
    _handle.add({fromWindowId: call});
  }

  final _handle = StreamController<Map<int, MethodCall>>.broadcast();

  Stream<Map<int, MethodCall>> get handle => _handle.stream;

  static Future<WindowController> createWindow({
    required ExternalWindowType type,
    Map<String, dynamic>? jsonArguments,
  }) async {
    final Map<String, dynamic> baseJson = {
      'type': type.name,
    };

    if (jsonArguments != null) {
      baseJson.addAll(jsonArguments);
    }

    return DesktopMultiWindow.createWindow(
      jsonEncode(
        baseJson,
      ),
    );
  }

  static Future<List<int>> getAllSubWindowIds() async {
    try {
      return DesktopMultiWindow.getAllSubWindowIds();
    } catch (e, stackTrace) {
      return [];
    }
  }

  static Future<bool> isExistWindow(windowId) async =>
      (await getAllSubWindowIds()).indexWhere((elem) => elem == windowId) != -1;
}
