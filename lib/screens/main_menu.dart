import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:space_fortress/init.dart';
import 'package:space_fortress/screens/game_play.dart';
import 'package:space_fortress/screens/settings_menu.dart';
import 'package:space_fortress/widgets/snack_bar.dart';

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

final usernameInput = TextEditingController();

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  void initState() {
    super.initState();
    InitApp.initializeApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0),
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
                height: 40,
                child: TextField(
                  decoration: const InputDecoration(
                    iconColor: Colors.white,
                    labelText: 'Enter Username',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  controller: usernameInput,
                  style: const TextStyle(
                    fontFamily: "",
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    if (usernameInput.text == "") {
                      showSnackBar(context, "Please Enter a Username!");
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const GamePlay(),
                        ),
                      );
                    }
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
                height: 10,
              ),
              Text(
                "The code of foe mines is\n${foeMinesCode.join(",")}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
