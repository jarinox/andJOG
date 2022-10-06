import 'package:andjog/screens/licenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.about),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 126.0,
                height: 126.0,
                child: Image.asset("assets/vgcenter.png", width: 126.0,)
              ),

              Text(tr.copyright,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12.0),

              OutlinedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LicensesScreen())
                  );
                },
                child: Text(tr.openSourceLibraries)
              ),

              OutlinedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GPLLicenseScreen())
                  );
                },
                child: const Text("GNU General Public License Version 3")
              ),
            ],
          ),
        ),
      ),
    );
  }
}