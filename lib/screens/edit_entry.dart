import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/widgets/tracking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


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
  List<String> addedImages = [];

  Entry entry = Entry(
    Random().nextInt(4294967296),
    0,
    "",
    DateTime.now(),
    [],
    {"tracking": []}
  );

  String localAppDir = "";
  List<Uint8List> images = [];

  void showTrackingSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context){
        return TrackingListWidget(entry);
      }
    );
  }

  void showMoreSheet(BuildContext context){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context){
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(AppLocalizations.of(context)!.addImage),
                onTap: () {
                  final picker = ImagePicker();
                  picker.pickImage(source: ImageSource.gallery).then((value) async {
                    if(value != null){
                      String hash = await addFileToMedia(value.path, diary.password);
                      addedImages.add(hash);
                      
                      if (!entry.other.containsKey("images")){
                        entry.other["images"] = [];
                      }

                      setState(() {
                        entry.other["images"].add(hash);
                      });

                      Uint8List imgBytes = await value.readAsBytes();

                      setState(() {
                        images.add(imgBytes);
                      });
                    }
                  });
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context)!.takePicture),

                onTap: () {
                  final picker = ImagePicker();
                  picker.pickImage(source: ImageSource.camera).then((value) async {
                    if(value != null){
                      if (!entry.other.containsKey("images")){
                        entry.other["images"] = [];
                      }
                      setState(() {
                        entry.other["images"].add("0");
                      });
                      String hash = await addFileToMedia(value.path, diary.password);
                      
                      

                      setState(() {
                        entry.other["images"].last = hash;
                      });

                      Uint8List imgBytes = await value.readAsBytes();

                      setState(() {
                        images.add(imgBytes);
                      });
                    }
                  });
                },
              ),

              /*ListTile(
                leading: const Icon(Icons.location_pin),
                title: Text(AppLocalizations.of(context)!.addCurrentLocation),
              ),*/
            ],
          ),
        );
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

  void loadImages() async {
    Future.delayed(const Duration(milliseconds: 200)).then((value) async{
      if(!entry.other.containsKey("images")) return;
      images.clear();
      for(String hash in entry.other["images"]){
        List<int>? bytes = await getBytesFromMedia(hash, diary.password);
        if(bytes != null){
          images.add(Uint8List.fromList(bytes));
        }

        setState(() {
          images = images;
        });
      }
    });
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

    loadImages();

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

  void back() async {
    for(String hash in addedImages){
      await deleteFileFromMedia(hash);
    }
    if(!context.mounted) return;
    Navigator.of(context).pop();
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

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: tr.back,
          onPressed: () => back(),
        ),
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

            if(entry.other.containsKey("images"))
              SizedBox(
                height: 100.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.other["images"].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Stack(
                        children: [
                          
                          images.length > index ?Image.memory(
                            images[index],
                            height: 100.0,
                          ) : 
                          Container(
                            width: 56,
                            color: Colors.grey,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),

                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: SizedBox(
                              height: 26.0,
                              width: 26.0,
                                child: Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(130, 244, 67, 54),
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 16.0,
                                  onPressed: () {
                                    deleteFileFromMedia(entry.other["images"][index]);
                                    setState(() {
                                      entry.other["images"].removeAt(index);
                                      images.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.close, color: Colors.white,),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
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
            diary.sortEntries();
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
              TextButton.icon(
                onPressed: useTracking ? (){
                  showTrackingSheet(context);
                } : null,
                icon: const Icon(Icons.track_changes),
                label: Text(tr.tracking),
              ),

              TextButton.icon(
                onPressed: (){
                  showMoreSheet(context);
                },
                icon: const Icon(Icons.more),
                label: Text(tr.more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
