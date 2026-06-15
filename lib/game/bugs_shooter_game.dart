import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Rectangle;
import 'player.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'hud.dart';
import 'game_data.dart';
import 'obstacle.dart';
import 'hazard.dart';
import 'pickup.dart';
import 'wall.dart';

class Crosshair extends SpriteComponent with HasGameRef<BugsShooterGame> {
  Crosshair() : super(size: Vector2.all(32), anchor: Anchor.center, priority: 200);

  bool isTargeting = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    updateSprite();
  }

  void updateSprite() {
    if (gameRef.weaponsSheet != null && gameRef.selectedWeapon != null) {
      sprite = gameRef.weaponsSheet!.getSpriteById(gameRef.selectedWeapon!.crosshairId);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final enemies = gameRef.world.children.whereType<Enemy>();
    isTargeting = enemies.any((e) => e.containsPoint(position));

    if (isTargeting) {
      paint.color = Colors.red;
      scale = Vector2.all(1.2 + 0.1 * sin(DateTime.now().millisecondsSinceEpoch / 100));
    } else {
      paint.color = Colors.white;
      scale = Vector2.all(1.0);
    }
    
    // Smoothly follow the mouse position but relative to camera if needed
    // The position is already updated in onMouseMove, so we just handle targeting here
  }
}

