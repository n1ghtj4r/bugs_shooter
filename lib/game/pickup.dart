import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';
import 'bugs_shooter_game.dart';

enum PickupType { coin, heart, fireRateBoost }

class Pickup extends SpriteComponent with HasGameRef<BugsShooterGame> {
  final PickupType type;
  final double magnetRadius = 180.0;
  final double collectRadius = 25.0;
  final double speed = 350.0;

  Pickup({
    required this.type,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    int tileId = 0;
    switch (type) {
      case PickupType.coin: tileId = 157; break; // Yellow coin icon
      case PickupType.heart: tileId = 133; break;  // Heart icon
      case PickupType.fireRateBoost: tileId = 139; break; // Speed icon (lightning)
    }

    if (gameRef.interfaceSheet != null) {
      sprite = gameRef.interfaceSheet!.getSpriteById(tileId);
    }
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPos = gameRef.player.position;
    final dist = position.distanceTo(playerPos);
    
    // Magnetic Pull
    if (dist < magnetRadius) {
      final dir = (playerPos - position).normalized();
      position.add(dir * speed * dt);
    }

    // Collect
    if (dist < collectRadius) {
      _collect();
    }
  }

  void _collect() {
    switch (type) {
      case PickupType.coin:
        gameRef.score += 50;
        FlameAudio.play('coin-${['a','b','c','d'][Random().nextInt(4)]}.ogg', volume: 0.35);
        break;
      case PickupType.heart:
        if (gameRef.health < (gameRef.selectedCharacter?.maxHp ?? 3)) {
          gameRef.health++;
        }
        FlameAudio.play('coin-a.ogg', volume: 0.4);
        break;
      case PickupType.fireRateBoost:
        gameRef.activateFireRateBoost();
        FlameAudio.play('select-a.ogg', volume: 0.5);
        break;
    }
    removeFromParent();
  }
}
