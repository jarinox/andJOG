import 'package:andjog/jog/settings.dart';
import 'package:andjog/screens/initial.dart';
import 'package:andjog/screens/start.dart';
import 'package:flutter/material.dart';
import 'package:andjog/jog/fio.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> startup(BuildContext context) async {
    Settings settings = await loadSettings();

    if(!mounted) return;
    if(settings.recentlyUsed.isEmpty){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InitialScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StartScreen()),
      );
    }
  } 

  @override
  void initState() {
    super.initState();
    startup(context);
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/vgcenter.png",
          width: 126.0
        ),
      ),
    );
  }
}