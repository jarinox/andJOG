import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/home.dart';
import 'package:andjog/screens/initial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:local_auth/local_auth.dart';


class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _formPwd = GlobalKey<FormState>();
  TextEditingController tecPassword = TextEditingController();

  bool cantOpen = false;

  void unlockDiary(BuildContext context) async {
    if(_formPwd.currentState!.validate()){
      Settings settings = await loadSettings();
      Diary? diary = await loadDiary(settings.recentlyUsed.last, tecPassword.text);

      if(diary != null){
        if(!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(diary, settings))
        );
      } else {
        cantOpen = true;
        _formPwd.currentState!.validate();
        cantOpen = false;
      }
    }
  }

  Future _checkFingerprint() async {
    final tr = AppLocalizations.of(context)!;
    Settings settings = await loadSettings();
    if(!settings.fingerprint) return;
    if(!settings.passwords.containsKey(settings.recentlyUsed.last)) return;

    final LocalAuthentication auth = LocalAuthentication();
    
    try {
      bool permission = await auth.authenticate(localizedReason: tr.unlockDiary, options: const AuthenticationOptions(biometricOnly: true));
      if(permission){
        tecPassword.text = settings.passwords[settings.recentlyUsed.last]!;

        if(!mounted) return;
        unlockDiary(context);
      }
    } on PlatformException catch (e) {
      debugPrint(e.code);
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), _checkFingerprint);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.diary),
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          constraints: const BoxConstraints(maxWidth: 600.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formPwd,
                child: TextFormField(
                  controller: tecPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    labelText: tr.password,
                    border: const UnderlineInputBorder()
                  ),
                  validator: (String? value){
                    if(cantOpen){
                      return tr.failed;
                    } else if (value == null || value.isEmpty){
                      return tr.pleaseEnterYourPassword;
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 10.0),

              ElevatedButton(
                onPressed: () {
                  unlockDiary(context);
                },
                child: Text(tr.unlock),
              ),

              const SizedBox(height: 20.0),

              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InitialScreen()),
                  );
                },
                child: Text(tr.moreOptions),
              ),
            ],
          ),
        ),
      ),
    );
  }
}