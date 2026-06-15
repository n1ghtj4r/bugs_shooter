import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'bugs_shooter_game.dart';
import 'bullet.dart';
import 'player.dart';
import 'wall.dart';

class Enemy extends SpriteAnimationComponent with HasGameRef<BugsShooterGame>, CollisionCallbacks {
  final int wave;
  late double speed;
  double hp = 1;
  late double maxHp;
  late int row;
  double _damageTimer = 0;
  
  late RectangleComponent _hpBar;
  late RectangleComponent _hpBarBg;

  Enemy({required Vector2 position, required this.wave}) 
      : super(position: position, size: Vector2.all(56), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final speedMultiplier = gameRef.selectedMapTheme?.enemySpeedMultiplier ?? 1.0;
    speed = (130.0 + (wave * 5)) * speedMultiplier;
    
    // Increased HP to make them tougher
    maxHp = 5.0 + (wave * 1.5);
    hp = maxHp;
    
    row = (wave - 1) % 4; 
    
    if (gameRef.enemySheet != null) {
      animation = gameRef.enemySheet!.createAnimation(row: row, stepTime: 0.1, from: 0, to: 4);
    }
    // Fixed Hitbox Alignment: Use Vector2.zero() with Anchor.center
    // Slightly larger radius (25) to catch bullets from all 360 degrees reliably
    add(CircleHitbox(radius: 25, anchor: Anchor.center, position: Vector2.zero()));

    // Enemy Health Bar: Positioned at 0, -38 (above head)
    _hpBarBg = RectangleComponent(
      position: Vector2(0, -38),
      size: Vector2(40, 4),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black54,
    );
    add(_hpBarBg);

    _hpBar = RectangleComponent(
      position: Vector2(0, -38),
      size: Vector2(40, 4),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.greenAccent,
    );
    add(_hpBar);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.health <= 0) return;
    _damageTimer += dt;

    final dir = (gameRef.player.position - position).normalized();
    position.add(dir * speed * dt);
    
    // Face the player
    if (dir.x < 0) scale.x = -1; 
    else if (dir.x > 0) scale.x = 1;

    // Update HP Bar visual
    _hpBar.size.x = 40 * (hp / maxHp).clamp(0, 1);
    if (hp / maxHp < 0.3) _hpBar.paint.color = Colors.redAccent;
    
    // Ensure damage to hero if touching (Circle-to-circle check)
    // Hero radius is 20, Enemy radius is 22. Sum = 42.
    if (_damageTimer >= 1.0 && position.distanceTo(gameRef.player.position) < 48) {
      gameRef.health -= 1;
      _damageTimer = 0;
      gameRef.playHurtSound();
      gameRef.player.triggerDamageFlash();
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Bullet) {
      hp -= other.weapon.damage;
      other.removeFromParent();
      
      // Improved Quick Flash effect: Fast pulse once
      add(ColorEffect(
        Colors.white, 
        EffectController(duration: 0.05, reverseDuration: 0.05), 
        opacityTo: 0.7
      ));

      if (hp <= 0) {
        _die();
      }
    } else if (other is Player && _damageTimer >= 1.0) {
      gameRef.health -= 1;
      _damageTimer = 0;
      gameRef.playHurtSound();
      gameRef.player.triggerDamageFlash();
    } else if (other is Wall) {
      if (points.isNotEmpty) {
        final collisionPoint = points.first;
        final pushDir = (position - collisionPoint).normalized();
        position.add(pushDir * 3);
      }
    }
  }

  void _die() {
    removeFromParent();
    gameRef.score += 10;
    if (Random().nextDouble() < 0.2) gameRef.spawnLoot(position.clone());
    gameRef.playExplosionSound();

    if (gameRef.skullEnemySprite != null) {
      // Death effect: Skull icon using renamed file
      final skull = SpriteComponent(
        sprite: gameRef.skullEnemySprite,
        position: position.clone(),
        size: Vector2.all(32),
        anchor: anchor,
      );
      gameRef.world.add(skull);
      skull.add(MoveEffect.by(Vector2(0, -60), EffectController(duration: 0.8)));
      skull.add(OpacityEffect.fadeOut(EffectController(duration: 0.8), onComplete: () => skull.removeFromParent()));
    }

    // Red Splat
    gameRef.world.add(
      SpriteComponent(
        sprite: animation!.frames.first.sprite,
        position: position.clone(),
        size: size.clone(),
        anchor: anchor,
        paint: Paint()..color = Colors.red.withOpacity(0.7),
      )..add(OpacityEffect.fadeOut(EffectController(duration: 0.6), onComplete: () => null))
       ..add(ScaleEffect.by(Vector2.all(1.2), EffectController(duration: 0.3)))
    );
  }
}
