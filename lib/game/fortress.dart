import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/enemy.dart';
import 'package:space_fortress/game/game.dart';

class Fortress extends SpriteComponent
    with HasGameRef<SpaceFortressGame>, CollisionCallbacks {
  double speed = 50;
  int _health = 100;
  int get health => _health;

  Fortress({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
        );

  @override
  Future<void>? onLoad() {
    add(CircleHitbox(anchor: Anchor.center, position: size / 2, radius: 33)
      ..debugMode = true);
    return super.onLoad();
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (other is Enemy) {
  //     gameRef.camera.shake(intensity: 20);
  //     _health -= 10;
  //     if (health < 0) {
  //       _health = 0;
  //     }
  //   }
  //   super.onCollision(intersectionPoints, other);
  // }

  // void reset() {
  //   _score = 0;
  //   _health = 100;
  //   position = gameRef.canvasSize / 2;
  // }
}
