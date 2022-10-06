import 'package:andjog/jog/fio.dart';
import 'package:andjog/jog/jog.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Diary diary;
  const ChangePasswordScreen(this.diary, {Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formPwd = GlobalKey<FormState>();

  TextEditingController tecOld = TextEditingController();
  TextEditingController tecNew = TextEditingController();
  TextEditingController tecNewRepeat = TextEditingController();

  @override
  void dispose() {
    tecOld.dispose();
    tecNew.dispose();
    tecNewRepeat.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;


    return Scaffold(
      appBar: AppBar(
        title: Text(tr.changePassword),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formPwd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: tecOld,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: tr.oldPassword,
                    filled: true,
                  ),
                  
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return tr.pleaseEnterOldPassword;
                    } else if(value != widget.diary.password){
                      return tr.wrongPassword;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8.0,),

                TextFormField(
                  controller: tecNew,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: tr.newPassword,
                    filled: true,
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return tr.pleaseEnterNewPassword;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8.0,),

                TextFormField(
                  controller: tecNewRepeat,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: tr.newPasswordRepeat,
                    filled: true,
                  ),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return tr.pleaseRepeatNewPassword;
                    } else if(tecNew.text != value){
                      return tr.invalidPasswordRepetition;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16.0,),

                ElevatedButton(
                  onPressed: () async {
                    if(_formPwd.currentState!.validate()){
                      widget.diary.password = tecNew.text;
                      await saveDiary(widget.diary);

                      if(!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr.passwordChanged),
                        ),
                      );
                    }
                  },
                  child: Text(tr.changePassword),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}