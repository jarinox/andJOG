import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';


class PointOnLine {
  final DateTime time;
  final String type;
  final String track;
  final String title;
  final num value;
  final int trackID;

  PointOnLine(this.time, this.type, this.track, this.title, this.value, this.trackID);
}

class BooleanTracker {
  final String title;
  final double averageValue;

  BooleanTracker(this.title, this.averageValue);
}

class ChartTracker {
  final String title;
  final List<PointOnLine> points;
  final int id;
  bool show = true;

  ChartTracker(this.title, this.points, this.id);
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
    List<BooleanTracker> booleanTrackers = [];

    Map<String, ChartTracker> chartLines = {};

    int i = 0;
    for (Entry entry in widget.diary.entries){
      if(entry.other.containsKey("tracking") && firstDate!.compareTo(entry.createdAt) != 1 && lastDate!.compareTo(entry.createdAt.add(const Duration(days: -1))) != -1){
        for(Map tracker in entry.other["tracking"]){
          if(!chartLines.containsKey(tracker["type"] + ":" + tracker["title"])){
            chartLines[tracker["type"] + ":" + tracker["title"]] = ChartTracker(tracker["title"], [], i++);
          }

          chartLines[tracker["type"] + ":" + tracker["title"]]!.points.add(
            PointOnLine(
              entry.createdAt,
              tracker["type"],
              tracker["type"] + ":" + tracker["title"],
              tracker["title"],
              tracker["type"] == "bool" ? (tracker["value"] ? 1 : 0) : double.parse(tracker["value"].toString()),
              chartLines[tracker["type"] + ":" + tracker["title"]]!.id,
            )
          );
        }
      }
    }

    List<String> removeKeys = [];

    bool showTrackerEmpty = showTracker.isEmpty;

    i = 0;
    for (String key in chartLines.keys){
      if (chartLines[key]!.points[0].type == "bool"){
        double averageValue = 0;
        for (PointOnLine point in chartLines[key]!.points){
          averageValue += point.value;
        }
        averageValue /= chartLines[key]!.points.length;

        booleanTrackers.add(
          BooleanTracker(
            chartLines[key]!.points[0].title,
            averageValue,
          )
        );

        removeKeys.add(key); // for displaying toggle switches only for chart lines
        continue;
      }

      if (showTrackerEmpty) showTracker.add(true);

      if(showTracker[i] == false){
        i++;
        continue;
      }

      listSeries.add(
        charts.Series<PointOnLine, DateTime>(
          id: key,
          colorFn: (a, _) => genColor(a.trackID),
          domainFn: (PointOnLine point, _) => point.time,
          measureFn: (PointOnLine point, _) => point.value,
          data: chartLines[key]!.points,
        )
      );

      i++;
    }

    for (String key in removeKeys){
      chartLines.remove(key);
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
            itemCount: chartLines.length,
            itemBuilder: (context, index){
              ChartTracker tracker = chartLines.values.toList()[index];
              return ListTile(
                leading: Center(
                  widthFactor: 1.0,
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: [Colors.blue, Colors.red, Colors.green, Colors.cyan, Colors.deepOrange, Colors.lime][tracker.id % 6],
                    ),
                  ),
                ),
                title: Text(tracker.title),

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

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: booleanTrackers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Center(
                  widthFactor: 1.0,
                  child: Container(
                    width: 34.0,
                    height: 16.0,
                    child: Text("${(booleanTrackers[index].averageValue*100).toStringAsFixed(0)} %"),
                  ),
                ),
                title: Text(booleanTrackers[index].title),
              );              
            },
          ),
        ],
      ),
    );
  }

}
