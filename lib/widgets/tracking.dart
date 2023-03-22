import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TrackingListWidget extends StatefulWidget {
  final Entry entry;
  const TrackingListWidget(this.entry, {Key? key}) : super(key: key);

  @override
  State<TrackingListWidget> createState() => _TrackingListWidgetState();
}

class _TrackingListWidgetState extends State<TrackingListWidget> {
  List<TextEditingController> tecs = [];

  late Entry mEntry;

  List<Widget> buildTracking(context){
    final tr = AppLocalizations.of(context)!;
    List<Widget> quests = [];

    for(int i = 0; i < mEntry.other["tracking"].length; ++i){
      Map q = widget.entry.other["tracking"][i];
      if(q["type"] == "bool"){
        quests.add(
          CheckboxListTile(
            title: Text(q["title"], overflow: TextOverflow.ellipsis,),
            value: mEntry.other["tracking"][i]["value"],
            onChanged: (bool? newValue){
              setState(() {
                mEntry.other["tracking"][i]["value"] = newValue!;
                q["value"] = newValue;
              });
            }
          )
        );
      }


      if(q["type"] == "slider"){
        quests.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q["title"],
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16.0),
                ),

                Slider(
                  label: q["options"][4-(q["value"] / 2 +0.5).floor()],
                  min: 0,
                  max: 8,
                  divisions: 8,
                  value: double.parse(q["value"].toString()),
                  onChanged: (newValue){
                    setState(() {
                      q["value"] = newValue.toInt();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }


      if(q["type"] == "number"){
        TextEditingController tec = TextEditingController(text: q["value"]);
        tec.selection = TextSelection.fromPosition(TextPosition(offset: tec.text.length));
        tecs.add(tec);

        quests.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 256.0,
                  child: Text(
                    q["title"],
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                
                Expanded(child: Container()),

                SizedBox(
                  height: 26.0,
                  width: 70.0,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: tec,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      q["value"] = value.replaceAll(",", ".");
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    quests.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ElevatedButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          child: Text(tr.save)
        ),
      ),
    );

    quests.add(
      Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
    );

    return quests;
  }

  @override
  void initState() {
    mEntry = widget.entry;
    super.initState();
  }

  @override
  void dispose() {
    for(TextEditingController tec in tecs){
      tec.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: buildTracking(context),
    );
  }
}
