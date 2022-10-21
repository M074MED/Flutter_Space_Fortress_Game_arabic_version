import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:space_fortress/game/enemy.dart';
import 'package:space_fortress/game/game.dart';

class Bullet extends SpriteComponent
    with CollisionCallbacks, HasGameRef<SpaceFortressGame> {
  final double _speed = 450;
  final Vector2 velocity;
  final String name;

  Bullet({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
    required double playerAngle,
    required this.name,
  })  : velocity = Vector2(sin(playerAngle), -cos(playerAngle)),
        super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void>? onLoad() {
    add(CircleHitbox(anchor: Anchor.center, position: size / 2, radius: 10));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * _speed * dt);
    if (position.y < 0 ||
        position.y > gameRef.size.y ||
        position.x < 0 ||
        position.x > gameRef.size.x) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }
}
