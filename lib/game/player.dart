import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'bugs_shooter_game.dart';
import 'game_data.dart';
import 'enemy.dart';
import 'wall.dart';
import 'dart:math';

class Player extends SpriteAnimationComponent with HasGameRef<BugsShooterGame>, CollisionCallbacks, KeyboardHandler {
  double baseSpeed = 400.0;
  final Vector2 _moveDir = Vector2.zero();
  late int row;
  SpriteAnimation? walkAnim, idleAnim;
  final Set<LogicalKeyboardKey> _keys = {};
  
  SpriteComponent? statusBubble;

  // Dash variables
  bool isDashing = false;
  double dashTimer = 0.0;
  final double dashDuration = 0.2;
  double dashCooldownTimer = 0.0;
  double get dashCooldownDuration => (gameRef.selectedCharacter?.id == 0) ? 0.7 : 1.0; 
  Vector2 dashDirection = Vector2.zero();
  
  double damageFlashTimer = 0.0;
  bool get isInvincible => isDashing || damageFlashTimer > 0.0;

  Player() : super(anchor: Anchor.center, size: Vector2.all(64));

  @override
  Future<void> onLoad() async {
    row = gameRef.selectedCharacter?.tileRow ?? 0;
    if (gameRef.playerSheet != null) {
      walkAnim = gameRef.playerSheet!.createAnimation(row: row, stepTime: 0.1, from: 0, to: 4);
      idleAnim = gameRef.playerSheet!.createAnimation(row: row, stepTime: 0.5, from: 0, to: 1);
      animation = idleAnim;
    }
    // Fixed Hitbox Alignment: Center it by using Vector2.zero() since anchor is center
    add(CircleHitbox(radius: 20, anchor: Anchor.center, position: Vector2.zero()));

    // Ensure a sprite is always set to avoid assertion error
    final fallbackSprite = gameRef.interfaceSheet?.getSprite(1, 5);

    statusBubble = SpriteComponent(
      sprite: gameRef.approachingWarningSprite ?? fallbackSprite,
      size: Vector2.all(32),
      position: Vector2(0, -50), // Centered and slightly higher
      anchor: Anchor.center,
    );
    statusBubble!.opacity = 0;
    add(statusBubble!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.health <= 0) return;

    _updateStatusBubble(dt);

    if (dashCooldownTimer > 0) dashCooldownTimer -= dt;
    if (damageFlashTimer > 0) {
      damageFlashTimer -= dt;
      opacity = (damageFlashTimer * 15).toInt() % 2 == 0 ? 0.4 : 1.0;
    } else {
      opacity = 1.0;
    }

    // Keep status bubble upright and centered regardless of player flip
    if (statusBubble != null) {
      statusBubble!.scale.x = scale.x.abs() * (statusBubble!.scale.x / statusBubble!.scale.x.abs());
    }

    if (isDashing) {
      dashTimer -= dt;
      position.add(dashDirection * baseSpeed * 2.5 * dt);
      if (dashTimer <= 0) isDashing = false;
    } else {
      _moveDir.setZero();
      if (gameRef.controlMode == ControlMode.keyboard) {
        if (_keys.contains(LogicalKeyboardKey.keyW)) _moveDir.y -= 1;
        if (_keys.contains(LogicalKeyboardKey.keyS)) _moveDir.y += 1;
        if (_keys.contains(LogicalKeyboardKey.keyA)) _moveDir.x -= 1;
        if (_keys.contains(LogicalKeyboardKey.keyD)) _moveDir.x += 1;
      } else if (gameRef.joystick != null && !gameRef.joystick!.delta.isZero()) {
        _moveDir.setFrom(gameRef.joystick!.relativeDelta);
      }

      if (!_moveDir.isZero()) {
        final speed = baseSpeed * (gameRef.selectedCharacter?.speedMultiplier ?? 1.0);
        position.add(_moveDir.normalized() * speed * dt);
        if (animation != walkAnim) animation = walkAnim;
      } else {
        if (animation != idleAnim) animation = idleAnim;
      }

      // 360 Aiming: Always face the crosshair even when standing still
      final dirToCrosshair = gameRef.crosshair.position - position;
      if (dirToCrosshair.x.abs() > 5) { // Small deadzone to prevent flickering
        scale.x = dirToCrosshair.x < 0 ? -1 : 1;
      }
    }

    position.x = position.x.clamp(32, BugsShooterGame.worldSize - 32);
    position.y = position.y.clamp(32, BugsShooterGame.worldSize - 32);
  }

  void _updateStatusBubble(double dt) {
    if (gameRef.interfaceSheet == null) return;

    final enemies = gameRef.world.children.whereType<Enemy>();
    if (enemies.isEmpty) {
      statusBubble?.opacity = 0;
      return;
    }

    double minDist = double.infinity;
    for (final e in enemies) {
      final d = position.distanceTo(e.position);
      if (d < minDist) minDist = d;
    }

    if (minDist < 120) {
      statusBubble?.sprite = gameRef.warningSeeSprite;
      statusBubble?.opacity = 1.0;
      // Pulse effect when in danger
      final s = 1.0 + 0.1 * sin(DateTime.now().millisecondsSinceEpoch / 50);
      statusBubble?.scale = Vector2(s * (scale.x < 0 ? -1 : 1), s);
    } else if (minDist < 250) {
      statusBubble?.sprite = gameRef.approachingWarningSprite;
      statusBubble?.opacity = 1.0;
      statusBubble?.scale = Vector2(scale.x < 0 ? -1 : 1, 1.0);
    } else {
      statusBubble?.opacity = 0;
    }
  }

  void dash() {
    if (dashCooldownTimer > 0 || isDashing) return;
    isDashing = true;
    dashTimer = dashDuration;
    dashCooldownTimer = dashCooldownDuration;
    dashDirection = _moveDir.isZero() ? Vector2(scale.x, 0) : _moveDir.normalized();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keys.clear(); _keys.addAll(keysPressed);
    if (keysPressed.contains(LogicalKeyboardKey.space) && event is KeyDownEvent) dash();
    return super.onKeyEvent(event, keysPressed);
  }

  void triggerDamageFlash() {
    damageFlashTimer = 1.0;
    
    final skullSprite = gameRef.skullHeroSprite ?? gameRef.interfaceSheet?.getSprite(1, 1);
    if (skullSprite != null) {
      final skull = SpriteComponent(
        sprite: skullSprite,
        position: Vector2(0, -50), // Centered exactly above head
        size: Vector2.all(40),
        anchor: Anchor.center,
      );
      add(skull);
      // Ensure skull isn't flipped by player scale
      skull.scale.x = scale.x < 0 ? -1 : 1;

      skull.add(MoveEffect.by(Vector2(0, -60), EffectController(duration: 0.6)));
      skull.add(OpacityEffect.fadeOut(EffectController(duration: 0.6), onComplete: () => skull.removeFromParent()));
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Wall) {
      if (points.isNotEmpty) {
        final collisionPoint = points.first;
        final pushDir = (position - collisionPoint).normalized();
        position.add(pushDir * 4);
      }
    }
  }
}
