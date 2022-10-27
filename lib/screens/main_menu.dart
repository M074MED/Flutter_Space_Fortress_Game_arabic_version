import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:space_fortress/screens/game_play.dart';
import 'package:space_fortress/screens/settings_menu.dart';

String getRandomChar() {
  return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split("")[Random().nextInt(25)];
}

String firstChar = getRandomChar();
String secondChar = getRandomChar();
String thirdChar = getRandomChar();

List<String> foeMinesCode = [
  firstChar,
  secondChar == firstChar ? getRandomChar() : secondChar,
  thirdChar == firstChar || thirdChar == secondChar
      ? getRandomChar()
      : thirdChar
];

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                "Space Fortress",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
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
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GamePlay(),
                    ),
                  );
                },
                child: const Text(
                  "Play",
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsMenu(),
                    ),
                  );
                },
                child: const Text(
                  "Options",
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "The code of foe mines is\n${foeMinesCode.join(",")}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
