import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'dart:math';
import 'bugs_shooter_game.dart';

enum PickupType { b, u, g, s }

class Pickup extends SpriteComponent with HasGameRef<BugsShooterGame> {
  final PickupType type;
  final double magnetRadius = 180.0;
  final double collectRadius = 25.0;
  final double speed = 350.0;

  Pickup({
    required this.type,
    required Vector2 position,
  }) : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    switch (type) {
      case PickupType.b: sprite = gameRef.spriteB; break;
      case PickupType.u: sprite = gameRef.spriteU; break;
      case PickupType.g: sprite = gameRef.spriteG; break;
      case PickupType.s: sprite = gameRef.spriteS; break;
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
    gameRef.score += 100;
    String letter = '';
    switch (type) {
      case PickupType.b: letter = 'B'; break;
      case PickupType.u: letter = 'U'; break;
      case PickupType.g: letter = 'G'; break;
      case PickupType.s: letter = 'S'; break;
    }
    gameRef.collectLetter(letter);
    FlameAudio.play('coin-${['a','b','c','d'][Random().nextInt(4)]}.ogg', volume: 0.35);
    removeFromParent();
  }
}
