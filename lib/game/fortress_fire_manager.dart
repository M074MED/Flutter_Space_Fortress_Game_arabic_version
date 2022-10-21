import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/game.dart';

class FortressFireManager extends Component with HasGameRef<SpaceFortressGame> {
  late Timer _timer;
  SpriteSheet spriteSheet;
  Random random = Random();

  FortressFireManager({required this.spriteSheet}) : super() {
    _timer = Timer(
      3,
      onTick: _fortressFire,
      repeat: true,
    );
  }

  void _fortressFire() {
    if (gameRef.player.move) {
      Vector2 initialSize = Vector2(64, 64);
      Vector2 position = gameRef.fortress.position;
      // position.clamp(
      //     Vector2.zero() + initialSize / 2, gameRef.size - initialSize / 2);

      Bullet fortressBullet = Bullet(
      name: "fortressBullet",
        sprite: spriteSheet.getSpriteById(31),
        size: initialSize,
        position: position,
        playerAngle: gameRef.fortress.angle,
      );
      fortressBullet.anchor = Anchor.center;
      gameRef.add(fortressBullet);
    }
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    _timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  void reset() {
    _timer.stop();
    _timer.start();
  }
}
