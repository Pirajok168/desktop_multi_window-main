import 'dart:async';

import 'package:desktop_multi_window/desktop_multi_window.dart';



class RTToastEntry {
  final Future<void> Function(WindowController window, bool userRemove) onRemove;
  final Future<void> Function(WindowController window, String action) onTap;
  final WindowController window;

  Timer? timer;
  bool willSoonDeleted = false;

  RTToastEntry({
    required this.onRemove,
    required this.window,
    required this.onTap,
  });
}