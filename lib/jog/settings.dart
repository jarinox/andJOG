import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';


@JsonSerializable()
class Settings {
  String colorMode;
  String firstDay;
  List<String> recentlyUsed;
  bool fingerprint;
  Map<String, String> passwords;

  Settings(
    this.colorMode,
    this.firstDay,
    this.recentlyUsed,
    this.fingerprint,
    this.passwords
  );

  factory Settings.fromJson(String json) {
    Map a = jsonDecode(json);
    
    if(!a.containsKey("fingerprint")){
      a["fingerprint"] = false;
      a["passwords"] = {};
    }

    return _$SettingsFromJson(Map<String, dynamic>.from(a));
  }
  String toJson() => jsonEncode(_$SettingsToJson(this));
}