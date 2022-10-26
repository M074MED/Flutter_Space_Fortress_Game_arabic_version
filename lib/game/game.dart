import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/audio_player_component.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/command.dart';
import 'package:space_fortress/game/enemy.dart';
import 'package:space_fortress/game/fortress_fire_manager.dart';
import 'package:space_fortress/game/fortress.dart';
import 'package:space_fortress/game/move_buttons.dart';
import 'package:space_fortress/game/player.dart';
import 'package:space_fortress/widgets/overlays/game_over_menu.dart';
import 'package:space_fortress/widgets/overlays/pause_button.dart';
import 'package:space_fortress/widgets/overlays/pause_menu.dart';

class SpaceFortressGame extends FlameGame
    with HasTappables, HasCollisionDetection, HasDraggables {
  late SpriteSheet spriteSheet;
  late Player player;
  int playerPoints = 0;
  int velocityScore = 0;
  int playerShots = 100;
  late Fortress fortress;
  late FortressFireManager _fortressFireManager;
  late JoystickComponent joystick;
  late TextComponent _playerPoints;
  late TextComponent _playerShots;
  late TextComponent _velocityScore;
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
        position: Vector2(180, 130),
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
        },
      );
      add(fireButton);

      MoveButtons moveButton = MoveButtons(
        sprite: spriteSheet.getSpriteById(0),
        position: Vector2(80, size.y - 110),
        size: Vector2(64, 64),
        onTDown: () {
          player.moveAngel =
              Vector2(sin(player.angle), -cos(player.angle)).clone();
          player.speed = 50;
          player.move = true;
        },
        onTUp: () {
          player.moveAngel =
              Vector2(sin(player.angle), -cos(player.angle)).clone();
          player.speed = 200;
          player.move = true;
        },
        onTCancel: () {
          player.move = false;
        },
      );
      add(moveButton);

      MoveButtons rotateRightButton = MoveButtons(
        sprite: spriteSheet.getSpriteById(0),
        position: Vector2(120, size.y - 70),
        size: Vector2(64, 64),
        onTDown: () {
          player.rotateRight = false;
        },
        onTUp: () {
          player.rotateRight = true;
        },
        onTCancel: () {
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
          player.rotateLeft = false;
        },
        onTUp: () {
          player.rotateLeft = true;
        },
        onTCancel: () {
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

  @override
  void update(double dt) {
    super.update(dt);

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
    // _playerHealth.text = "Health: ${player.health}%";

    // if (player.health <= 0 && !camera.shaking) {
    //   pauseEngine();
    //   overlays.remove(PauseButton.id);
    //   overlays.add(GameOverMenu.id);
    // }
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

    children.whereType<Enemy>().forEach((enemy) => {enemy.removeFromParent()});
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

  @override
  void onAttach() {
    _audioPlayerComponent.playBgm("SpaceInvaders.wav");
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }
}
