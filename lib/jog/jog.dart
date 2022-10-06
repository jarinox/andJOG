import 'dart:convert';
import 'dart:math';

import 'package:table_calendar/table_calendar.dart';


class SearchFilter {
  List<int>? categories;
  String? text;
  DateTime? date;
}


class Entry {
  int id;
  int category;
  String text;
  DateTime createdAt;
  List<int> keywords;
  Map<String, dynamic> other;

  Entry(this.id, this.category, this.text, this.createdAt, this.keywords, this.other);
  
  factory Entry.fromMap(Map data){
    Entry entry = Entry(
      data["id"],
      data["category"],
      data["text"],
      DateTime.fromMillisecondsSinceEpoch(data["createdAt"]),
      List<int>.from(data["keywords"]),
      data["other"],
    );
    return entry;
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id": id,
      "text": text,
      "category": category,
      "createdAt": createdAt.millisecondsSinceEpoch,
      "keywords": keywords,
      "other": other,
    };
    
    return map;
  }
}

class Diary {
  String name;
  String password;
  List<Entry> entries;
  List<String> categories;
  Map<String, dynamic> settings;


  void addEntry(Entry entry){
    while(entries.indexWhere((element) => element.id == entry.id) != -1){
      entry.id = Random().nextInt(4294967296);
    }

    entries.add(entry);
    entries.sort((a, b){
      return a.createdAt.compareTo(b.createdAt);
    });
  }


  List<Entry> filter(SearchFilter filter, {int maxLength = 20}){
    List<Entry> filteredEntries = [];
    if(filter.text != null){
      filter.text = filter.text!.toLowerCase();
    }

    for(Entry entry in entries.reversed){
      if(filteredEntries.length >= maxLength){
        break;
      }

      if(filter.text != null){
        if(!entry.text.toLowerCase().contains(filter.text!)){
          continue;
        }
      }

      if(filter.date != null){
        if(!isSameDay(filter.date!, entry.createdAt)){
          continue;
        }
      }

      if(filter.categories != null && filter.categories!.isNotEmpty){
        if(!filter.categories!.contains(entry.category)){
          continue;
        }
      }

      filteredEntries.add(entry);
    }

    return filteredEntries;
  }


  Diary(this.name, this.password, this.categories, this.entries, this.settings);

  factory Diary.fromJson(String name, String json, String password){
    final data = jsonDecode(json);
    Diary diary = Diary(name, password, [], [], data["settings"]);

    for(Map entry in data["entries"]){
      diary.entries.add(
        Entry.fromMap(entry),
      );
    }

    diary.categories = List<String>.from(data["categories"]);

    return diary;
  }

  String toJson(){
    List<Map<String, dynamic>> mappedEntries = [];
    
    for(Entry entry in entries){
      mappedEntries.add(
        entry.toMap()
      );
    }

    return jsonEncode({
      "entries": mappedEntries,
      "settings": settings,
      "categories": categories,
    });
  }
}