import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';


@JsonSerializable()
class Settings {
  String colorMode;
  String firstDay;
  List<String> recentlyUsed;

  Settings(
    this.colorMode,
    this.firstDay,
    this.recentlyUsed
  );

  factory Settings.fromJson(String json) => _$SettingsFromJson(Map<String, dynamic>.from(jsonDecode(json)));
  String toJson() => jsonEncode(_$SettingsToJson(this));
}