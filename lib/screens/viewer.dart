import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/jog_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ViewerScreen extends StatefulWidget {
  final Diary diary;
  final Entry entry;
  const ViewerScreen(this.diary, this.entry, {Key? key}) : super(key: key);

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

String getMediaPath(String hash, String localAppDir) {
  return p.join(localAppDir, "media", hash);
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool hasTracking = false;
  List<Uint8List> images = [];

  void loadImages() async {
    if(!widget.entry.other.containsKey("images")) return;
    await Future.delayed(const Duration(milliseconds: 200));

    for(String hash in widget.entry.other["images"]){
      if(hash == "0") continue;
      List<int>? bytes = await getBytesFromMedia(hash, widget.diary.password);
      
      if(bytes != null){
        setState(() {
          images.add(Uint8List.fromList(bytes));
        });
      }
    }
  }


  @override
  void initState() {
    hasTracking = widget.entry.other.containsKey("tracking") && widget.entry.other["tracking"].isNotEmpty;
    super.initState();
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat(tr.dateFormat).format(widget.entry.createdAt)),

        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Chip(
                label: Text(widget.diary.categories[widget.entry.category]),
                backgroundColor: categoryColor(widget.entry.category).withOpacity(0.7),
              ),
            ),
          )
        ],
      ),

      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.entry.text,
              style: const TextStyle(
                fontSize: 15.0
              ),
            ),
          ),
          

          if(widget.entry.other.containsKey("images"))
            if(widget.entry.other["images"].isNotEmpty)
              SizedBox(
                height: 200.0,
                child: Center(child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.entry.other["images"].length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: EdgeInsets.only(left: (index == 0 ? 0.0 : 8.0)),
                      child: GestureDetector(
                        child: images.length > index ? Image.memory(
                          images[index],
                          fit: BoxFit.cover,
                        ) :
                        Container(
                          width: 112,
                          color: Colors.grey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Image.memory(images[index])));
                        },
                      ),
                    );
                  },
                ),),
              ),

          hasTracking ? const SizedBox(height: 36.0) : const SizedBox(),
          hasTracking ? Text(tr.tracking, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16.0)) : const SizedBox(),

          hasTracking ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.entry.other["tracking"].length,
            itemBuilder: (context, index){
              final quest = widget.entry.other["tracking"][index];
              String value = "";
              if(quest["type"] == "bool"){
                value = quest["value"] ? tr.yes : tr.no;
              }

              if(quest["type"] == "number"){
                value = quest["value"].toString();
              }

              if(quest["type"] == "slider"){
                value = quest["options"][4-(quest["value"] / 2 +0.5).floor()] + " (${quest["value"]+1}/9)";
              }


              return ListTile(
                title: Text(value),
                subtitle: Text(widget.entry.other["tracking"][index]["title"]),
              );
            },
          ) : const SizedBox(),
        ],
      ),
    );
  }
}
