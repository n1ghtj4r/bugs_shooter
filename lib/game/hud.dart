import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'bugs_shooter_game.dart';

class Hud extends PositionComponent with HasGameRef<BugsShooterGame> {
  late TextComponent scoreText;
  late TextComponent waveText;
  SpriteComponent? weaponIcon;

  late RectangleComponent healthBar;
  final List<SpriteComponent> bulletIcons = [];
  late RectangleComponent reloadBar;
  final List<SpriteComponent> bugsLetters = [];

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

    waveText = TextComponent(
      text: 'WAVE: 1',
      anchor: Anchor.topCenter,
      position: Vector2(gameRef.size.x / 2, 55),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: [Shadow(blurRadius: 5, color: Colors.black)],
        ),
      ),
    );
    add(waveText);

    // Health Bar Background
    add(RectangleComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 15),
      paint: Paint()..color = Colors.black54,
    ));
    healthBar = RectangleComponent(
      position: Vector2(20, 20),
      size: Vector2(150, 15),
      paint: Paint()..color = Colors.redAccent,
    );
    add(healthBar);

    // Ammo Icons Container
    _setupAmmoIcons();

    // Reload Bar
    reloadBar = RectangleComponent(
      position: Vector2(20, 42),
      size: Vector2(150, 4),
      paint: Paint()..color = Colors.blueAccent.withOpacity(0.8),
    )..opacity = 0;
    add(reloadBar);

    _setupBugsLetters();
    _setupWeaponIcon();
  }

  void _setupAmmoIcons() {
    final fallbackSprite = gameRef.interfaceSheet?.getSpriteById(132);
    for (int i = 0; i < 10; i++) {
      final icon = SpriteComponent(
        sprite: fallbackSprite,
        size: Vector2(14, 22),
        position: Vector2(20 + (i * 18), 45),
      );
      bulletIcons.add(icon);
      add(icon);
    }
  }

  void _setupBugsLetters() {
    final fallbackSprite = gameRef.interfaceSheet?.getSpriteById(132);
    for (int i = 0; i < 4; i++) {
      final letter = SpriteComponent(
        sprite: fallbackSprite,
        size: Vector2.all(28),
        position: Vector2(20 + (i * 35), 75),
      );
      bugsLetters.add(letter);
      add(letter);
    }
  }

  void _setupWeaponIcon() {
    if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
      weaponIcon = SpriteComponent(
        sprite: gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId),
        size: Vector2.all(64),
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

    waveText.text = 'WAVE: ${gameRef.wave}';
    waveText.position.x = gameRef.size.x / 2;

    // Update Health
    final maxHp = gameRef.selectedCharacter?.maxHp ?? 3;
    healthBar.size.x = 150 * (gameRef.health / maxHp).clamp(0.0, 1.0);

    // Update Ammo Icons
    final isShotgun = gameRef.selectedWeapon?.id == 1;
    final bulletSprite = (isShotgun ? gameRef.bulletShotgunSprite : gameRef.bulletIconSprite) 
                         ?? gameRef.interfaceSheet?.getSpriteById(132);

    for (int i = 0; i < bulletIcons.length; i++) {
      bulletIcons[i].sprite = bulletSprite;
      bulletIcons[i].opacity = i < gameRef.ammo ? 1.0 : 0.1;
    }

    // Update Reload Bar
    if (gameRef.isReloading) {
      reloadBar.opacity = 1.0;
      reloadBar.size.x = 150 * (1 - (gameRef.reloadTimer / gameRef.reloadDuration));
    } else {
      reloadBar.opacity = 0;
    }

    // Update BUGS Letters
    if (gameRef.spriteB != null) {
      bugsLetters[0].sprite = gameRef.spriteB;
      bugsLetters[0].opacity = gameRef.collectedLetters.contains('B') ? 1.0 : 0.2;
    }
    if (gameRef.spriteU != null) {
      bugsLetters[1].sprite = gameRef.spriteU;
      bugsLetters[1].opacity = gameRef.collectedLetters.contains('U') ? 1.0 : 0.2;
    }
    if (gameRef.spriteG != null) {
      bugsLetters[2].sprite = gameRef.spriteG;
      bugsLetters[2].opacity = gameRef.collectedLetters.contains('G') ? 1.0 : 0.2;
    }
    if (gameRef.spriteS != null) {
      bugsLetters[3].sprite = gameRef.spriteS;
      bugsLetters[3].opacity = gameRef.collectedLetters.contains('S') ? 1.0 : 0.2;
    }

    // Update Weapon Icon
    if (gameRef.selectedWeapon != null && gameRef.weaponsSheet != null) {
      if (weaponIcon == null) {
        _setupWeaponIcon();
      } else {
        weaponIcon!.sprite = gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.tileId);
        weaponIcon!.position.x = gameRef.size.x - 20;
      }
    }
  }
}
