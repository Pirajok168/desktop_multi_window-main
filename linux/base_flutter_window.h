//
// Created by boyan on 2022/1/27.
//

#ifndef DESKTOP_MULTI_WINDOW_LINUX_BASE_FLUTTER_WINDOW_H_
#define DESKTOP_MULTI_WINDOW_LINUX_BASE_FLUTTER_WINDOW_H_

#include <string>
#include <cmath>
#include <gtk/gtk.h>

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

  void SetBoundsWithAnimation(double_t x, double_t y, double_t width, double_t height);

  void Focus();

  FlMethodResponse* GetBounds(double_t devicePixelRatio);

 protected:

  virtual GtkWindow* GetWindow() = 0;
};

#endif //DESKTOP_MULTI_WINDOW_LINUX_BASE_FLUTTER_WINDOW_H_
