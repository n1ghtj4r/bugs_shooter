import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'bugs_shooter_game.dart';
import 'game_data.dart';
import 'obstacle.dart';
import 'wall.dart';
import 'enemy.dart';
import 'dart:math';

class Bullet extends SpriteComponent with HasGameRef<BugsShooterGame>, CollisionCallbacks {
  final Vector2 direction;
  final WeaponData weapon;
  double dist = 0;

  Bullet({required Vector2 position, required this.direction, required this.weapon}) 
      : super(position: position, size: Vector2(8, 20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Determine which bullet sprite to use based on the weapon
    final isShotgun = weapon.id == 1; // Shotgun ID
    sprite = isShotgun ? gameRef.bulletShotgunSprite : gameRef.bulletIconSprite;

    // Fallback if individual sprites are not loaded yet
    if (sprite == null && gameRef.interfaceSheet != null) {
      sprite = gameRef.interfaceSheet!.getSprite(1, 4); // Default gold bullet in sheet
    }
    
    // All bullets are now the same size as requested

    // Correcting Rotation: Pointy end faces the direction of travel
    angle = atan2(direction.y, direction.x) + (pi / 2);
    
    // Use RectangleHitbox for better 360-degree intersection with long bullets
    add(RectangleHitbox(
      size: Vector2(size.x, size.y),
      anchor: Anchor.center,
      position: Vector2.zero(),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = direction * weapon.bulletSpeed * dt;
    position.add(delta);
    dist += delta.length;
    if (dist > 1500) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Obstacle || other is Wall || other is Enemy) {
      removeFromParent();
    }
  }
}
