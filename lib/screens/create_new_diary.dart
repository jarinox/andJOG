import 'dart:io';
import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/start.dart';
import 'package:path/path.dart' as p;
import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class CreateNewDiaryScreen extends StatefulWidget {
  const CreateNewDiaryScreen({Key? key}) : super(key: key);

  @override
  State<CreateNewDiaryScreen> createState() => _CreateNewDiaryScreenState();
}

class PadTile extends Padding {
  const PadTile(
    Widget child,
    {Key? key, EdgeInsets padding = const EdgeInsets.symmetric(
      vertical: 6.0,
      horizontal: 16.0
    ),}
  ) : super(
    key: key, 
    padding: padding,
    child: child,
  );
}

class _CreateNewDiaryScreenState extends State<CreateNewDiaryScreen> {
  final _formPwdKey = GlobalKey<FormState>();
  final _formWebDavKey = GlobalKey<FormState>();
  int _stepIndex = 0;

  TextEditingController tecPassword = TextEditingController();
  TextEditingController tecPasswordRepeat = TextEditingController();
  TextEditingController tecWebDavUrl = TextEditingController();
  TextEditingController tecStandardCategory = TextEditingController(text: "personal");

  bool _useSync = false;


  void createDiary(BuildContext context) async {
    final String ad = await appDir;

    int i = 0;
    while(
      await File(
        p.join(ad, "diary${i.toString()}.enc")
      ).exists()
    ){
      ++i;
    }

    final Diary diary = Diary("diary${i.toString()}", tecPassword.text, [tecStandardCategory.text], [], {
      "tracking": {
        "enabled": false,
        "quests": [],
      },
    });

    await saveDiary(diary);
    Settings settings = await loadSettings();
    settings.recentlyUsed.add("diary${i.toString()}");
    await saveSettings(settings);
    
    if(!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false
    );
  }


  @override
  void dispose() {
    tecPassword.dispose();
    tecPasswordRepeat.dispose();
    tecWebDavUrl.dispose();
    tecStandardCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.newDiary),
      ),

      body: Stepper(
        currentStep: _stepIndex,
        onStepContinue: (){
          if(_stepIndex == 0){
            if(_formPwdKey.currentState!.validate()){
              setState(() {
                _stepIndex++;
              });
            }
          }/* else if(_stepIndex == 1){
            if(!_useSync || _formWebDavKey.currentState!.validate()){
              setState(() {
                _stepIndex++;
              });
            }
          }*/ else if(_stepIndex == 1){
            createDiary(context);
          }
        },
        onStepTapped: (int index){
          if(index < _stepIndex){
            setState(() {
              _stepIndex = index;
            });
          }
        },
        onStepCancel: (){
          Navigator.of(context).pop();
        },
        steps: <Step>[
          Step(
            title: Text(tr.setPassword),
            content: Form(
              key: _formPwdKey,
              child: Column(
                children: [
                  Text(tr.setPasswordDescribtion),

                  Container(height: 14.0,),

                  TextFormField(
                    controller: tecPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: tr.password,
                      border: const UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return tr.pleaseEnterAPassword;
                      }
                      return null;
                    },
                  ),
                
                  const SizedBox(height: 10.0,),
                
                  TextFormField(
                    controller: tecPasswordRepeat,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: tr.passwordRepeat,
                      border: const UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return tr.pleaseRepeatYourPassword;
                      } else if (value != tecPassword.text){
                        return tr.invalidPasswordRepetition;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),

          /*Step(
            title: const Text("Synchronisation einrichten (optional)"),
            content: Form(
              key: _formWebDavKey,
              child: Column(
                children: [
                  const Text("Sie können mithilfe eines WebDav Servers (z.B. Nextcloud) das verschlüsselte Tagebuch zwischen mehreren Geräten synchronisieren."),
                  SwitchListTile(
                    title: const Text("WebDav Synchronisation"),
                    value: _useSync,
                    onChanged: (bool newValue){
                      setState(() {
                        _useSync = newValue;
                      });
                    }
                  ),
            
                  const SizedBox(height: 10.0),
            
                  TextFormField(
                    controller: tecWebDavUrl,
                    enabled: _useSync,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "URL",
                      border: UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "Bitte geben Sie eine URL an.";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10.0),
            
                  TextFormField(
                    controller: tecWebDavUrl,
                    enabled: _useSync,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Benutzername",
                      border: UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "Bitte geben Sie einen Benutzernamen an.";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10.0),

                  TextFormField(
                    controller: tecWebDavUrl,
                    enabled: _useSync,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Passwort",
                      border: UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "Bitte geben Sie Ihr Passwort an.";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10.0),

                  TextFormField(
                    controller: tecWebDavUrl,
                    enabled: _useSync,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: "Dateipfad",
                      border: UnderlineInputBorder()
                    ),
                    validator: (value) {
                      if(value == null || value.isEmpty){
                        return "Bitte geben Sie den Dateipfad an.";
                      }
                      return null;
                    },
                  ),
            
                ],
              ),
            ),
          ),*/

          Step(
            title: Text(tr.defaultCategory),
            content: Column(
              children: [
                Text(tr.categoriesDescription),

                const SizedBox(height: 12.0),

                TextField(
                  controller: tecStandardCategory,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: tr.defaultCategory,
                  ),
                ),

                const SizedBox(height: 36.0),

                Text(tr.clickContinueToCreateDiary),
              ],
            ),
          ),
        ]
      ),
                
    );
  }
}