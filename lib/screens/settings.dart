import 'dart:io';
import 'dart:math';
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
              DateTime time = DateTime.now();
              for(int i = 0; i < 100; ++i){
                time = time.subtract([const Duration(days: 1), const Duration(days: 1), const Duration(days: 2), const Duration(days: 2), const Duration(days: 3), const Duration(days: 4), const Duration(seconds: 1)][Random().nextInt(7)]);
                widget.diary.addEntry(Entry(
                  1234+i,
                  0,
                  [
                    "Lorem ipsum dolor sit amet consectetur adipiscing elit, urna consequat felis vehicula class ultricies mollis dictumst, aenean non a in donec nulla. Phasellus ante pellentesque erat cum risus consequat imperdiet aliquam, integer placerat et turpis mi eros nec lobortis taciti, vehicula nisl litora tellus ligula porttitor metus.",
                    "Vivamus integer non suscipit taciti mus etiam at primis tempor sagittis sit, euismod libero facilisi aptent elementum felis blandit cursus gravida sociis erat ante, eleifend lectus nullam dapibus netus feugiat curae curabitur est ad. Massa curae fringilla porttitor quam sollicitudin iaculis aptent leo ligula euismod dictumst, orci penatibus mauris eros etiam praesent erat volutpat posuere hac.",
                    "Metus fringilla nec ullamcorper odio aliquam lacinia conubia mauris tempor, etiam ultricies proin quisque lectus sociis id tristique, integer phasellus taciti pretium adipiscing tortor sagittis ligula.",
                    "Mollis pretium lorem primis senectus habitasse lectus scelerisque donec, ultricies tortor suspendisse adipiscing fusce morbi volutpat pellentesque, consectetur mi risus molestie curae malesuada cum. Dignissim lacus convallis massa mauris enim ad mattis magnis senectus montes, mollis taciti phasellus accumsan bibendum semper blandit suspendisse faucibus nibh est, metus lobortis morbi cras magna vivamus per risus fermentum.",
                    "Dapibus imperdiet praesent magnis ridiculus congue gravida curabitur dictum sagittis, enim et magna sit inceptos sodales parturient pharetra mollis, aenean vel nostra tellus commodo pretium sapien sociosqu.",
                    "Dignissim lacus convallis massa mauris enim ad mattis magnis senectus montes, mollis taciti phasellus accumsan bibendum semper blandit suspendisse faucibus nibh est, metus lobortis morbi cras magna vivamus per risus fermentum. Dapibus imperdiet praesent magnis ridiculus congue gravida curabitur dictum sagittis, enim et magna sit inceptos sodales parturient pharetra mollis, aenean vel nostra tellus commodo pretium sapien sociosqu.",
                    "Habitasse magnis mauris rutrum malesuada vivamus porta sit praesent, et ornare justo egestas potenti phasellus cum elementum nisi, molestie nullam tortor blandit felis placerat porttitor. Malesuada elementum ante vestibulum augue vulputate penatibus netus mollis pretium libero, aptent tristique hendrerit accumsan metus arcu viverra ipsum eleifend parturient, dictumst tempus primis interdum sagittis porttitor luctus et suspendisse.",
                    "Cubilia dictum nisl platea id volutpat pretium scelerisque suspendisse velit nisi pulvinar dictumst, gravida potenti penatibus massa suscipit mollis magnis phasellus aptent consequat elit, auctor varius pharetra urna blandit ultrices orci molestie accumsan quam tempor.",
                    "Ante est montes augue faucibus ultrices habitasse penatibus fermentum, eros massa iaculis turpis nisi maecenas venenatis, ad tristique suscipit egestas vestibulum mattis etiam. Diam turpis venenatis ligula condimentum montes, sagittis dis sollicitudin nunc lorem, id consequat duis justo. ",
                    "Vitae vulputate montes non vestibulum tristique sapien hac netus risus, ornare molestie pulvinar sed auctor condimentum metus natoque, neque nisi volutpat fusce lobortis felis tempor magnis.",
                    "Turpis pulvinar mattis in proin dui elementum sit habitasse, penatibus dictum duis convallis ullamcorper egestas fermentum a vehicula, auctor lobortis libero blandit ultrices taciti eu. Habitant euismod aliquam imperdiet purus cum duis in varius mus vivamus sodales enim, vehicula blandit eu iaculis condimentum commodo libero integer nullam senectus cubilia.",
                    "Praesent augue massa placerat nisi nibh mauris sollicitudin mi nisl, nascetur tempor phasellus taciti conubia in aliquet hac vulputate sed, non est dictumst consectetur tempus porta ante sit. Inceptos parturient elit metus nunc scelerisque aliquam laoreet praesent rutrum, sociis ipsum nisi proin cursus faucibus sollicitudin gravida etiam, hendrerit dis tristique erat ornare tortor porttitor tellus.",
                    "Nostra sem magna lorem felis orci risus posuere sagittis litora, facilisi eget ultricies egestas sociosqu montes interdum enim, tristique nunc in nascetur vel accumsan purus placerat. Class nam sagittis pretium quis tristique risus justo nisi penatibus, habitasse semper lectus accumsan sem natoque facilisi augue, molestie nascetur curae nisl vel ornare odio sit. ",
                    "Donec pharetra natoque vehicula fermentum penatibus hendrerit condimentum aenean, vitae magna auctor odio nisi sapien magnis, ut integer hac venenatis eget habitasse mi. "
                  ][Random().nextInt(14)],
                  time,
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