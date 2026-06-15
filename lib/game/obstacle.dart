import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'bugs_shooter_game.dart';

class Obstacle extends SpriteComponent with HasGameRef<BugsShooterGame> {
  final int tileId;

  Obstacle({
    required this.tileId,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if (gameRef.tilesSheet != null) {
      sprite = gameRef.tilesSheet!.getSpriteById(tileId);
    }
    add(RectangleHitbox());
  }
}
