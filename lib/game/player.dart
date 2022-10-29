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
  double speed = 0;
  double maxSpeed = 250;
  final Random _random = Random();
  int health = 4;
  bool move = false;
  bool onTurbo = false;
  int oldAngleDir = 0;
  int newAngleDir = 0;
  Vector2 moveAngel = Vector2(0, 0);
  bool rotateRight = false;
  bool rotateLeft = false;
  bool inHyperSpace = false;
  bool canShoot = true;
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

    if (frameCounter % 10 == 0) {
      if (inHyperSpace) {
        gameRef.controlScore -= 35;
        inHyperSpace = false;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    frameCounter++;

    if (onTurbo) {
      if (oldAngleDir == newAngleDir) {
        moveAngel = Vector2(sin(angle), -cos(angle)).clone();
        speed += 2;
        if (speed > maxSpeed) {
          speed = maxSpeed;
        }
      } else {
        if (oldAngleDir + newAngleDir == 2 || oldAngleDir + newAngleDir == 4) {
          speed -= 2;
          if (speed <= 0) {
            oldAngleDir = newAngleDir;
          }
        } else {
          moveAngel = Vector2(sin(angle), -cos(angle)).clone();
          speed += 2;
          if (speed > maxSpeed) {
            speed = maxSpeed;
          }
        }
      }
      print(speed);
      print("oldAngleDir $oldAngleDir");
      print("newAngleDir $newAngleDir");
      print("Angle $angle");
    }

    if (move) {
      position.add(moveAngel * speed * dt);
    }
    if (rotateRight) {
      angle += 2 * dt;
      if (angle > 2 * pi) {
        angle = 0;
      }
    }
    if (rotateLeft) {
      angle -= 2 * dt;
      if (angle < 0) {
        angle = 2 * pi;
      }
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

    ensureVisible(position, gameRef.size);

    if (frameCounter % 30 == 0) {
      if (speed < 150) {
        gameRef.velocityScore += 7;
      } else {
        gameRef.velocityScore -= 7;
      }
      frameCounter = 0;
    }

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
      // print(
      //     "shipDamageByFortress ${gameRef.shipDamageByFortress}\nfortressDestruction ${gameRef.fortressDestruction}\nshipDamageByMine ${gameRef.shipDamageByMine}\nfortressHitByMissile ${gameRef.fortressHitByMissile}\nbonusTaken ${gameRef.bonusTaken}");
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bullet && other.name == "fortressBullet") {
      gameRef.playerPoints -= 50;
      health -= 1;

      gameRef.shipDamageByFortress++;
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
