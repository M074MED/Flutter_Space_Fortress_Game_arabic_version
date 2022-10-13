import 'package:flame/components.dart';
import 'package:flame/events.dart';

class MoveButtons extends SpriteComponent with Tappable {
  late Function onTDown;
  late Function onTUp;
  late Function onTCancel;

  MoveButtons({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
    required Function onTDown,
    required Function onTUp,
    required Function onTCancel,
  })  : onTDown = onTDown,
        onTUp = onTUp,
        onTCancel = onTCancel,
        super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
        );
  @override
  bool onTapUp(_) {
    onTDown();
    return true;
  }

  @override
  bool onTapDown(_) {
    onTUp();
    return true;
  }

  @override
  bool onTapCancel() {
    onTCancel();
    return true;
  }
}
