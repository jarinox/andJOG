import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';


class PointOnLine {
  final DateTime time;
  final String track;
  final String title;
  final int trackID;
  final num value;

  PointOnLine(this.time, this.track, this.trackID, this.title, this.value);
}

List colors = [charts.MaterialPalette.blue.shadeDefault, charts.MaterialPalette.red.shadeDefault, charts.MaterialPalette.green.shadeDefault, charts.MaterialPalette.cyan.shadeDefault, charts.MaterialPalette.deepOrange.shadeDefault, charts.MaterialPalette.lime.shadeDefault];

dynamic genColor(int i){
  return colors[i % colors.length];
}


class ChartsScreen extends StatefulWidget {
  final Diary diary;
  const ChartsScreen(this.diary, {Key? key}) : super(key: key);

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<bool> showTracker = [];
  List<PointOnLine> trackerList = [];
  DateTime? firstDate;
  DateTime? lastDate;
  String? changeRange;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    if(firstDate == null){
      firstDate =  widget.diary.entries.first.createdAt;
      lastDate = widget.diary.entries.last.createdAt;
      changeRange = tr.changeDateRange;
    }
    List<charts.Series<dynamic, DateTime>> listSeries = [];
    Map<String, List> data = {};

    for (Entry entry in widget.diary.entries){
      if(entry.other.containsKey("tracking") && firstDate!.compareTo(entry.createdAt) != 1 && lastDate!.compareTo(entry.createdAt.add(const Duration(days: -1))) != -1){
        for(Map tracker in entry.other["tracking"]){
          if(!data.containsKey(tracker["type"] + ":" + tracker["title"])){
            data[tracker["type"] + ":" + tracker["title"]] = [];
          }
          data[tracker["type"] + ":" + tracker["title"]]!.add([tracker, entry]);
        }
      }
    }

    int i = 0;
    for(String key in data.keys){
      List<PointOnLine> dt = [];
      for(List item in data[key]!){
        if(item[0]["type"] == "number"){
          dt.add(
            PointOnLine(item[1].createdAt, key, i, item[0]["title"], double.parse(item[0]["value"]))
          );
        }

        if(item[0]["type"] == "slider"){
          dt.add(
            PointOnLine(item[1].createdAt, key, i, item[0]["title"], double.parse(item[0]["value"].toString()))
          );
        }
      }

      if(dt.isNotEmpty){
        if(showTracker.isEmpty){
          listSeries.add(
            charts.Series(
              id: key,
              colorFn: (a, _) {
                return genColor(a.trackID);
              },
              domainFn: (point, _) => point!.time,
              measureFn: (point, _) => point!.value,
              data: dt,
            ),
          );
        }
        else if(showTracker[i]){
          listSeries.add(
            charts.Series(
              id: key,
              colorFn: (a, _) {
                return genColor(a.trackID);
              },
              domainFn: (point, _) => point!.time,
              measureFn: (point, _) => point!.value,
              data: dt,
            ),
          );
        }
        i += 1;
      }
    }

    if(showTracker.isEmpty){
      for(int i = 0; i < listSeries.length; ++i){
        showTracker.add(true);
        trackerList.add(listSeries[i].data[0]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.charts),
      ),

      body: ListView(
        children: [
          SizedBox(
            height: 300.0,
            child: charts.TimeSeriesChart(
              animate: false,
              listSeries,
              defaultRenderer: charts.LineRendererConfig(),
              customSeriesRenderers: [
                charts.PointRendererConfig(
                  customRendererId: 'customPoint'
                )
              ],
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            )
          ),


          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                DateTimeRange? range = await showDateRangePicker(
                  context: context,
                  firstDate: widget.diary.entries.first.createdAt,
                  lastDate: widget.diary.entries.last.createdAt,
                  initialEntryMode: DatePickerEntryMode.input,
                  initialDateRange: DateTimeRange(start: firstDate!, end: lastDate!),
                  currentDate: DateTime.now(),
                );

                if(range != null){
                  setState(() {
                    firstDate = range.start;
                    lastDate = range.end;

                    changeRange = "${DateFormat(tr.dateFormat, tr.localeName).format(firstDate!)} ${tr.toLower} ${DateFormat(tr.dateFormat, tr.localeName).format(lastDate!)}";
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(changeRange!),
            ),
          ),

          const SizedBox(height: 18.0),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trackerList.length,
            itemBuilder: (context, index){
              return ListTile(
                leading: Center(
                  widthFactor: 1.0,
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: [Colors.blue, Colors.red, Colors.green, Colors.cyan, Colors.deepOrange, Colors.lime][trackerList[index].trackID % 6],
                    ),
                  ),
                ),
                title: Text(trackerList[index].title),

                trailing: Switch(
                  value: showTracker[index],
                  onChanged: (newValue){
                    setState(() {
                      showTracker[index] = newValue;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}