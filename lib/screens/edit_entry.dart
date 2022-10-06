import 'dart:math';
import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/widgets/tracking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EntryEditorScreen extends StatefulWidget {
  final int editNr;
  final Diary diary;
  const EntryEditorScreen(this.diary, this.editNr, {Key? key}) : super(key: key);

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  late Diary diary;
  TextEditingController tecEntry = TextEditingController();

  bool useTracking = true;

  Entry entry = Entry(
    Random().nextInt(4294967296),
    0,
    "",
    DateTime.now(),
    [],
    {"tracking": []}
  );

  void showTrackingSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context){
        return TrackingListWidget(entry);
      }
    );
  }

  void selectDate() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: entry.createdAt,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      locale: Locale(AppLocalizations.of(context)!.localeName),
    );

    if(newDate != null){
      setState(() {
        entry.createdAt = newDate;
      });
    }
  }

  @override
  void initState() {
    diary = widget.diary;
    if(!diary.settings.containsKey("tracking")){
      diary.settings["tracking"] = {
        "enabled": false,
        "quests": [],
      };
    }

    useTracking = diary.settings["tracking"]["enabled"];
    if(useTracking){
      entry.other["tracking"] = diary.settings["tracking"]["quests"];
    }

    if(widget.editNr != -1){
      entry = widget.diary.entries[widget.editNr];
      tecEntry.text = entry.text;
    }

    super.initState();
  }

  @override
  void dispose() {
    tecEntry.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: widget.editNr != -1 ? Text(tr.editEntry) : Text(tr.newEntry),

        actions: [
          Center(
            child: DropdownButton(
              dropdownColor: Colors.grey[900],
              underline: const SizedBox(),
              value: diary.categories[entry.category],
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white,),
              items: diary.categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(color: Colors.white),));
              }).toList(),
              onChanged: (String? item) {
                setState(() {
                  entry.category = diary.categories.indexOf(item!);
                });
              }
            ),
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat(tr.dateFormat).format(entry.createdAt),
                    style: const TextStyle(
                      fontSize: 17.0,
                    ),  
                  ),
                ),

                IconButton(
                  onPressed: () => selectDate(),
                  tooltip: tr.changeDate,
                  icon: const Icon(Icons.calendar_today)
                ),
              ],
            ),

            Expanded(
              child: TextField(
                controller: tecEntry,
                keyboardType: TextInputType.multiline,
                maxLines: 30,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: tr.dearDiary,
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          entry.text = tecEntry.text;
          if(widget.editNr == -1){  
            diary.addEntry(entry);
          } else {
            diary.entries[widget.editNr] = entry;
          }

          await saveDiary(diary);

          if(!mounted) return;
          Navigator.of(context).pop();
        },
        tooltip: tr.save,
        child: const Icon(Icons.check),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 50.0,
          child: ListView(
            padding: const EdgeInsets.all(5.0),
            scrollDirection: Axis.horizontal,
            children: [
              /*TextButton.icon(
                onPressed: (){},
                icon: const Icon(Icons.attach_file),
                label: Text(tr.addAttachement),
              ),*/

              TextButton.icon(
                onPressed: useTracking ? (){
                  showTrackingSheet(context);
                } : null,
                icon: const Icon(Icons.track_changes),
                label: Text(tr.tracking),
              ),
            ],
          ),
        ),
      ),
    );
  }
}