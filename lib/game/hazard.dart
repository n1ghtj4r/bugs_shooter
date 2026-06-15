import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'bugs_shooter_game.dart';

enum HazardType { damage, slow, poison, lava }

class Hazard extends SpriteComponent with HasGameRef<BugsShooterGame> {
  final int tileId;
  final HazardType type;
  double _timer = 0;

  Hazard({
    required this.tileId,
    required Vector2 position,
    required this.type,
  }) : super(position: position, size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if (gameRef.tilesSheet != null) {
      sprite = gameRef.tilesSheet!.getSpriteById(tileId);
    }
    add(CircleHitbox(radius: size.x * 0.35, anchor: Anchor.center, position: size / 2));
  }

  void triggerEffect(double dt) {
    _timer += dt;
    switch (type) {
      case HazardType.damage:
        if (_timer >= 1.0) {
          gameRef.health -= 1;
          gameRef.playHurtSound();
          _timer = 0;
        }
        break;
      case HazardType.lava:
        if (_timer >= 0.5) {
          gameRef.health -= 1;
          gameRef.playHurtSound();
          _timer = 0;
        }
        break;
      case HazardType.poison:
        if (_timer >= 2.0) {
          gameRef.health -= 1;
          gameRef.playHurtSound();
          _timer = 0;
        }
        break;
      case HazardType.slow:
        // Slow effect is applied in player.update
        break;
    }
  }
}
