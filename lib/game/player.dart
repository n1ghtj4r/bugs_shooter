import 'package:flame/effects.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'bugs_shooter_game.dart';
import 'game_data.dart';
import 'enemy.dart';
import 'wall.dart';
import 'dart:math';

class Player extends PositionComponent with HasGameRef<BugsShooterGame>, CollisionCallbacks, KeyboardHandler {
  double baseSpeed = 400.0;
  final Vector2 _moveDir = Vector2.zero();
  late int row;
  
  // Separate components for body and weapon for better visual control
  late SpriteAnimationComponent body;
  late SpriteComponent weaponHand;
  
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
    await super.onLoad();
    row = gameRef.selectedCharacter?.tileRow ?? 0;
    
    if (gameRef.playerSheet != null) {
      walkAnim = gameRef.playerSheet!.createAnimation(row: row, stepTime: 0.1, from: 0, to: 4);
      idleAnim = gameRef.playerSheet!.createAnimation(row: row, stepTime: 0.5, from: 0, to: 1);
    }
    
    // The Body (Animation)
    body = SpriteAnimationComponent(
      animation: idleAnim,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(body);

    // The Weapon - Aligned with the hands of the character sprites
    weaponHand = SpriteComponent(
      size: Vector2.all(32), 
      anchor: const Anchor(0.1, 0.5), // Grip point at the end of the handle
      position: Vector2(size.x / 2, size.y / 2 + 8), 
      priority: 10, // Always on top of the body
    );
    
    if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
      weaponHand.sprite = gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId);
    }
    add(weaponHand);

    // Hitbox aligned to center
    add(CircleHitbox(radius: 20, anchor: Anchor.center, position: size / 2));

    // Status Bubble
    statusBubble = SpriteComponent(
      sprite: gameRef.approachingWarningSprite,
      size: Vector2.all(32),
      position: Vector2(size.x / 2, -15),
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
      body.opacity = (damageFlashTimer * 15).toInt() % 2 == 0 ? 0.4 : 1.0;
      weaponHand.opacity = body.opacity;
    } else {
      body.opacity = 1.0;
      weaponHand.opacity = 1.0;
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
        if (body.animation != walkAnim) body.animation = walkAnim;
      } else {
        if (body.animation != idleAnim) body.animation = idleAnim;
      }

      // 360 Aiming logic
      final dirToCrosshair = gameRef.crosshair.position - position;
      
      // Flip character body to face target (upright 2D style)
      if (dirToCrosshair.x.abs() > 2) {
        body.scale.x = dirToCrosshair.x < 0 ? -1 : 1;
      }

      // Update held weapon rotation and position
      if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
        weaponHand.sprite = gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId);
        
        final angle = atan2(dirToCrosshair.y, dirToCrosshair.x);
        weaponHand.angle = angle;
        
        // Keep weapon upright when aiming left
        if (angle > pi/2 || angle < -pi/2) {
          weaponHand.scale.y = -1;
        } else {
          weaponHand.scale.y = 1;
        }
        
        // Push the weapon slightly forward based on aim direction to look "held"
        final aimOffset = dirToCrosshair.normalized() * 12;
        weaponHand.position = Vector2(size.x / 2, size.y / 2 + 8) + aimOffset;
      }
    }

    position.x = position.x.clamp(32, BugsShooterGame.worldSize - 32);
    position.y = position.y.clamp(32, BugsShooterGame.worldSize - 32);
  }

  void _updateStatusBubble(double dt) {
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
      final s = 1.0 + 0.1 * sin(DateTime.now().millisecondsSinceEpoch / 50);
      statusBubble?.scale = Vector2.all(s);
    } else if (minDist < 250) {
      statusBubble?.sprite = gameRef.approachingWarningSprite;
      statusBubble?.opacity = 1.0;
      statusBubble?.scale = Vector2.all(1.0);
    } else {
      statusBubble?.opacity = 0;
    }
  }

  void dash() {
    if (dashCooldownTimer > 0 || isDashing) return;
    isDashing = true;
    dashTimer = dashDuration;
    dashCooldownTimer = dashCooldownDuration;
    dashDirection = _moveDir.isZero() ? Vector2(body.scale.x, 0) : _moveDir.normalized();
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
        position: Vector2(size.x / 2, -15),
        size: Vector2.all(40),
        anchor: Anchor.center,
      );
      add(skull);
      skull.add(MoveEffect.by(Vector2(0, -60), EffectController(duration: 0.6)));
      skull.add(OpacityEffect.fadeOut(EffectController(duration: 0.6), onComplete: () => skull.removeFromParent()));
    }
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Wall && points.isNotEmpty) {
      position.add((position - points.first).normalized() * 4);
    }
  }
}
