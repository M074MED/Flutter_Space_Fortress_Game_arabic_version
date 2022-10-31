import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/game.dart';
import 'package:space_fortress/game/player.dart';
import 'package:space_fortress/screens/main_menu.dart';

class Mine extends SpriteComponent
    with HasGameRef<SpaceFortressGame>, CollisionCallbacks {
  final Random _random = Random();
  int frameCounter = 0;
  int speed = 100;
  String code = getRandomChar();
  late bool isFoe;
  late DateTime loadTime;
  late bool isPlayerAct;

  Vector2 getRandomVector() =>
      (Vector2.random(_random) - Vector2.random(_random)) * 500;

  Mine({
    Sprite? sprite,
    Vector2? size,
  }) : super(
          sprite: sprite,
          size: size,
        );
  @override
  Future<void>? onLoad() {
    position = Vector2(_random.nextInt((gameRef.size.x).toInt()).toDouble(),
        _random.nextInt((gameRef.size.y).toInt()).toDouble());
    isFoe = foeMinesCode.contains(code) ? true : false;
    loadTime = DateTime.now();
    isPlayerAct = false;

    add(RectangleHitbox(
        anchor: Anchor.center, position: size / 2, size: size - Vector2.all(25))
      ..debugMode = true);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dir = (gameRef.player.position - position).normalized();
    position += dir * (speed * dt);
    frameCounter++;
    if (frameCounter == 120) {
      frameCounter = 0;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (isFoe) {
        other.health -= 2;
        gameRef.playerPoints -= 50;
      }
      destroy();

      gameRef.shipDamageByMine++;
    } else if (other is Bullet && other.name == "playerBullet") {
      if (!isFoe) {
        gameRef.playerPoints += 20;
        if (gameRef.inOuterHexagon || gameRef.inInnerHexagon) {
          gameRef.controlScore += 20;
        } else if (gameRef.outOfHexagons) {
          gameRef.controlScore += (20 * 0.5).toInt();
        }
        gameRef.fortress.health += 1;
      }
      destroy();
    }
    super.onCollision(intersectionPoints, other);
  }

  void destroy() {
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

  // void reset() {
  //   _score = 0;
  //   _health = 100;
  //   position = gameRef.canvasSize / 2;
  // }
}
