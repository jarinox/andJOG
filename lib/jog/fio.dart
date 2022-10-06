import 'dart:convert';
import 'dart:io';
import 'package:andjog/jog/settings.dart';
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:andjog/jog/jog.dart';
import 'package:path_provider/path_provider.dart';


Future<String> get appDir async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}


Future<Diary?> loadDiary(String name, String password) async {
  final String path = p.join(await appDir, "$name.enc");
  final File file = File(path);
  if(await file.exists()){
    final String encString = await file.readAsString();
    final List<String> encData = encString.split("\n");

    Key key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(password)).bytes));
    final encrypter = Encrypter(AES(key));

    final IV iv = IV.fromBase64(encData[0]);
    final encrypted = Encrypted.fromBase64(encData[1]);
    try {
      final String decString = encrypter.decrypt(encrypted, iv: iv);
      return Diary.fromJson(name, decString, password); 
    } catch(_){}
  }
  return null;
}


Future<void> saveDiary(Diary diary, {String? directory}) async {
  String path;
  if(directory == null){
    path = p.join(await appDir, "${diary.name}.enc");
  } else {
    path = p.join(directory, "${diary.name}.enc");
  }
  final File file = File(path);
  
  final String decString = diary.toJson();
  Key key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(diary.password)).bytes));
  final IV iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final Encrypted encrypted = encrypter.encrypt(decString, iv: iv);

  await file.writeAsString("${iv.base64}\n${encrypted.base64}");
}


Future<Settings> loadSettings() async {
  final String path = p.join(await appDir, "settings.json");
  final File f = File(path);
  
  if(await f.exists()){
    return Settings.fromJson(
      await f.readAsString()
    );
  } else {
    return Settings("auto", "mon", []);
  }
}

Future<void> saveSettings(Settings settings) async {
  final String path = p.join(await appDir, "settings.json");
  final File f = File(path);
  await f.writeAsString(
    settings.toJson()
  );
}



class DataManager {
  Settings settings;
  Diary diary;

  DataManager(this.settings, this.diary);
}