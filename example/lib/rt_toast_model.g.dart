// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rt_toast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToastSuccessDownloadGame _$ToastSuccessDownloadGameFromJson(
        Map<String, dynamic> json) =>
    ToastSuccessDownloadGame(
      gameName: json['gameName'] as String,
      imageUrl: json['imageUrl'] as String,
      actions: (json['actions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$ToastSuccessDownloadGameToJson(
        ToastSuccessDownloadGame instance) =>
    <String, dynamic>{
      'gameName': instance.gameName,
      'imageUrl': instance.imageUrl,
      'actions': instance.actions,
    };
