import 'package:flame/components.dart';
import 'package:flame/events.dart';

class MoveButtons extends SpriteComponent with Tappable {
  late Function onTDown;
  late Function onTUp;

  MoveButtons({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
    required Function onTDown,
    required Function onTUp,
  })  : onTDown = onTDown,
        onTUp = onTUp,
        super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
        );
  @override
  bool onTapUp(_) {
    onTUp();
    return true;
  }

  @override
  bool onTapDown(_) {
    onTDown();
    return true;
  }
}
