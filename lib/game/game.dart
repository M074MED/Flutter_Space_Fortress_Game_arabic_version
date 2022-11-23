import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/audio_player_component.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/command.dart';
import 'package:space_fortress/game/fortress_fire_manager.dart';
import 'package:space_fortress/game/fortress.dart';
import 'package:space_fortress/game/move_buttons.dart';
import 'package:space_fortress/game/player.dart';
import 'package:space_fortress/models/sessions.dart';
import 'package:space_fortress/screens/main_menu.dart';
import 'package:space_fortress/widgets/overlays/game_over_menu.dart';
import 'package:space_fortress/widgets/overlays/pause_button.dart';
import 'package:space_fortress/widgets/overlays/pause_menu.dart';
import 'package:backendless_sdk/backendless_sdk.dart' as bkl;

import 'mine.dart';
import 'package:collection/collection.dart';

class SpaceFortressGame extends FlameGame
    with HasTappables, HasCollisionDetection, HasDraggables {
  late SpriteSheet spriteSheet;
  late Player player;
  Vector2 playerPosition = Vector2(180, 130);
  late Fortress fortress;
  late Mine mine;
  int foeMineFinish = 0;
  List<DateTime> foeMinefinishDecreaseTime = [];
  List<String> bonuses = [];
  bool bonusToked = false;
  late FortressFireManager _fortressFireManager;
  late JoystickComponent joystick;
  late TextComponent _playerPoints;
  late TextComponent _playerShots;
  late TextComponent _velocityScore;
  late TextComponent _mineCode;
  late TextComponent _bonus;
  late TextComponent _controlScore;
  // late TextComponent _playerHealth;
  late AudioPlayerComponent _audioPlayerComponent;
  late PolygonComponent outerHexagonShape;
  late PolygonComponent innerHexagonShape;
  bool _isAlreadyLoaded = false;
  bool playerRemoved = false;
  bool fortressRemoved = false;
  bool inOuterHexagon = false;
  bool inInnerHexagon = false;
  bool outOfHexagons = false;
  bool mineOnScreen = false;
  int frameCounter = 0;
  int playerDeathTimes = 0;

  // Backend Data Variables
  int playerPoints = 0;
  int velocityScore = 0;
  int controlScore = 0;
  int playerShots = 100;
  String bonus = "";
  int shipDamageByFortress = 0;
  int fortressDestruction = 0;
  int shipDamageByMine = 0;
  int fortressHitByMissile = 0;
  int bonusTaken = 0; // TODO: Implementation Not Found
  List<DateTime> fireTimes = [];
  double fireAverage = 0;
  List<int> foeMineLoadAndPlayerActTimesDiff = [];
  double foeMineLoadAndPlayerActTimesDiffAverage = 0;
  List<int> friendlyMineLoadAndPlayerActTimesDiff = [];
  double friendlyMineLoadAndPlayerActTimesDiffAverage = 0;
  double totalPlayerDistance = 0;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  @override
  Future<void> onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.loadAll(["simpleSpace_tilesheet@2.png", "joystick.png"]);

      _audioPlayerComponent = AudioPlayerComponent();
      add(_audioPlayerComponent);

      ParallaxComponent _background = await ParallaxComponent.load(
        [
          ParallaxImageData("background/stars1.png"),
          ParallaxImageData("background/stars2.png"),
        ],
        repeat: ImageRepeat.repeat,
        // baseVelocity: Vector2(0, -50),
        // velocityMultiplierDelta: Vector2(0, 1.5),
      );
      add(_background);

      spriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache("simpleSpace_tilesheet@2.png"),
          columns: 8,
          rows: 6);

      player = Player(
        sprite: spriteSheet.getSpriteById(4),
        size: Vector2(50, 50),
        position: playerPosition,
      );
      player.anchor = Anchor.center;
      add(player);

      fortress = Fortress(
        sprite: spriteSheet.getSpriteById(37),
        size: Vector2(70, 70),
        position: size / 2,
      );
      fortress.anchor = Anchor.center;
      add(fortress);

      _fortressFireManager = FortressFireManager(spriteSheet: spriteSheet);
      add(_fortressFireManager);

      final controllersSpriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache("joystick.png"), columns: 6, rows: 1);

      // joystick = JoystickComponent(
      //   knob: SpriteComponent(
      //     sprite: controllersSpriteSheet.getSpriteById(1),
      //     size: Vector2.all(100),
      //   ),
      //   background: SpriteComponent(
      //     sprite: controllersSpriteSheet.getSpriteById(0),
      //     size: Vector2.all(100),
      //   ),
      //   margin: const EdgeInsets.only(left: 40, bottom: 40),
      // );
      // add(joystick);

      final fireButton = HudButtonComponent(
        button: SpriteComponent(
          sprite: controllersSpriteSheet.getSpriteById(2),
          size: Vector2.all(80),
        ),
        buttonDown: SpriteComponent(
          sprite: controllersSpriteSheet.getSpriteById(4),
          size: Vector2.all(80),
        ),
        margin: const EdgeInsets.only(
          right: 40,
          bottom: 50,
        ),
        onPressed: () {
          if (mineOnScreen) {
            player.canShoot = !mine.isFoe;
          } else {
            player.canShoot = true;
          }
          if (player.canShoot) {
            Bullet bullet = Bullet(
              name: "playerBullet",
              sprite: spriteSheet.getSpriteById(28),
              size: Vector2(64, 64),
              position: player.position.clone(),
              playerAngle: player.angle,
            );
            bullet.anchor = Anchor.center;
            add(bullet);
            playerShots -= 1;
            if (playerShots < 0) {
              playerShots = 0;
              playerPoints -= 3;
            }
            _audioPlayerComponent.playSfx("laserSmall.ogg");

            fireTimes.add(DateTime.now());
            List<int> fireTimesDiff = [];
            if (fireTimes.length >= 2) {
              for (var i = 0; i < fireTimes.length - 1; i++) {
                fireTimesDiff.add(fireTimes[i + 1]
                    .difference(fireTimes[i])
                    .inMilliseconds
                    .abs());
              }
              fireAverage = fireTimesDiff.average;
              print("fireAverage $fireAverage");
            }

            calcMineLoadAndPlayerActTimesDiffAverage();
          } else if (mine.isFoe) {
            if (foeMineFinish < 2) {
              if (foeMinefinishDecreaseTime.isEmpty) {
                foeMineFinish += 1;
              }
              foeMinefinishDecreaseTime.add(DateTime.now());
              if (foeMinefinishDecreaseTime.length >= 2) {
                if (foeMinefinishDecreaseTime[
                            foeMinefinishDecreaseTime.length - 1]
                        .difference(foeMinefinishDecreaseTime[
                            foeMinefinishDecreaseTime.length - 2])
                        .inMilliseconds <
                    250) {
                  foeMineFinish += 1;
                  if (foeMineFinish == 2) {
                    playerPoints += 30;
                    if (inOuterHexagon || inInnerHexagon) {
                      controlScore += 30;
                    } else if (outOfHexagons) {
                      controlScore += (30 * 0.5).toInt();
                    }
                    mine.destroy();
                  }
                } else {
                  foeMineFinish = 0;
                  foeMinefinishDecreaseTime.clear();
                }
              }
            }
            calcMineLoadAndPlayerActTimesDiffAverage();
          }
        },
      );
      add(fireButton);

      MoveButtons moveButton = MoveButtons(
        sprite: spriteSheet.getSpriteById(0),
        position: Vector2(80, size.y - 110),
        size: Vector2(64, 64),
        onTDown: () {
          // player.moveAngel =
          //     Vector2(sin(player.angle), -cos(player.angle)).clone();
          player.move = true;

          final double newAngle = player.angle;
          if (newAngle >= 0 && newAngle < pi / 2) {
            player.newAngleDir = 0;
          } else if (newAngle >= pi / 2 && newAngle < pi) {
            player.newAngleDir = 1;
          } else if (newAngle >= pi && newAngle < (3 * pi) / 2) {
            player.newAngleDir = 2;
          } else if (newAngle >= (3 * pi) / 2 && newAngle < 2 * pi) {
            player.newAngleDir = 3;
          }
          player.onTurbo = true;

          calcMineLoadAndPlayerActTimesDiffAverage();
        },
        onTUp: () {
          final double oldAngle = player.angle;
          if (oldAngle >= 0 && oldAngle < pi / 2) {
            player.oldAngleDir = 0;
          } else if (oldAngle >= pi / 2 && oldAngle < pi) {
            player.oldAngleDir = 1;
          } else if (oldAngle >= pi && oldAngle < (3 * pi) / 2) {
            player.oldAngleDir = 2;
          } else if (oldAngle >= (3 * pi) / 2 && oldAngle < 2 * pi) {
            player.oldAngleDir = 3;
          }
          player.onTurbo = false;
        },
      );
      add(moveButton);

      MoveButtons rotateRightButton = MoveButtons(
        sprite: spriteSheet.getSpriteById(0),
        position: Vector2(120, size.y - 70),
        size: Vector2(64, 64),
        onTDown: () {
          player.rotateRight = true;

          calcMineLoadAndPlayerActTimesDiffAverage();
        },
        onTUp: () {
          player.rotateRight = false;
        },
      );
      rotateRightButton.angle = -4.7;
      add(rotateRightButton);

      MoveButtons rotateLeftButton = MoveButtons(
        sprite: spriteSheet.getSpriteById(0),
        position: Vector2(40, size.y - 70),
        size: Vector2(64, 64),
        onTDown: () {
          player.rotateLeft = true;

          calcMineLoadAndPlayerActTimesDiffAverage();
        },
        onTUp: () {
          player.rotateLeft = false;
        },
      );
      rotateLeftButton.angle = 4.7;
      add(rotateLeftButton);

      _playerPoints = TextComponent(
        text: "Points: 0",
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _playerPoints.positionType = PositionType.viewport;
      add(_playerPoints);

      _playerShots = TextComponent(
        text: "Shots: 100",
        position: Vector2(150, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _playerShots.positionType = PositionType.viewport;
      add(_playerShots);

      _velocityScore = TextComponent(
        text: "VLCTY: 0",
        position: Vector2(400, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _velocityScore.positionType = PositionType.viewport;
      add(_velocityScore);

      _mineCode = TextComponent(
        text: "IFF: ",
        position: Vector2(500, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _mineCode.positionType = PositionType.viewport;
      add(_mineCode);

      _controlScore = TextComponent(
        text: "CNTRL: ",
        position: Vector2(550, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _controlScore.positionType = PositionType.viewport;
      add(_controlScore);

      _bonus = TextComponent(
        text: "",
        position: fortress.position + Vector2(0, 60),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      );
      _bonus.anchor = Anchor.center;
      _bonus.positionType = PositionType.viewport;
      add(_bonus);

      // _playerHealth = TextComponent(
      //   text: "Health: 100%",
      //   position: Vector2(size.x - 10, 10),
      //   anchor: Anchor.topRight,
      //   textRenderer: TextPaint(
      //     style: const TextStyle(
      //       color: Colors.white,
      //       fontSize: 16,
      //     ),
      //   ),
      // );
      // _playerHealth.positionType = PositionType.viewport;
      // add(_playerHealth);

      outerHexagonShape = PolygonComponent.relative(
        [
          Vector2(0.0, -1.0),
          Vector2(-1.0, -0.5),
          Vector2(-1.0, 0.5),
          Vector2(0.0, 1.0),
          Vector2(1.0, 0.5),
          Vector2(1.0, -0.5),
        ],
        parentSize: size,
        paint: Paint()..color = Colors.white12,
        anchor: Anchor.center,
        position: size / 2,
        angle: 4.7,
        scale: Vector2(0.5, 1.4),
      );

      add(outerHexagonShape);

      innerHexagonShape = PolygonComponent.relative(
        [
          Vector2(0.0, -1.0),
          Vector2(-1.0, -0.5),
          Vector2(-1.0, 0.5),
          Vector2(0.0, 1.0),
          Vector2(1.0, 0.5),
          Vector2(1.0, -0.5),
        ],
        parentSize: size,
        paint: Paint()..color = Colors.white24,
        anchor: Anchor.center,
        position: size / 2,
        angle: 4.7,
        scale: Vector2(0.12, 0.3),
      );

      add(innerHexagonShape);

      _isAlreadyLoaded = true;
    }
  }

  void calcMineLoadAndPlayerActTimesDiffAverage() {
    if (mineOnScreen) {
      if (!mine.isPlayerAct) {
        if (mine.isFoe) {
          foeMineLoadAndPlayerActTimesDiff
              .add(DateTime.now().difference(mine.loadTime).inMilliseconds);
          foeMineLoadAndPlayerActTimesDiffAverage =
              foeMineLoadAndPlayerActTimesDiff.average;
        } else {
          friendlyMineLoadAndPlayerActTimesDiff
              .add(DateTime.now().difference(mine.loadTime).inMilliseconds);
          friendlyMineLoadAndPlayerActTimesDiffAverage =
              friendlyMineLoadAndPlayerActTimesDiff.average;
        }
        mine.isPlayerAct = true;
        print(
            "foeMineLoadAndPlayerActTimesDiff $foeMineLoadAndPlayerActTimesDiff\nfoeMineLoadAndPlayerActTimesDiffAverage $foeMineLoadAndPlayerActTimesDiffAverage\nfriendlyMineLoadAndPlayerActTimesDiff $friendlyMineLoadAndPlayerActTimesDiff\nfriendlyMineLoadAndPlayerActTimesDiffAverage $friendlyMineLoadAndPlayerActTimesDiffAverage");
      }
    }
  }

  void bonusFunc() {
    if (frameCounter % 240 == 0) {
      if (bonus.isEmpty) {
        bonus = '@#\$%&*'.split("")[Random().nextInt(5)];
        bonuses.add(bonus);
      }
    } else if (frameCounter % 600 == 0) {
      if (bonuses.length >= 2) {
        // if (bonuses[bonuses.length - 1] == "\$" &&
        //     bonuses[bonuses.length - 2] == "\$") {
        //   print(bonuses[bonuses.length - 1] + bonuses[bonuses.length - 2]);
        // }
        bonuses.clear();
      }
      bonus = "";
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    frameCounter++;

    _commandList.forEach((command) {
      children.forEach((component) {
        command.run(component);
      });
    });
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    _playerPoints.text = "Points: $playerPoints";
    _playerShots.text = "Shots: $playerShots";
    _velocityScore.text = "VLCTY: $velocityScore";
    _mineCode.text = "IFF: ${mineOnScreen ? mine.code : ""}";
    _controlScore.text = "CNTRL: $controlScore";
    _bonus.text = bonusToked ? "BONUS" : bonus;
    // _playerHealth.text = "Health: ${player.health}%";

    if (playerDeathTimes >= 3) {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameOverMenu.id);
      playerDeathTimes = 0;
      // send data
      try {
        sendSessionData();
      } catch (e) {
        print("$e");
      }
    }
    if (playerRemoved) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        player = Player(
          sprite: spriteSheet.getSpriteById(4),
          size: Vector2(50, 50),
          position: Vector2(180, 130),
        );
        player.anchor = Anchor.center;
        add(player);
      });
      playerRemoved = false;
    }

    if (fortressRemoved) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        fortress = Fortress(
          sprite: spriteSheet.getSpriteById(37),
          size: Vector2(70, 70),
          position: size / 2,
        );
        fortress.anchor = Anchor.center;
        add(fortress);
      });
      fortressRemoved = false;
    }

    if (outerHexagonShape.containsPoint(player.position) &&
        !(innerHexagonShape.containsPoint(player.position))) {
      inOuterHexagon = true;
      inInnerHexagon = false;
      outOfHexagons = false;
    } else if (innerHexagonShape.containsPoint(player.position)) {
      inOuterHexagon = false;
      inInnerHexagon = true;
      outOfHexagons = false;
    } else {
      inOuterHexagon = false;
      inInnerHexagon = false;
      outOfHexagons = true;
    }

    bonusFunc();

    generateMines();

    if (frameCounter == 600) {
      frameCounter = 0;
    }
  }

  void sendSessionData() async {
    await bkl.Backendless.data
        .of("Sessions")
        .save(Sessions(
          playerPoints: playerPoints,
          velocityScore: velocityScore,
          controlScore: controlScore,
          playerShots: playerShots,
          shipDamageByFortress: shipDamageByFortress,
          fortressDestruction: fortressDestruction,
          shipDamageByMine: shipDamageByMine,
          fortressHitByMissile: fortressHitByMissile,
          bonusTaken: bonusTaken,
          fireAverage: fireAverage,
          foeMineLoadAndPlayerActTimesDiffAverage:
              foeMineLoadAndPlayerActTimesDiffAverage,
          friendlyMineLoadAndPlayerActTimesDiffAverage:
              friendlyMineLoadAndPlayerActTimesDiffAverage,
          totalPlayerDistance: totalPlayerDistance,
          assigned_username: usernameInput.text,
        ).toJson())
        .catchError((error, stackTrace) {
      print("Error: ${error.toString()}");
    });
    print("Session created!");
  }

  void generateMines() {
    mineOnScreen = children.whereType<Mine>().isNotEmpty;
    if (mineOnScreen) {
      if (frameCounter % 600 == 0) {
        mine.removeFromParent();
      }
    } else {
      if (frameCounter % 240 == 0) {
        mine = Mine(
          sprite: spriteSheet.getSpriteById(41),
          size: Vector2(50, 50),
        );
        mine.anchor = Anchor.center;
        add(mine);
      }
    }
  }

  // @override
  // void render(Canvas canvas) {
  //   canvas.drawRect(
  //     Rect.fromLTWH(size.x - 107, 10, player.health.toDouble(), 20),
  //     Paint()..color = Colors.blue,
  //   );

  //   super.render(canvas);
  // }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    player.reset();
    _fortressFireManager.reset();
    fortress.reset();

    // Reset Variables
    bonuses = [];
    bonusToked = false;
    fortressRemoved = false;
    inOuterHexagon = false;
    inInnerHexagon = false;
    outOfHexagons = false;
    mineOnScreen = false;
    frameCounter = 0;
    playerDeathTimes = 0;
    playerPoints = 0;
    velocityScore = 0;
    controlScore = 0;
    playerShots = 100;
    bonus = "";
    shipDamageByFortress = 0;
    fortressDestruction = 0;
    shipDamageByMine = 0;
    fortressHitByMissile = 0;
    bonusTaken = 0;
    fireTimes = [];
    fireAverage = 0;
    foeMineLoadAndPlayerActTimesDiff = [];
    foeMineLoadAndPlayerActTimesDiffAverage = 0;
    friendlyMineLoadAndPlayerActTimesDiff = [];
    friendlyMineLoadAndPlayerActTimesDiffAverage = 0;
    totalPlayerDistance = 0;

    children.whereType<Mine>().forEach((mine) => {mine.removeFromParent()});
    children
        .whereType<Bullet>()
        .forEach((bullet) => {bullet.removeFromParent()});
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (player.health > 0) {
          pauseEngine();
          overlays.remove(PauseButton.id);
          overlays.add(PauseMenu.id);
        }
        break;
      default:
    }
    super.lifecycleStateChange(state);
  }

  // @override
  // void onAttach() {
  //   _audioPlayerComponent.playBgm("SpaceInvaders.wav");
  //   super.onAttach();
  // }

  // @override
  // void onDetach() {
  //   _audioPlayerComponent.stopBgm();
  //   super.onDetach();
  // }
}
