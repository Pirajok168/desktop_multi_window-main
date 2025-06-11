//
// Created by boyan on 2022/1/27.
//

#include "base_flutter_window.h"



static void on_size_allocate(GtkWidget* widget, GdkRectangle* allocation, gpointer user_data) {
   
    GdkDisplay* display = gtk_widget_get_display(widget);
    GdkMonitor* monitor = gdk_display_get_primary_monitor(display);
    if (!monitor) return;

    GdkRectangle monitor_geometry;
    gdk_monitor_get_geometry(monitor, &monitor_geometry);

    
    int margin = 20;
    int x = monitor_geometry.x + monitor_geometry.width - allocation->width - margin;
    int y = monitor_geometry.y + monitor_geometry.height - allocation->height - margin;

    gtk_window_move(GTK_WINDOW(widget), x, y);

    g_signal_handlers_disconnect_by_func(widget, (gpointer)on_size_allocate, user_data);
}

void BaseFlutterWindow::Show(bool isNotification) {
    auto window = GetWindow();
    if (!window) {
        return;
    }
    gtk_widget_set_app_paintable(GTK_WIDGET(window), TRUE);    

    if (isNotification) {
        
        gtk_window_set_keep_above(window, TRUE);
        gtk_window_set_skip_taskbar_hint(window, TRUE);
        gtk_window_set_skip_pager_hint(window, TRUE);

        g_signal_connect(GTK_WIDGET(window), "size-allocate", G_CALLBACK(on_size_allocate), nullptr);
    } else {
      gtk_widget_show(GTK_WIDGET(window));
    }
}

void BaseFlutterWindow::Hide() {
  auto window = GetWindow();
  if (!window) {
    return;
  }
  gtk_widget_hide(GTK_WIDGET(window));
}

void BaseFlutterWindow::SetBounds(double_t x, double_t y, double_t width, double_t height) {
  auto window = GetWindow();
  if (!window) {
    return;
  }
  gtk_window_move(GTK_WINDOW(window), static_cast<gint>(x), static_cast<gint>(y));
  gtk_window_resize(GTK_WINDOW(window), static_cast<gint>(width), static_cast<gint>(height));
}

void BaseFlutterWindow::SetTitle(const std::string &title) {
  auto window = GetWindow();
  if (!window) {
    return;
  }
  gtk_window_set_title(GTK_WINDOW(window), title.c_str());
}

void BaseFlutterWindow::Center() {
  auto window = GetWindow();
  if (!window) {
    return;
  }
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
}

void BaseFlutterWindow::Close() {
  auto window = GetWindow();
    if (!window) {
        return;
    }
  gtk_window_close(GTK_WINDOW(window));
}

void BaseFlutterWindow::StartDragging() {
    auto window = GetWindow();
    if (!window) {
        return;
    }

    auto screen = gtk_window_get_screen(window);
    auto display = gdk_screen_get_display(screen);
    auto seat = gdk_display_get_default_seat(display);
    auto device = gdk_seat_get_pointer(seat);

    gint root_x, root_y;
    gdk_device_get_position(device, nullptr, &root_x, &root_y);
    guint32 timestamp = (guint32)g_get_monotonic_time();

    gtk_window_begin_move_drag(window, 1, root_x, root_y, timestamp);


}

void BaseFlutterWindow::SetNewReact(double_t width, double_t height) {
    auto window = GetWindow();
    if (!window) {
        return;
    }
    gtk_window_resize(GTK_WINDOW(window), static_cast<gint>(width), static_cast<gint>(height));
}


void BaseFlutterWindow::SetOpacity(double_t opacity) {
    auto window = GetWindow();
    if (!window) {
        return;
    }

    gtk_widget_set_opacity(GTK_WIDGET(window), opacity);
}

FlMethodResponse* BaseFlutterWindow::GetBounds(double_t devicePixelRatio) {
    auto window = GetWindow();
    if (!window) {
        return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }

    gint x, y, width, height;
    gtk_window_get_position(window, &x, &y);
    gtk_window_get_size(window, &width, &height);

    g_autoptr(FlValue) result_data = fl_value_new_map();
    fl_value_set_string_take(result_data, "x", fl_value_new_float(x));
    fl_value_set_string_take(result_data, "y", fl_value_new_float(y));
    fl_value_set_string_take(result_data, "width", fl_value_new_float(width));
    fl_value_set_string_take(result_data, "height", fl_value_new_float(height));

    return FL_METHOD_RESPONSE(fl_method_success_response_new(result_data));
}

void BaseFlutterWindow::SetBoundsWithAnimation(double_t x, double_t y, double_t width, double_t height) {
    auto window = GetWindow();
    if (!window) {
        return;
    }
    gtk_window_move(GTK_WINDOW(window), static_cast<gint>(x), static_cast<gint>(y));
}


void BaseFlutterWindow::Focus() {
    auto window = GetWindow();
    if (!window) {
        return;
    }
    gtk_window_present(window);
}