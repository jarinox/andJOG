import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/jog_utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesScreen extends StatefulWidget {
  final Diary diary;
  const CategoriesScreen(this.diary, {Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Diary diary;

  TextEditingController tecTitle = TextEditingController();

  @override
  void initState() {
    diary = widget.diary;
    super.initState();
  }

  @override
  void dispose() {
    tecTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.configCategories),
      ),

      body: ListView.builder(
        itemCount: diary.categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              Icons.category,
              color: categoryColor(index),
            ),
            title: Text(diary.categories[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: (){
                    tecTitle.text = diary.categories[index];

                    showDialog(
                      context: context,
                      builder: (context){
                        return SimpleDialog(
                          title: Text(tr.renameCategory),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextField(
                                controller: tecTitle,
                                decoration: InputDecoration(
                                  filled: true,
                                  labelText: tr.title,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(16.0,8.0,16.0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    child: Text(tr.cancel),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  TextButton(
                                    child: Text(tr.save),
                                    onPressed: () async {
                                      setState(() {
                                        diary.categories[index] = tecTitle.text;
                                      });

                                      widget.diary.categories[index] = tecTitle.text;

                                      await saveDiary(diary);

                                      tecTitle.text = "";

                                      if(!mounted) return;
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),

                IconButton(
                  onPressed: () async {
                    bool canRemove = true;
                    for(Entry entry in diary.entries){
                      if(entry.category == index){
                        canRemove = false;
                        break;
                      }
                    }

                    if(canRemove){
                      for(int i = 0; i < diary.entries.length; ++i){
                        if(diary.entries[i].category > index){
                          diary.entries[i].category -= 1;
                        }
                      }

                      setState(() {
                        diary.categories.removeAt(index);
                      });
                      
                      await saveDiary(diary);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr.cantRemoveCategory),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete)
                ),
              ]
            ),
          );
        },
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            diary.categories.add(tr.newCategory);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}