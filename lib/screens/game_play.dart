import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:space_fortress/game/game.dart';
import 'package:space_fortress/widgets/overlays/game_over_menu.dart';
import 'package:space_fortress/widgets/overlays/pause_button.dart';
import 'package:space_fortress/widgets/overlays/pause_menu.dart';

SpaceFortressGame _spacescape = SpaceFortressGame();

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: GameWidget(
          game: _spacescape,
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpaceFortressGame gameRef) =>
                PauseButton(gameRef: gameRef,),
            PauseMenu.id: (BuildContext context, SpaceFortressGame gameRef) =>
                PauseMenu(gameRef: gameRef,),
            GameOverMenu.id: (BuildContext context, SpaceFortressGame gameRef) =>
                GameOverMenu(gameRef: gameRef,),
          },
        ),
      ),
    );
  }
}
