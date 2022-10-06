import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/jog_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ViewerScreen extends StatefulWidget {
  final Diary diary;
  final Entry entry;
  const ViewerScreen(this.diary, this.entry, {Key? key}) : super(key: key);

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool hasTracking = false;

  @override
  void initState() {
    hasTracking = widget.entry.other.containsKey("tracking") && widget.entry.other["tracking"].isNotEmpty;
    super.initState();
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
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            widget.entry.text,
            style: const TextStyle(
              fontSize: 15.0
            ),
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