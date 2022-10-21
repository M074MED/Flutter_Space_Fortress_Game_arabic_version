import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/enemy.dart';
import 'package:space_fortress/game/game.dart';

class Fortress extends SpriteComponent
    with HasGameRef<SpaceFortressGame>, CollisionCallbacks {
  double speed = 50;
  final Random _random = Random();
  int health = 0;
  List<DateTime> healthDecreaseTime = [];
  int finish = 0;
  List<DateTime> finishDecreaseTime = [];

  Vector2 getRandomVector() =>
      (Vector2.random(_random) - Vector2.random(_random)) * 500;

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
    add(CircleHitbox(anchor: Anchor.center, position: size / 2, radius: 33));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.player.move) {
      lookAt(gameRef.player.position);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet && other.name == "playerBullet") {
      if (health < 10) {
        if (healthDecreaseTime.isEmpty) {
          health += 1;
        }
        healthDecreaseTime.add(DateTime.now());
        if (healthDecreaseTime.length >= 2) {
          if (healthDecreaseTime[healthDecreaseTime.length - 1]
                  .difference(healthDecreaseTime[healthDecreaseTime.length - 2])
                  .inMilliseconds >=
              250) {
            health += 1;
          } else {
            health = 0;
            healthDecreaseTime.clear();
          }
        }
      } else {
        if (finish < 2) {
          if (finishDecreaseTime.isEmpty) {
            finish += 1;
          }
          finishDecreaseTime.add(DateTime.now());
          if (finishDecreaseTime.length >= 2) {
            if (finishDecreaseTime[finishDecreaseTime.length - 1]
                    .difference(
                        finishDecreaseTime[finishDecreaseTime.length - 2])
                    .inMilliseconds <
                250) {
              finish += 1;
              if (finish == 2) {
                gameRef.playerPoints += 100;
                removeFromParent();
                final particleComponent = ParticleSystemComponent(
                  particle: Particle.generate(
                    count: 10,
                    lifespan: 0.1,
                    generator: (i) => AcceleratedParticle(
                      acceleration: getRandomVector(),
                      speed: getRandomVector(),
                      position: position.clone(),
                      child: CircleParticle(
                        radius: 1.5,
                        paint: Paint()..color = Colors.white,
                      ),
                    ),
                  ),
                );
                gameRef.add(particleComponent);
              }
            } else {
              finish = 0;
              finishDecreaseTime.clear();
            }
          }
        }
      }
      print("health: $health || finish: $finish");
      other.removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onRemove() {
    gameRef.fortressRemoved = true;
    super.onRemove();
  }

  // void reset() {
  //   _score = 0;
  //   _health = 100;
  //   position = gameRef.canvasSize / 2;
  // }
}
