import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'bugs_shooter_game.dart';

class Hud extends PositionComponent with HasGameRef<BugsShooterGame> {
  late TextComponent scoreText;
  SpriteComponent? weaponIcon;
  
  late RectangleComponent healthBar;
  final List<SpriteComponent> bulletIcons = [];
  late RectangleComponent reloadBar;

  Hud() : super(position: Vector2.zero(), priority: 100);

  @override
  Future<void> onLoad() async {
    // Score at top center
    scoreText = TextComponent(
      text: 'SCORE: 0',
      anchor: Anchor.topCenter,
      position: Vector2(gameRef.size.x / 2, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
      ),
    );
    add(scoreText);

    // Health Bar Background
    add(RectangleComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.black54,
    ));
    healthBar = RectangleComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 12),
      paint: Paint()..color = Colors.redAccent,
    );
    add(healthBar);

    // Ammo Icons Container
    _setupAmmoIcons();

    // Reload Bar (Hidden by default)
    reloadBar = RectangleComponent(
      position: Vector2(20, 40),
      size: Vector2(120, 4),
      paint: Paint()..color = Colors.blueAccent.withOpacity(0.8),
    )..opacity = 0;
    add(reloadBar);

    _setupWeaponIcon();
  }

  void _setupAmmoIcons() {
    final isShotgun = gameRef.selectedWeapon?.id == 1;
    final bulletSprite = (isShotgun ? gameRef.bulletShotgunSprite : gameRef.bulletIconSprite)
                         ?? gameRef.interfaceSheet?.getSprite(1, 4);

    for (int i = 0; i < 10; i++) {
      final icon = SpriteComponent(
        sprite: bulletSprite,
        size: Vector2(12, 20),
        position: Vector2(20 + (i * 15), 40),
      );
      bulletIcons.add(icon);
      add(icon);
    }
  }

  void _setupWeaponIcon() {
    if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
      weaponIcon = SpriteComponent(
        sprite: gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId),
        size: Vector2.all(48),
        position: Vector2(gameRef.size.x - 20, 20),
        anchor: Anchor.topRight,
      );
      add(weaponIcon!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'SCORE: ${gameRef.score}';
    scoreText.position.x = gameRef.size.x / 2;

    // Update Health
    final maxHp = gameRef.selectedCharacter?.maxHp ?? 3;
    healthBar.size.x = 150 * (gameRef.health / maxHp);

    // Update Ammo Icons
    final isShotgun = gameRef.selectedWeapon?.id == 1;
    final bulletSprite = isShotgun ? gameRef.bulletShotgunSprite : gameRef.bulletIconSprite;

    for (int i = 0; i < bulletIcons.length; i++) {
      bulletIcons[i].sprite = bulletSprite;
      bulletIcons[i].opacity = i < gameRef.ammo ? 1.0 : 0.0;
    }

    // Update Reload Bar
    if (gameRef.isReloading) {
      reloadBar.opacity = 1.0;
      reloadBar.size.x = 150 * (1 - (gameRef.reloadTimer / gameRef.reloadDuration));
    } else {
      reloadBar.opacity = 0;
    }

    // Update Weapon Icon if changed
    if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
      if (weaponIcon == null) {
        _setupWeaponIcon();
      } else {
        weaponIcon!.sprite = gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId);
      }
    }
  }
}
