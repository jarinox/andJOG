/*
 *  andJOG - Tagebuch
 *  Copyright 2020-2022 Jakob Stolze <https://github.com/jarinox>
 *  Email: c4ehhehfa@relay.firefox.com
 * 
 *  This file is part of andJOG <https://github.com/jarinox/andJOG>.
 * 
 *  andJOG is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 * 
 *  andJOG is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with andJOG.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  Diese Datei ist Teil von andJOG <https://github.com/jarinox/andJOG>.
 * 
 *  andJOG ist Freie Software: Sie können es unter den Bedingungen
 *  der GNU General Public License, wie von der Free Software Foundation,
 *  Version 3 der Lizenz oder (nach Ihrer Wahl) jeder neueren
 *  veröffentlichten Version, weiter verteilen und/oder modifizieren.
 * 
 *  andJOG wird in der Hoffnung, dass es nützlich sein wird, aber
 *  OHNE JEDE GEWÄHRLEISTUNG, bereitgestellt; sogar ohne die implizite
 *  Gewährleistung der MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK.
 *  Siehe die GNU General Public License für weitere Details.
 * 
 *  Sie sollten eine Kopie der GNU General Public License zusammen mit diesem
 *  Programm erhalten haben. Wenn nicht, siehe <https://www.gnu.org/licenses/>.
 */


import 'package:andjog/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const AndJOG());
}

class AndJOG extends StatelessWidget {
  const AndJOG({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'andJOG',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
        brightness: SchedulerBinding.instance.window.platformBrightness,
        //brightness: Brightness.dark,
        
        primaryColor: Colors.blue,
        primaryColorDark: Colors.blue,

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),

        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith((states) {
            if(states.contains(MaterialState.selected)){
              return Colors.blue;
            } else {
              return Theme.of(context).brightness == Brightness.light ? Colors.grey.shade600 : Colors.white70;
            }
          }),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateColor.resolveWith((states) {
            if(states.contains(MaterialState.selected)){
              return Colors.blue;
            } else {
              return Colors.white70;
            }
          }),

          trackColor: MaterialStateColor.resolveWith((states) {
            if(states.contains(MaterialState.selected)){
              return Colors.blue.shade200;
            } else {
              return Theme.of(context).brightness == Brightness.light ? Colors.grey.shade500 : Colors.grey.shade600;
            }
          }),
        ),
      ),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      home: const SplashScreen(),
    );
  }
}
