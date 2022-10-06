import 'dart:io';

import 'package:andjog/screens/start.dart';
import 'package:path/path.dart' as p;
import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/create_new_diary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  Settings settings = Settings("auto", "mon", []);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.welcomeToAndjog),
      ),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/vgcenter.png", width: 126.0,),



              ListTile(
                title: ElevatedButton(
                  onPressed:() {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CreateNewDiaryScreen())
                    );
                  },
                  child: Text(tr.createNewDiary)
                ),
              ),

              ListTile(
                title: OutlinedButton(
                  onPressed:() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null) {
                      settings = await loadSettings();

                      final String ad = await appDir;

                      int i = 0;
                      while(
                        await File(
                          p.join(ad, "diary${i.toString()}.enc")
                        ).exists()
                      ){
                        ++i;
                      }

                      await File(result.files.single.path!).copy(p.join(ad, "diary${i.toString()}.enc"));
                      settings.recentlyUsed.add("diary${i.toString()}");
                      await saveSettings(settings);

                      if(!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const StartScreen()),
                        (route) => false,
                      );
                    } else {
                      if(!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr.noFileSelected),
                        ),
                      );
                    }
                  },
                  child: Text(tr.importFromFile)
                ),
              ),

              /*ListTile(
                title: OutlinedButton(
                  onPressed:() {
                    
                  },
                  child: Text(tr.importFromWebDav)
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}