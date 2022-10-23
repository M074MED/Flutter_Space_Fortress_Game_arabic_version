import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:space_fortress/game/bullet.dart';
import 'package:space_fortress/game/enemy.dart';
import 'package:space_fortress/game/game.dart';

class Player extends SpriteComponent
    with HasGameRef<SpaceFortressGame>, CollisionCallbacks {
  double speed = 50;
  final Random _random = Random();
  int health = 4;
  bool move = false;
  Vector2 moveAngel = Vector2(0, 0);
  bool rotateRight = false;
  bool rotateLeft = false;
  bool inHyperSpace = false;
  int frameCounter = 0;

  // Vector2 getRandomVector() =>
  //     (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  Vector2 getRandomVector() =>
      (Vector2.random(_random) - Vector2.random(_random)) * 500;

  Player({
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
    add(CircleHitbox(anchor: Anchor.center, position: size / 2, radius: 23));
    return super.onLoad();
  }

  void ensureVisible(Vector2 position, Vector2 size) {
    if (position.x > size.x) {
      position.x = 0;
      inHyperSpace = true;
    } else if (position.x < 0) {
      position.x = size.x;
      inHyperSpace = true;
    } else if (position.y > size.y) {
      position.y = 0;
      inHyperSpace = true;
    } else if (position.y < 0) {
      position.y = size.y;
      inHyperSpace = true;
    }

    if (frameCounter == 10) {
      if (inHyperSpace) {
        gameRef.playerPoints -= 35;
        inHyperSpace = false;
      }
      frameCounter = 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (move) {
      position.add(moveAngel * speed * dt);
    }
    if (rotateRight) {
      angle += 2 * dt;
    }
    if (rotateLeft) {
      angle -= 2 * dt;
    }
    // if (gameRef.joystick.direction != JoystickDirection.idle) {
    //   position.add(gameRef.joystick.delta * _speed * dt);
    //   angle = gameRef.joystick.delta.screenAngle();
    // }

    // final particleComponent = ParticleSystemComponent(
    //   particle: Particle.generate(
    //     count: 10,
    //     lifespan: 0.1,
    //     generator: (i) => AcceleratedParticle(
    //       acceleration: getRandomVector(),
    //       speed: getRandomVector(),
    //       position: position.clone() + Vector2(0, size.y / 3),
    //       child: CircleParticle(
    //         radius: 1,
    //         paint: Paint()..color = Colors.white,
    //       ),
    //     ),
    //   ),
    // );
    // gameRef.add(particleComponent);

    // int oldPoints = gameRef.playerPoints;
    frameCounter++;
    ensureVisible(position, gameRef.size);
    // int newPoints = gameRef.playerPoints;
    // if (oldPoints - newPoints == 70) {
    //   gameRef.playerPoints += 35;
    // }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet && other.name == "fortressBullet") {
      gameRef.playerPoints -= 50;
      health -= 1;
      if (health == 0) {
        gameRef.playerPoints -= 100;
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
      other.removeFromParent();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onRemove() {
    gameRef.playerRemoved = true;
    super.onRemove();
  }

  // void addToScore(int points) {
  //   _score += points;
  // }

  void reset() {
    // _score = 0;
    // _health = 100;
    position = gameRef.canvasSize / 2;
  }
}
