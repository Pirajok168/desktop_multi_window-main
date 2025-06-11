//
// Created by yangbin on 2022/1/27.
//

#ifndef MULTI_WINDOW_WINDOWS_BASE_FLUTTER_WINDOW_H_
#define MULTI_WINDOW_WINDOWS_BASE_FLUTTER_WINDOW_H_

#include "window_channel.h"

class BaseFlutterWindow {

 public:

  virtual ~BaseFlutterWindow() = default;

  virtual WindowChannel *GetWindowChannel() = 0;

  void Show(bool isNotification);

  void Hide();

  void Close();

  void SetTitle(const std::string &title);

  void SetBounds(double_t x, double_t y, double_t width, double_t height);

  void Center();

  void StartDragging();

  void SetNewReact(double_t width, double_t height);

  void SetOpacity(double_t opacity);

  void BaseFlutterWindow::SetBoundsWithAnimation(double_t x, double_t y, double_t width, double_t height);

  void UpNotification();

  void DownNotification();

  flutter::EncodableMap BaseFlutterWindow::GetBounds(double_t devicePixelRatio);

  void Focus();

  bool IsMinimized();

  void Restore();

  void Undock();

 protected:

  virtual HWND GetWindowHandle() = 0;

};

#endif //MULTI_WINDOW_WINDOWS_BASE_FLUTTER_WINDOW_H_
