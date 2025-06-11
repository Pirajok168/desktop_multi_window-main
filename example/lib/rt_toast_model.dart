

part 'rt_toast_model.g.dart';

sealed class RTToastModel {
  final Function(String)? onTap;

  const RTToastModel({this.onTap});

  Map<String, dynamic> toJson();
}


class ToastSuccessDownloadGame extends RTToastModel {
  final String gameName;
  final String imageUrl;
  final Map<String, String> actions;


  final Function(String)? onTapNotification;

  const ToastSuccessDownloadGame({
    required this.gameName,
    required this.imageUrl,
    this.actions = const {},
    this.onTapNotification,
  }): super(onTap: onTapNotification);


  factory ToastSuccessDownloadGame.fromJson(Map<String, dynamic> json) =>
      _$ToastSuccessDownloadGameFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ToastSuccessDownloadGameToJson(this);
}
