// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      json['colorMode'] as String,
      json['firstDay'] as String,
      (json['recentlyUsed'] as List<dynamic>).map((e) => e as String).toList(),
      json['fingerprint'] as bool,
      Map<String, String>.from(json['passwords'] as Map),
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'colorMode': instance.colorMode,
      'firstDay': instance.firstDay,
      'recentlyUsed': instance.recentlyUsed,
      'fingerprint': instance.fingerprint,
      'passwords': instance.passwords,
    };
