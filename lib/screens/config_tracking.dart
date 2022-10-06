import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TrackingConfigScreen extends StatefulWidget {
  final Diary diary;
  const TrackingConfigScreen(this.diary, {Key? key}) : super(key: key);

  @override
  State<TrackingConfigScreen> createState() => _TrackingConfigScreenState();
}

class _TrackingConfigScreenState extends State<TrackingConfigScreen> with TickerProviderStateMixin {
  late Diary diary;

  late TabController _tabController;

  TextEditingController tecTitle = TextEditingController();

  TextEditingController tecSlider1 = TextEditingController();
  TextEditingController tecSlider2 = TextEditingController();
  TextEditingController tecSlider3 = TextEditingController();
  TextEditingController tecSlider4 = TextEditingController();
  TextEditingController tecSlider5 = TextEditingController();

  @override
  void initState() {
    if(!widget.diary.settings.containsKey("tracking")){
      widget.diary.settings["tracking"] = {
        "enabled": false,
        "quests": [],
      };
    } else {
      if(!widget.diary.settings["tracking"].containsKey("quests")){
        widget.diary.settings["tracking"]["quests"] = [];
      }
    }

    diary = widget.diary;
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tecTitle.dispose();
    tecSlider1.dispose();
    tecSlider2.dispose();
    tecSlider3.dispose();
    tecSlider4.dispose();
    tecSlider5.dispose();

    _tabController.dispose();

    super.dispose();
  }


  void showConfigBottomSheet(BuildContext context, int index){
    final tr = AppLocalizations.of(context)!;

    setState(() {
      tecTitle.text = diary.settings["tracking"]["quests"][index]["title"];

      if(diary.settings["tracking"]["quests"][index]["type"] == "slider"){
        if(!diary.settings["tracking"]["quests"][index].containsKey("options")){
          diary.settings["tracking"]["quests"][index]["options"] = ["", "", "", "", ""];
        }

        tecSlider1.text = diary.settings["tracking"]["quests"][index]["options"][0];
        tecSlider2.text = diary.settings["tracking"]["quests"][index]["options"][1];
        tecSlider3.text = diary.settings["tracking"]["quests"][index]["options"][2];
        tecSlider4.text = diary.settings["tracking"]["quests"][index]["options"][3];
        tecSlider5.text = diary.settings["tracking"]["quests"][index]["options"][4];
      }
    });

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context){
        return ListView(
          shrinkWrap: true,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: tr.yesNo,),
                Tab(text: tr.slider),
                Tab(text: tr.number),
              ]
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: tecTitle,                
                decoration: InputDecoration(
                  filled: true,
                  labelText: tr.questionOrTitle,
                ),
              ),
            ),

            SizedBox(
              height: 200.0,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(tr.trackBoolDescription),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        Text(tr.trackSliderDescription),

                        TextField(
                          controller: tecSlider1,
                          decoration: InputDecoration(
                            labelText: tr.veryGood,
                          ),
                        ),
                        TextField(
                          controller: tecSlider2,
                          decoration: InputDecoration(
                            labelText: tr.good,
                          ),
                        ),
                        TextField(
                          controller: tecSlider3,
                          decoration: InputDecoration(
                            labelText: tr.neutral,
                          ),
                        ),
                        TextField(
                          controller: tecSlider4,
                          decoration: InputDecoration(
                            labelText: tr.bad,
                          ),
                        ),
                        TextField(
                          controller: tecSlider5,
                          decoration: InputDecoration(
                            labelText: tr.veryBad,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(tr.trackNumberDescription),
                  ),
                ]
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    diary.settings["tracking"]["quests"][index]["title"] = tecTitle.text;
                    diary.settings["tracking"]["quests"][index]["type"] = ["bool", "slider", "number"][_tabController.index];

                    switch (_tabController.index) {
                      case 0:
                        diary.settings["tracking"]["quests"][index]["value"] = false; break;
                      case 1:
                        diary.settings["tracking"]["quests"][index]["value"] = 4;
                        diary.settings["tracking"]["quests"][index]["options"] = [tecSlider1.text, tecSlider2.text, tecSlider3.text, tecSlider4.text, tecSlider5.text];
                        break;
                      case 2:
                        diary.settings["tracking"]["quests"][index]["value"] = ""; break;
                    }
                  });

                  await saveDiary(diary);

                  if(!mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(tr.save),
              ),
            ),

            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.configTracking),
      ),

      body: ReorderableListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.drag_handle),
            key: Key(index.toString()),
            title: Text(
              diary.settings["tracking"]["quests"][index]["title"],
              overflow: TextOverflow.ellipsis,
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: (){
                    setState(() {
                      _tabController.index = ["bool", "slider", "number"].indexOf(diary.settings["tracking"]["quests"][index]["type"]);
                    });
                    showConfigBottomSheet(context, index);
                  },
                  icon: const Icon(Icons.edit),
                ),

                IconButton(
                  onPressed: () async {
                    setState(() {
                      diary.settings["tracking"]["quests"].removeAt(index);
                    });

                    await saveDiary(diary);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ]
            ),
          );
        },
        itemCount: diary.settings["tracking"]["quests"].length,
        onReorder: (int oldIndex, int newIndex) async {
          setState(() {  
            final item = diary.settings["tracking"]["quests"].removeAt(oldIndex);
            if(newIndex > diary.settings["tracking"]["quests"].length){
              diary.settings["tracking"]["quests"].add(item);
            } else {
              diary.settings["tracking"]["quests"].insert(newIndex, item);
            }
          });

          await saveDiary(diary);
        }
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          setState(() {
            diary.settings["tracking"]["quests"].add({
              "type": "bool",
              "title": tr.newTracker,
              "value": false,
            });
          });
        },
      ),
    );
  }
}