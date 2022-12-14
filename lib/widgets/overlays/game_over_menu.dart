import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:space_fortress/game/game.dart';
import 'package:space_fortress/screens/main_menu.dart';
import 'package:space_fortress/widgets/overlays/pause_button.dart';


class GameOverMenu extends StatelessWidget {
  static const String id = "GameOverMenu";
  final SpaceFortressGame gameRef;

  const GameOverMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            child: Directionality(
                        textDirection: TextDirection.rtl,
              child: Text(
                "انتهت اللعبة",
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
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameOverMenu.id);
                gameRef.overlays.add(PauseButton.id);
                gameRef.reset();
                gameRef.resumeEngine();
              },
              child: const Directionality(
                        textDirection: TextDirection.rtl,
                child: Text(
                  "اعادة التشغيل",
                ),
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
                gameRef.overlays.remove(GameOverMenu.id);
                gameRef.resumeEngine();
                gameRef.reset();
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainMenu(),
                  ),
                );
              },
              child: const Directionality(
                        textDirection: TextDirection.rtl,
                child: Text(
                  "خروج",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
