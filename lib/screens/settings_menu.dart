import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:space_fortress/game/settings.dart';

Settings settings = Settings();

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "الاعدادات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.0,
                    shadows: [
                      Shadow(
                        blurRadius: 40.0,
                        color: Colors.white,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SwitchListTile(
                  title: const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text("المؤثرات الصوتية")),
                  value: settings.soundEffects,
                  onChanged: (newValue) {
                    setState(() {
                      settings.soundEffects = newValue;
                    });
                  }),
            ),
            // SwitchListTile(
            //     title: const Text("Background Music"),
            //     value: settings.backgroundMusic,
            //     onChanged: (newValue) {
            //       setState(() {
            //         settings.backgroundMusic = newValue;
            //       });
            //     }),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.arrow_back)),
            ),
          ],
        ),
      ),
    );
  }
}