class BugsShooterGame extends FlameGame 
    with HasCollisionDetection, TapCallbacks, DragCallbacks, HasKeyboardHandlerComponents, MouseMovementDetector {
  
  static const double worldSize = 2500.0;
  late Player player;
  late Hud hud;
  late Crosshair crosshair;
  JoystickComponent? joystick;
  late Timer enemySpawner;
  
  ControlMode controlMode = ControlMode.joystick;
  CharacterData? selectedCharacter;
  WeaponData? selectedWeapon;
  MapThemeData? selectedMapTheme;
  
  int score = 0;
  int health = 3;
  int ammo = 10;
  final int maxAmmo = 10;
  double reloadTimer = 0.0;
  final double reloadDuration = 1.5;
  bool get isReloading => reloadTimer > 0;

  double _fireTimer = 0;

  int wave = 1;
  int enemiesSpawnedInWave = 0;
  bool isWaveActive = false;

  SpriteSheet? playerSheet, enemySheet, weaponsSheet, tilesSheet, interfaceSheet;
  Sprite? warningSeeSprite, approachingWarningSprite, bulletIconSprite, bulletShotgunSprite, skullEnemySprite, skullHeroSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    playerSheet = SpriteSheet(image: await images.load('Players/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    enemySheet = SpriteSheet(image: await images.load('Enemies/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    weaponsSheet = SpriteSheet(image: await images.load('Weapons/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    tilesSheet = SpriteSheet(image: await images.load('Tiles/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(16));
    interfaceSheet = SpriteSheet(image: await images.load('Interface/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(16));

    // Load renamed individual sprites
    warningSeeSprite = Sprite(await images.load('Interface/Tiles/warning_see_enemy.png'));
    approachingWarningSprite = Sprite(await images.load('Interface/Tiles/approaching_enemy_warning.png'));
    bulletIconSprite = Sprite(await images.load('Interface/Tiles/bullet_rifle.png'));
    bulletShotgunSprite = Sprite(await images.load('Interface/Tiles/bullet_shotgun.png'));
    skullEnemySprite = Sprite(await images.load('Interface/Tiles/skull_enemy.png'));
    skullHeroSprite = Sprite(await images.load('Interface/Tiles/skull_hero.png'));

    camera = CameraComponent.withFixedResolution(width: 800, height: 600, world: world);
    add(camera);

    hud = Hud();
    camera.viewport.add(hud); 

    crosshair = Crosshair();
    world.add(crosshair);

    _addBoundaries();

    enemySpawner = Timer(2.0, onTick: _spawnEnemy, repeat: true);

    await FlameAudio.audioCache.loadAll([
      'shoot-a.ogg', 'shoot-b.ogg', 'shoot-c.ogg', 'shoot-d.ogg',
      'shoot-e.ogg', 'shoot-f.ogg', 'shoot-g.ogg', 'shoot-h.ogg',
      'hurt-a.ogg', 'hurt-b.ogg', 'hurt-c.ogg', 'hurt-d.ogg', 'hurt-e.ogg',
      'explosion-a.ogg', 'explosion-b.ogg', 'explosion-c.ogg',
      'coin-a.ogg', 'coin-b.ogg', 'coin-c.ogg', 'coin-d.ogg',
      'select-a.ogg', 'lose-a.ogg'
    ]);
    
    pauseEngine();
  }

  void startNewGame() {
    score = 0;
    health = selectedCharacter?.maxHp ?? 3;
    ammo = maxAmmo;
    reloadTimer = 0;
    wave = 1;
    enemiesSpawnedInWave = 0;
    isWaveActive = true;
    enemySpawner.limit = 2.0;
    
    world.children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    world.children.whereType<Player>().forEach((p) => p.removeFromParent());
    world.children.whereType<SpriteBatchComponent>().forEach((b) => b.removeFromParent());
    world.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    world.children.whereType<Wall>().forEach((w) => w.removeFromParent());
    world.children.whereType<Hazard>().forEach((h) => h.removeFromParent());
    world.children.whereType<Pickup>().forEach((p) => p.removeFromParent());

    _generateMap();

    player = Player();
    player.position = Vector2(worldSize / 2, worldSize / 2);
    world.add(player);
    camera.follow(player);

    if (weaponsSheet != null && selectedWeapon != null) {
      crosshair.sprite = weaponsSheet!.getSpriteById(selectedWeapon!.crosshairId);
    }

    if (joystick != null) joystick!.removeFromParent();
    if (controlMode == ControlMode.joystick) {
      joystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white60),
        background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black38),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
      camera.viewport.add(joystick!);

      // Shoot Button for Joystick Mode
      final shootButton = HudButtonComponent(
        button: CircleComponent(radius: 35, paint: Paint()..color = Colors.red.withOpacity(0.5)),
        buttonDown: CircleComponent(radius: 35, paint: Paint()..color = Colors.red),
        margin: const EdgeInsets.only(right: 40, bottom: 120),
        onPressed: () => _shoot(crosshair.position),
      );
      camera.viewport.add(shootButton);

      // Dash Button for Joystick Mode
      final dashButton = HudButtonComponent(
        button: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue.withOpacity(0.5)),
        buttonDown: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
        margin: const EdgeInsets.only(right: 120, bottom: 40),
        onPressed: () => player.dash(),
      );
      camera.viewport.add(dashButton);
    }
    resumeEngine();
  }

  void _generateMap() {
    if (tilesSheet == null || selectedMapTheme == null) return;
    final theme = selectedMapTheme!;
    final batch = SpriteBatch(tilesSheet!.image);
    final random = Random();
    const double tileSize = 32.0;

    for (double x = 0; x < worldSize; x += tileSize) {
      for (double y = 0; y < worldSize; y += tileSize) {
        final chance = random.nextDouble();
        final sprite = tilesSheet!.getSprite(theme.floorRow, (chance < 0.85) ? theme.floorCol : theme.altCol);
        batch.add(source: sprite.src, offset: Vector2(x, y), scale: 2.0);

        if (chance > 0.992 && (Vector2(x, y).distanceTo(Vector2(worldSize / 2, worldSize / 2)) > 250)) {
          int obsId = theme.obstacleIds[random.nextInt(theme.obstacleIds.length)];
          world.add(Obstacle(tileId: obsId, position: Vector2(x, y), size: Vector2.all(tileSize * 1.5)));
        }
      }
    }
    world.add(SpriteBatchComponent(spriteBatch: batch));
    _addDecorations();
  }

  void _addDecorations() {
    // This is where you can add buildings or other complex structures
    // For example, adding a building at a specific location:
    final bPos = Vector2(worldSize / 2 + 200, worldSize / 2 + 200);
    
    // Example: adding a building SpriteComponent here...
    // world.add(building);

    world.add(Wall(
      position: Vector2(bPos.x, bPos.y),
      size: Vector2(192, 128), // 3x2 building footprint (3*64 x 2*64)
    ));
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (paused) return;
    crosshair.position = camera.globalToLocal(info.eventPosition.widget);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (paused) return;
    final pos = camera.globalToLocal(event.localPosition);
    crosshair.position = pos;
    _shoot(pos);
  }

  void _shoot(Vector2 target) {
    if (health <= 0 || paused || selectedWeapon == null || isReloading || _fireTimer > 0) return;
    if (ammo <= 0) return;

    final weapon = selectedWeapon!;
    ammo -= 1; 
    _fireTimer = 1 / weapon.fireRate;

    if (ammo <= 0) {
      reloadTimer = reloadDuration;
    }

    final baseDir = (target - player.position).normalized();
    world.add(Bullet(position: player.position.clone(), direction: baseDir, weapon: weapon));

    FlameAudio.play(weapon.shootSound, volume: 0.4);
  }

  void _addBoundaries() {
    final p = Paint()..color = Colors.transparent;
    world.add(RectangleComponent(position: Vector2(0, -10), size: Vector2(worldSize, 10), paint: p)..add(RectangleHitbox()));
    world.add(RectangleComponent(position: Vector2(0, worldSize), size: Vector2(worldSize, 10), paint: p)..add(RectangleHitbox()));
    world.add(RectangleComponent(position: Vector2(-10, 0), size: Vector2(10, worldSize), paint: p)..add(RectangleHitbox()));
    world.add(RectangleComponent(position: Vector2(worldSize, 0), size: Vector2(10, worldSize), paint: p)..add(RectangleHitbox()));
  }

  void spawnLoot(Vector2 pos) {
    final typeChance = Random().nextDouble();
    PickupType type = PickupType.coin;
    if (typeChance < 0.15) type = PickupType.heart;
    else if (typeChance < 0.3) type = PickupType.fireRateBoost;
    world.add(Pickup(type: type, position: pos));
  }

  void activateFireRateBoost() {}

  void playHurtSound() { 
    FlameAudio.play('hurt-a.ogg', volume: 0.6); 
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(4, 4), 
        EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 3),
      ),
    );
  }

  void playExplosionSound() { FlameAudio.play('explosion-a.ogg', volume: 0.3); }

  @override
  void update(double dt) {
    super.update(dt);
    if (health <= 0 && !paused) {
      pauseEngine(); FlameAudio.play('lose-a.ogg'); overlays.add('GameOver');
    }

    if (_fireTimer > 0) _fireTimer -= dt;

    // In Joystick mode, if moving, update crosshair to be in front of player
    if (controlMode == ControlMode.joystick && joystick != null && !joystick!.delta.isZero()) {
      crosshair.position = player.position + joystick!.relativeDelta * 200;
    }

    // Ammo Reloading
    if (reloadTimer > 0) {
      reloadTimer -= dt;
      if (reloadTimer <= 0) {
        ammo = maxAmmo;
      }
    }

    if (isWaveActive) {
      enemySpawner.update(dt);
      if (enemiesSpawnedInWave >= (5 + wave * 3) && world.children.whereType<Enemy>().isEmpty) {
        wave++; enemiesSpawnedInWave = 0; enemySpawner.limit = max(0.5, 2.0 - (wave * 0.1));
      }
    }
  }

  void _spawnEnemy() {
    if (enemiesSpawnedInWave >= (5 + wave * 3)) return;
    final vr = camera.visibleWorldRect;
    final side = Random().nextInt(4);
    Vector2 p;
    switch(side) {
      case 0: p = Vector2(vr.left + Random().nextDouble()*vr.width, vr.top - 100); break;
      case 1: p = Vector2(vr.right + 100, vr.top + Random().nextDouble()*vr.height); break;
      case 2: p = Vector2(vr.left + Random().nextDouble()*vr.width, vr.bottom + 100); break;
      default: p = Vector2(vr.left - 100, vr.top + Random().nextDouble()*vr.height); break;
    }
    p.x = p.x.clamp(0, worldSize); p.y = p.y.clamp(0, worldSize);
    world.add(Enemy(position: p, wave: wave));
    enemiesSpawnedInWave++;
  }
}
