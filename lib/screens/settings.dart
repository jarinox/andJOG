import 'dart:io';
import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/categories.dart';
import 'package:andjog/screens/change_password.dart';
import 'package:andjog/screens/config_tracking.dart';
import 'package:andjog/screens/splash.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:local_auth/local_auth.dart';



class SettingsScreen extends StatefulWidget {
  final Diary diary;
  final Settings settings;
  const SettingsScreen(this.diary, this.settings, {Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings settings;

  @override
  void initState() {
    settings = widget.settings;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final LocalAuthentication auth = LocalAuthentication();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.settings),
      ),

      body: ListView(

        children: [
          /*ListTile(
            title: Row(children: [
              Expanded(
                child: Text(tr.theme)
              ),

              DropdownButton(
                underline: const SizedBox(),
                value: settings.colorMode,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  DropdownMenuItem(value: "auto", child: Text(tr.automatic)),
                  DropdownMenuItem(value: "light", child: Text(tr.lightTheme)),
                  DropdownMenuItem(value: "dark", child: Text(tr.darkTheme)),
                ],
                onChanged: (String? item) {
                  setState(() {
                    if(item! == "auto"){}
                    settings.colorMode = item;
                  });
                  widget.settings.colorMode = item!;
                  saveSettings(settings);
                }
              ),
            ]),
          ),

          const Divider(height: 4.0),*/

          ListTile(
            title: Row(children: [
              Expanded(
                child: Text(tr.startingDayOfWeek)
              ),

              DropdownButton(
                underline: const SizedBox(),
                value: settings.firstDay,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: [
                  DropdownMenuItem(value: "mon", child: Text(tr.monday)),
                  DropdownMenuItem(value: "tue", child: Text(tr.tuesday)),
                  DropdownMenuItem(value: "wed", child: Text(tr.wednesday)),
                  DropdownMenuItem(value: "thu", child: Text(tr.thursday)),
                  DropdownMenuItem(value: "fri", child: Text(tr.friday)),
                  DropdownMenuItem(value: "sat", child: Text(tr.saturday)),
                  DropdownMenuItem(value: "sun", child: Text(tr.sunday)),
                ],
                onChanged: (String? item) {
                  setState(() {
                    settings.firstDay = item!;
                  });
                  widget.settings.firstDay = item!;
                  saveSettings(settings);
                }
              ),
            ]),
          ),

          const Divider(height: 4.0),

          ListTile(
            leading: const Icon(Icons.password),
            title: Text(tr.changePassword),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ChangePasswordScreen(widget.diary))
              );
            },
          ),

          const Divider(height: 4.0),

          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: Text(tr.unlockFingerprint),
            //subtitle: Text(tr.unlockFingerprintInfo, overflow: TextOverflow.ellipsisr,),
            value: widget.settings.fingerprint,
            onChanged: (newValue) async {
              if(newValue){
                try {
                  bool permission = await auth.authenticate(localizedReason: tr.enableFingerprint, options: const AuthenticationOptions(biometricOnly: true));
                  if(!permission) return;
                } on PlatformException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr.fingerprintUnavailable),
                    ),
                  );
                  return;
                }
              }

              if(!mounted) return;
              setState(() {
                widget.settings.fingerprint = newValue;
              });

              if(newValue){
                widget.settings.passwords[widget.diary.name] = widget.diary.password;
              } else {
                widget.settings.passwords.remove(widget.diary.name);
              }

              saveSettings(widget.settings);
            },
          ),

          const Divider(height: 4.0),

          ListTile(
            leading: const Icon(Icons.category),
            title: Text(tr.configCategories),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CategoriesScreen(widget.diary))
              );
            },
          ),

          const Divider(height: 4.0),

          SwitchListTile(
            title: Text(tr.enableTracking),
            value: widget.diary.settings["tracking"]["enabled"],
            onChanged: (newValue){
              setState(() {
                widget.diary.settings["tracking"]["enabled"] = newValue;
              });
              saveDiary(widget.diary);
            },
          ),

          ListTile(
            enabled: widget.diary.settings["tracking"]["enabled"],
            leading: const Icon(Icons.track_changes),
            title: Text(tr.configTracking),
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TrackingConfigScreen(widget.diary))
              );
            },
          ),

          const Divider(height: 4.0),

          /* ListTile(
            enabled: false,
            leading: const Icon(Icons.sync),
            title: Text(tr.configWebdav),
            onTap: (){
            },
          ),

          const Divider(height: 4.0), */

          ListTile(
            leading: const Icon(Icons.save_alt),
            title: Text(tr.exportDiary),
            onTap: () async {
              String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
                dialogTitle: tr.selectDirectoryForSave,
              );

              if(selectedDirectory == null) {
                if(!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr.saveDiaryCanceled),
                  ),
                );
              } else {
                try {
                  await saveDiary(widget.diary, directory: selectedDirectory);
                } catch (_) {
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tr.saveDiaryFailed),
                    ),
                  );
                }
              }
            },
          ),

          kDebugMode ? const Divider(height: 4.0) : const SizedBox(),

          kDebugMode ? ListTile(
            leading: const Icon(Icons.warning),
            title: Text(tr.deleteDataDebug),
            onTap: () async {
              final String dir = await appDir;

              for(String diary in settings.recentlyUsed){
                final String path = p.join(dir, "$diary.enc");
                final File f = File(path);
                if(await f.exists()){
                  await f.delete();
                }
              }

              settings.recentlyUsed = [];
              settings.colorMode = "auto";
              settings.firstDay = "mon";
              await saveSettings(settings);
              
              if(!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
            },
          ) : const SizedBox(),

          kDebugMode ? const Divider(height: 4.0) : const SizedBox(),

          kDebugMode ? ListTile(
            leading: const Icon(Icons.factory),
            title: const Text("Entry factory"),
            onTap: () async {
              for(int i = 0; i < 100; ++i){
                widget.diary.addEntry(Entry(
                  1234,
                  0,
                  "This is some sample text",
                  DateTime.now(),
                  [],
                  widget.diary.settings["tracking"]["enabled"] ? {"tracking":widget.diary.settings["tracking"]["quests"]} : {}
                ));
              }

              await saveDiary(widget.diary);
            },
          ) : const SizedBox(),
        ],
      ),
    );
  }
}