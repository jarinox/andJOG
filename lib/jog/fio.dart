import 'dart:convert';
import 'dart:io';
import 'package:andjog/jog/settings.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:path/path.dart' as p;
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:andjog/jog/jog.dart';
import 'package:path_provider/path_provider.dart';


Future<String> get appDir async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

Future<String> addFileToMedia(String originalPath, String password) async {
  final File file = File(originalPath);
  final List<int> bytes = await file.readAsBytes();
  final String hash = sha256.convert(bytes).toString();

  // copy file to app directory and rename it to hash
  final String newPath = p.join(await appDir, "media", "$hash");

  final dir = Directory(p.join(await appDir, "media"));
  if (!await dir.exists()){
    await dir.create();
  }

  String encs = await foundation.compute((List message) {
    final List<int> bytes = message[0];
    final String password = message[1];

    Key key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(password)).bytes));
    final encrypter = Encrypter(AES(key));

    final IV iv = IV.fromLength(16);

    final Encrypted encrypted = encrypter.encryptBytes(bytes, iv: iv);

    return "${iv.base64}\n${encrypted.base64}";
  }, [bytes, password]);

  final File newFile = File(newPath);
  await newFile.writeAsString(encs);

  return hash;
}

Future<List<int>?> getBytesFromMedia(String hash, String password) async {
  final String path = p.join(await appDir, "media", hash);
  final File file = File(path);
  if(await file.exists()){
    final String encString = await file.readAsString();

    return await foundation.compute((List params) {
      final String encString = params[0];
      final String password = params[1];

      final List<String> encData = encString.split("\n");
      Key key = Key.fromBase64(base64Encode(sha256.convert(utf8.encode(password)).bytes));
      final encrypter = Encrypter(AES(key));

      final IV iv = IV.fromBase64(encData[0]);
      final encrypted = Encrypted.fromBase64(encData[1]);

      final List<int> bytes = encrypter.decryptBytes(encrypted, iv: iv);
      return bytes;
    }, [encString, password]);
    
  }
  return null;
}

Future<void> deleteFileFromMedia(String hash) async {
  final String path = p.join(await appDir, "media", hash);
  final File file = File(path);
  file.delete();
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
    return Settings("auto", "mon", [], false, {});
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
