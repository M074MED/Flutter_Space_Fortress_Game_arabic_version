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
import 'package:space_fortress/game/enemy_manager.dart';
import 'package:space_fortress/game/fortress.dart';
import 'package:space_fortress/game/move_buttons.dart';
import 'package:space_fortress/game/player.dart';
import 'package:space_fortress/widgets/overlays/game_over_menu.dart';
import 'package:space_fortress/widgets/overlays/pause_button.dart';
import 'package:space_fortress/widgets/overlays/pause_menu.dart';

class SpaceFortressGame extends FlameGame
    with HasTappables, HasCollisionDetection, HasDraggables {
  late SpriteSheet _spriteSheet;
  late Player _player;
  late Fortress _fortress;
  late EnemyManager _enemyManager;
  late JoystickComponent joystick;
  late TextComponent _playerScore;
  late TextComponent _playerHealth;
  late AudioPlayerComponent _audioPlayerComponent;
  late PolygonComponent hexagonShape;
  bool _isAlreadyLoaded = false;

  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  @override
  Future<void> onLoad() async {
    if (!_isAlreadyLoaded) {
      await images.loadAll(["simpleSpace_tilesheet@2.png", "joystick.png"]);

      // _audioPlayerComponent = AudioPlayerComponent();
      // add(_audioPlayerComponent);

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

      _spriteSheet = SpriteSheet.fromColumnsAndRows(
          image: images.fromCache("simpleSpace_tilesheet@2.png"),
          columns: 8,
          rows: 6);

      _player = Player(
        sprite: _spriteSheet.getSpriteById(4),
        size: Vector2(50, 50),
        position: Vector2(180, 130),
      );
      _player.anchor = Anchor.center;
      add(_player);

      _fortress = Fortress(
        sprite: _spriteSheet.getSpriteById(37),
        size: Vector2(70, 70),
        position: size / 2,
      );
      _fortress.anchor = Anchor.center;
      add(_fortress);

      // _enemyManager = EnemyManager(spriteSheet: _spriteSheet);
      // add(_enemyManager);

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
            sprite: _spriteSheet.getSpriteById(28),
            size: Vector2(64, 64),
            position: _player.position.clone(),
            playerAngle: _player.angle,
          );
          bullet.anchor = Anchor.center;
          add(bullet);
          // _audioPlayerComponent.playSfx("laserSmall.ogg");
        },
      );
      add(fireButton);

      MoveButtons moveButton = MoveButtons(
        sprite: _spriteSheet.getSpriteById(0),
        position: Vector2(80, size.y - 110),
        size: Vector2(64, 64),
        onTDown: () {
          _player.moveAngel =
              Vector2(sin(_player.angle), -cos(_player.angle)).clone();
          _player.speed = 50;
          _player.move = true;
        },
        onTUp: () {
          _player.moveAngel =
              Vector2(sin(_player.angle), -cos(_player.angle)).clone();
          _player.speed = 200;
          _player.move = true;
        },
        onTCancel: () {
          _player.move = false;
        },
      );
      add(moveButton);

      MoveButtons rotateRightButton = MoveButtons(
        sprite: _spriteSheet.getSpriteById(0),
        position: Vector2(120, size.y - 70),
        size: Vector2(64, 64),
        onTDown: () {
          _player.rotateRight = false;
        },
        onTUp: () {
          _player.rotateRight = true;
        },
        onTCancel: () {
          _player.rotateRight = false;
        },
      );
      rotateRightButton.angle = -4.7;
      add(rotateRightButton);

      MoveButtons rotateLeftButton = MoveButtons(
        sprite: _spriteSheet.getSpriteById(0),
        position: Vector2(40, size.y - 70),
        size: Vector2(64, 64),
        onTDown: () {
          _player.rotateLeft = false;
        },
        onTUp: () {
          _player.rotateLeft = true;
        },
        onTCancel: () {
          _player.rotateLeft = false;
        },
      );
      rotateLeftButton.angle = 4.7;
      add(rotateLeftButton);

      _playerScore = TextComponent(
        text: "Score: 0",
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _playerScore.positionType = PositionType.viewport;
      add(_playerScore);

      _playerHealth = TextComponent(
        text: "Health: 100%",
        position: Vector2(size.x - 10, 10),
        anchor: Anchor.topRight,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
      _playerHealth.positionType = PositionType.viewport;
      add(_playerHealth);

      hexagonShape = PolygonComponent.relative(
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

      add(hexagonShape);

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

    _playerScore.text = "Score: ${_player.score}";
    _playerHealth.text = "Health: ${_player.health}%";

    if (_player.health <= 0 && !camera.shaking) {
      pauseEngine();
      overlays.remove(PauseButton.id);
      overlays.add(GameOverMenu.id);
    }

    // track the player
    // if (_player.move) {
    //   _fortress.add(
    //     RotateEffect.by(
    //       _fortress.position.angleTo(_player.position),
    //       LinearEffectController(1),
    //       onComplete: () => {},
    //     ),
    //   );
    // }
    // _fortress.angle = _fortress.position.angleTo(_player.position);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(size.x - 107, 10, _player.health.toDouble(), 20),
      Paint()..color = Colors.blue,
    );

    super.render(canvas);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();

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
        if (_player.health > 0) {
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
    // _audioPlayerComponent.playBgm("SpaceInvaders.wav");
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
  }
}
