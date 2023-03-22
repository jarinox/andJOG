import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/jog_utils.dart';
import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/about.dart';
import 'package:andjog/screens/charts_refactored.dart';
import 'package:andjog/screens/edit_entry.dart';
import 'package:andjog/screens/settings.dart';
import 'package:andjog/screens/start.dart';
import 'package:andjog/screens/viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomeScreen extends StatefulWidget {
  final Diary diary;
  final Settings settings;
  const HomeScreen(this.diary, this.settings, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey calendarKey = GlobalKey();

  int _appBarIndex = 0;
  late Diary diary;
  late Settings settings;

  double maxHeight = 350;

  ScrollController scMain = ScrollController();
  TextEditingController tecSearch = TextEditingController();

  bool showCalendar = false;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  SearchFilter searchFilter = SearchFilter();
  List<Entry> filteredEntries = [];
  List<Entry> selectedEntries = [];

  int maxLength = 20;
  bool showIndicator = false;

  void updateFilteredEntries(){
    filteredEntries = diary.filter(searchFilter, maxLength: maxLength);
  }

  @override
  void initState() {
    diary = widget.diary;
    settings = widget.settings;
    updateFilteredEntries();
    
    
    scMain.addListener(_onScroll);
    
    super.initState();
  }

  @override
  void dispose() {
    tecSearch.dispose();
    scMain.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scMain.offset >=
        scMain.position.maxScrollExtent &&
        !scMain.position.outOfRange) {
      if(maxLength <= diary.entries.length){
        setState(() {
          showIndicator = true;
        });
        maxLength += 20;
        setState(() {
          updateFilteredEntries();
        });
        setState(() {
          showIndicator = false;
        });
      }
    }
  }

  void confirmDeleteEntries(BuildContext context){
    final tr = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr.warning),
        content: selectedEntries.length == 1 ? Text(tr.confirmDeleteEntry) : Text(tr.confirmDeleteEntries),

        actions: [
          TextButton(
            onPressed: () async {
              for(Entry e in selectedEntries){
                for(String hash in e.other['images']){
                  await deleteFileFromMedia(hash);
                }
                diary.entries.remove(e);
              }

              await saveDiary(diary);
              setState(() {
                updateFilteredEntries();  
                selectedEntries.clear();
              });

              if(!mounted) return;
              Navigator.of(context).pop();
            },
            child: Text(tr.yes),
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text(tr.no),
          ),
        ],
      ),
    );
  }

  void newEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EntryEditorScreen(diary, -1)
      )
    );

    Diary? d = await loadDiary(diary.name, diary.password);

    if(d != null){
      diary = d;
      setState(() {
        updateFilteredEntries();
      });
    }
  }

  List<Entry> _getEntriesForDay(DateTime day){
    return diary.entries.where((entry) => isSameDay(day, entry.createdAt)).toList();
  }

  void updateHeight() async {
    setState(() {
      maxHeight = calendarKey.currentContext!.size!.height;
      if(maxHeight < 300){
        maxHeight = 300;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    Future.microtask(updateHeight);


    return Scaffold(
      appBar: [
        selectedEntries.isEmpty ? AppBar(
          title: Text(tr.diary),

          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _appBarIndex = 1;
                });
              },
              tooltip: tr.search,
              icon: const Icon(Icons.search),
            ),

            IconButton(
              onPressed: () {
                if(showCalendar){
                    searchFilter.date = null;
                    selectedDay = null;
                  }
                setState(() {
                  updateFilteredEntries();
                  showCalendar = !showCalendar;
                });
              },
              tooltip: showCalendar ? tr.hideCalendar : tr.showCalendar,
              icon: showCalendar ? const Icon(Icons.list) : const Icon(Icons.calendar_today),
            ),

            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChartsScreen(diary))
                );
              },
              tooltip: "${tr.charts} (beta)",
              icon: const Icon(Icons.line_axis),
            ),

            PopupMenuButton(
              onSelected: (value) async {
                if(value == 1){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsScreen(diary, settings))
                  );
                } else if(value == 0){
                  newEntry();
                } else if(value == 2){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AboutScreen())
                  );
                } else if(value == 3){
                  await saveDiary(diary);
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const StartScreen()), (route) => false
                  );
                }
              },

              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  value: 0,
                  child: Text(tr.newEntry),
                ),

                PopupMenuItem(
                  value: 1,
                  child: Text(tr.settings),
                ),

                PopupMenuItem(
                  value: 2,
                  child: Text(tr.about),
                ),

                PopupMenuItem(
                  value: 3,
                  child: Text(tr.lock),
                ),
              ],
            ),
          ],
        )
        
        :
        
        AppBar(
          title: selectedEntries.length == 1 ? Text("1 ${tr.entrySelected}") : Text("${selectedEntries.length} ${tr.entriesSelected}"),

          actions: [
            selectedEntries.length == 1 ? IconButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EntryEditorScreen(diary, diary.entries.indexOf(selectedEntries[0]))
                  )
                );

                selectedEntries.clear();

                Diary? d = await loadDiary(diary.name, diary.password);

                if(d != null){
                  diary = d;
                  setState(() {
                    updateFilteredEntries();
                  });
                }
              },
              tooltip: tr.edit,
              icon: const Icon(Icons.edit)
            ) : const SizedBox(),

            IconButton(
              onPressed: (){
                confirmDeleteEntries(context);
              },
              tooltip: tr.delete,
              icon: const Icon(Icons.delete)
            ),

            IconButton(
              onPressed: (){
                setState(() {
                  selectedEntries.clear();
                });
              },
              tooltip: tr.deselect,
              icon: const Icon(Icons.close)
            ),
          ],
        ),
      

        AppBar(
          title: TextField(
            controller: tecSearch,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: const Icon(Icons.search, color: Colors.white,),
              hintText: "${tr.search}...",
              border: InputBorder.none
            ),

            onChanged: (String text){
              searchFilter.text = text;
              setState(() {
                updateFilteredEntries();
              });
            },
          ),

          actions: [
            IconButton(onPressed: (){
              tecSearch.text = "";
              setState(() {
                searchFilter.text = null;
                _appBarIndex = 0;
                updateFilteredEntries();
              });
            }, icon: const Icon(Icons.close))
          ],
        ),
      ][_appBarIndex],


      // body
      body: ListView(
        controller: scMain,
        children: [
          showIndicator ? const LinearProgressIndicator(value: null) : const SizedBox(),

          AnimatedContainer( // Calendar
            height: showCalendar ? maxHeight : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                TableCalendar(
                  key: calendarKey,
                  locale: tr.localeName,
                  availableCalendarFormats: const {CalendarFormat.month: "month"},
                  startingDayOfWeek: {
                    "mon": StartingDayOfWeek.monday,
                    "tue": StartingDayOfWeek.tuesday,
                    "wed": StartingDayOfWeek.wednesday,
                    "thu": StartingDayOfWeek.thursday,
                    "fri": StartingDayOfWeek.friday,
                    "sat": StartingDayOfWeek.saturday,
                    "sun": StartingDayOfWeek.sunday,
                  }[settings.firstDay]!,
                  focusedDay: focusedDay,
                  firstDay: DateTime.utc(1980, 1, 1),
                  lastDay: DateTime.utc(2100, 1, 1),

                  eventLoader: _getEntriesForDay,

                  selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                  onPageChanged: (focused){ focusedDay = focused; },
                  onDaySelected: (selected, focused){
                    searchFilter.date = selected;
                    setState(() {
                      updateFilteredEntries();
                      selectedDay = selected;
                      focusedDay = focused;
                    });
                  },

                  calendarBuilders: CalendarBuilders(
                    singleMarkerBuilder:(context, day, Entry event) {
                      return Container(
                        width: 5.0,
                        height: 5.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: categoryColor(event.category),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),



          filteredEntries.isNotEmpty ? ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 4.0,),
            itemCount: filteredEntries.length,
            itemBuilder: (BuildContext context, int index){
              Entry entry = filteredEntries[index];
              bool isSelected = selectedEntries.contains(entry);

              return ListTile(
                leading: SizedBox(
                  height: 40.0,
                  width: 40.0,
                  child: Column(
                    children: [
                      Text(entry.createdAt.day.toString(), style: const TextStyle(fontSize: 20)),
                      Text(
                        DateFormat("MMM", tr.localeName).format(entry.createdAt),
                        style: const TextStyle(fontSize: 14)
                      ),
                    ],
                  ),
                ),

                title: Text(entry.text, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateFormat("EEEE, ${tr.dateFormat}", tr.localeName).format(entry.createdAt)),
                selected: isSelected,

                onTap: (){
                  if(selectedEntries.isEmpty){
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ViewerScreen(diary, entry))
                    );
                  } else {
                    if(isSelected){
                      setState(() {
                        selectedEntries.remove(entry);
                      });
                    } else {
                      setState(() {
                        selectedEntries.add(entry);
                      });
                    }
                  }
                },
                onLongPress: (){
                  if(!isSelected){
                    setState(() {
                      selectedEntries.add(entry);
                    });
                  }
                },
              );
            },
          )
          
          : 
          
          SizedBox(
            height: 70.0,
            child: Center(
              child: Text(tr.noEntriesFound),
            ),
          ),

        ],
      ),



      floatingActionButton: FloatingActionButton(
        onPressed: newEntry,
        tooltip: tr.newEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
