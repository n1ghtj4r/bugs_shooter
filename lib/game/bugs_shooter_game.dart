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
import 'package:flame_tiled/flame_tiled.dart';
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
    } else if (gameRef.interfaceSheet != null) {
      sprite = gameRef.interfaceSheet!.getSpriteById(132);
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
  }
}

class BugsShooterGame extends FlameGame 
    with HasCollisionDetection, TapCallbacks, DragCallbacks, HasKeyboardHandlerComponents, MouseMovementDetector {
  
  static const double worldSize = 2048.0; 
  late Player player;
  late Hud hud;
  late Crosshair crosshair;
  JoystickComponent? joystick;
  late Timer enemySpawner;
  
  ControlMode controlMode = ControlMode.joystick;
  CharacterData? selectedCharacter;
  WeaponData? selectedWeapon;
  BiomeData? selectedBiome;
  
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

  Set<String> collectedLetters = {};
  double powerUpMultiplier = 1.0;
  double powerUpTimer = 0;

  SpriteSheet? playerSheet, enemySheet, weaponsSheet, tilesSheet, interfaceSheet;
  Sprite? warningSeeSprite, approachingWarningSprite, bulletIconSprite, bulletShotgunSprite, skullEnemySprite, skullHeroSprite;
  Sprite? spriteB, spriteU, spriteG, spriteS;

  late TiledComponent mapComponent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    playerSheet = SpriteSheet(image: await images.load('Players/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    enemySheet = SpriteSheet(image: await images.load('Enemies/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    weaponsSheet = SpriteSheet(image: await images.load('Weapons/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(24));
    tilesSheet = SpriteSheet(image: await images.load('Tiles/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(16));
    interfaceSheet = SpriteSheet(image: await images.load('Interface/Tilemap/tilemap_packed.png'), srcSize: Vector2.all(16));

    warningSeeSprite = Sprite(await images.load('Interface/Tiles/warning_see_enemy.png'));
    approachingWarningSprite = Sprite(await images.load('Interface/Tiles/approaching_enemy_warning.png'));
    bulletIconSprite = Sprite(await images.load('Interface/Tiles/bullet_rifle.png'));
    bulletShotgunSprite = Sprite(await images.load('Interface/Tiles/bullet_shotgun.png'));
    skullEnemySprite = Sprite(await images.load('Interface/Tiles/skull_enemy.png'));
    skullHeroSprite = Sprite(await images.load('Interface/Tiles/skull_hero.png'));

    spriteB = Sprite(await images.load('Interface/Tiles/B.png'));
    spriteU = Sprite(await images.load('Interface/Tiles/U.png'));
    spriteG = Sprite(await images.load('Interface/Tiles/G.png'));
    spriteS = Sprite(await images.load('Interface/Tiles/S.png'));

    // Use the full screen size for the camera to avoid black bars on mobile
    camera = CameraComponent(world: world);
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

  void startNewGame() async {
    score = 0;
    health = selectedCharacter?.maxHp ?? 3;
    ammo = maxAmmo;
    reloadTimer = 0;
    wave = 1;
    enemiesSpawnedInWave = 0;
    isWaveActive = true;
    enemySpawner.limit = 2.0;
    collectedLetters.clear();
    powerUpMultiplier = 1.0;
    powerUpTimer = 0;

    world.children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<Bullet>().forEach((b) => b.removeFromParent());
    world.children.whereType<Player>().forEach((p) => p.removeFromParent());
    world.children.whereType<TiledComponent>().forEach((m) => m.removeFromParent());
    world.children.whereType<Wall>().forEach((w) => w.removeFromParent());
    world.children.whereType<Pickup>().forEach((p) => p.removeFromParent());

    try {
      await _loadMap();
      _addTileCollisions();
    } catch (e) {
      debugPrint('Error loading map: $e');
    }

    player = Player();
    player.position = Vector2(worldSize / 2, worldSize / 2);
    world.add(player);
    camera.follow(player);

    if (weaponsSheet != null && selectedWeapon != null) {
      crosshair.updateSprite();
    }

    camera.viewport.children.whereType<JoystickComponent>().forEach((j) => j.removeFromParent());
    camera.viewport.children.whereType<HudButtonComponent>().forEach((b) => b.removeFromParent());

    if (controlMode == ControlMode.joystick) {
      joystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white60),
        background: CircleComponent(radius: 50, paint: Paint()..color = Colors.black38),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
      camera.viewport.add(joystick!);

      final shootButton = HudButtonComponent(
        button: CircleComponent(radius: 35, paint: Paint()..color = Colors.red.withOpacity(0.5)),
        buttonDown: CircleComponent(radius: 35, paint: Paint()..color = Colors.red),
        margin: const EdgeInsets.only(right: 40, bottom: 120),
        onPressed: () => _shoot(crosshair.position),
      );
      shootButton.add(TextComponent(
        text: 'ATTACK',
        anchor: Anchor.center,
        position: Vector2(35, 35),
        textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ));
      camera.viewport.add(shootButton);

      final dashButton = HudButtonComponent(
        button: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue.withOpacity(0.5)),
        buttonDown: CircleComponent(radius: 30, paint: Paint()..color = Colors.blue),
        margin: const EdgeInsets.only(right: 120, bottom: 40),
        onPressed: () => player.dash(),
      );
      dashButton.add(TextComponent(
        text: 'DASH',
        anchor: Anchor.center,
        position: Vector2(30, 30),
        textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ));
      camera.viewport.add(dashButton);
    }
    
    _showWavePopup();
    resumeEngine();
  }

  Future<void> _loadMap() async {
    final tmxFile = selectedBiome?.tmxFile ?? 'burning_sands.tmx';
    // Use proper assets prefix for Tiled
    mapComponent = await TiledComponent.load(
      tmxFile,
      Vector2.all(16),
    );
    mapComponent.scale = Vector2.all(4.0);
    world.add(mapComponent);
  }

  void _addTileCollisions() {
    final stoneLayer = mapComponent.tileMap.getLayer<TileLayer>('stone');
    if (stoneLayer == null) return;

    final tileSize = 16.0 * 4.0;

    for (int row = 0; row < 32; row++) {
      for (int col = 0; col < 32; col++) {
        final tile = stoneLayer.tileData![row][col];
        if (tile.tile != 0) {
          world.add(Wall(
            position: Vector2(col * tileSize, row * tileSize),
            size: Vector2.all(tileSize),
          ));
        }
      }
    }
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
    final bullet = Bullet(position: player.position.clone(), direction: baseDir, weapon: weapon);
    
    if (powerUpMultiplier > 1.0) {
      bullet.add(ColorEffect(Colors.yellow, EffectController(duration: 0.1), opacityTo: 0.5));
    }
    
    world.add(bullet);
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
    final types = [PickupType.b, PickupType.u, PickupType.g, PickupType.s];
    final type = types[Random().nextInt(types.length)];
    world.add(Pickup(type: type, position: pos));
  }

  void collectLetter(String letter) {
    collectedLetters.add(letter);
    if (collectedLetters.length >= 4) {
      collectedLetters.clear();
      powerUpMultiplier = 2.0;
      powerUpTimer = 10.0;
      health = min(health + 1, selectedCharacter?.maxHp ?? 5);
      
      final msg = TextComponent(
        text: 'BUGS POWER UP!',
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 - 100),
        textRenderer: TextPaint(style: const TextStyle(color: Colors.greenAccent, fontSize: 40, fontWeight: FontWeight.bold)),
      );
      camera.viewport.add(msg);
      msg.add(RemoveEffect(delay: 2.0));
      FlameAudio.play('coin-a.ogg', volume: 0.8);
    }
  }

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
      pauseEngine();
      LeaderboardManager.addEntry(score, wave);
      FlameAudio.play('lose-a.ogg');
      overlays.add('GameOver');
    }

    if (_fireTimer > 0) _fireTimer -= dt;

    if (controlMode == ControlMode.joystick && joystick != null && !joystick!.delta.isZero()) {
      crosshair.position = player.position + joystick!.relativeDelta * 200;
    }

    if (reloadTimer > 0) {
      reloadTimer -= dt;
      if (reloadTimer <= 0) {
        ammo = maxAmmo;
      }
    }

    if (isWaveActive) {
      enemySpawner.update(dt);
      if (enemiesSpawnedInWave >= (5 + wave * 5) && world.children.whereType<Enemy>().isEmpty) {
        wave++;
        enemiesSpawnedInWave = 0;
        enemySpawner.limit = max(0.4, 2.0 - (wave * 0.15));
        _showWavePopup();
      }
    }

    if (powerUpTimer > 0) {
      powerUpTimer -= dt;
      if (powerUpTimer <= 0) {
        powerUpMultiplier = 1.0;
      }
    }
  }

  void _showWavePopup() {
    final text = TextComponent(
      text: 'WAVE $wave',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 64,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          shadows: [Shadow(blurRadius: 20, color: Colors.black)],
        ),
      ),
    );
    camera.viewport.add(text);
    text.add(ScaleEffect.to(Vector2.all(1.5), EffectController(duration: 0.5, reverseDuration: 0.5)));
    text.add(RemoveEffect(delay: 2.5));
    FlameAudio.play('select-a.ogg', volume: 0.5);
  }

  void _spawnEnemy() {
    final maxInWave = 5 + (wave * 5);
    if (enemiesSpawnedInWave >= maxInWave) return;
    
    final vr = camera.visibleWorldRect;
    final side = Random().nextInt(4);
    Vector2 p;
    switch(side) {
      case 0: p = Vector2(vr.left + Random().nextDouble()*vr.width, vr.top - 150); break;
      case 1: p = Vector2(vr.right + 150, vr.top + Random().nextDouble()*vr.height); break;
      case 2: p = Vector2(vr.left + Random().nextDouble()*vr.width, vr.bottom + 150); break;
      default: p = Vector2(vr.left - 150, vr.top + Random().nextDouble()*vr.height); break;
    }
    
    if (p.x.isNaN || p.y.isNaN) p = player.position + Vector2(200, 200);

    p.x = p.x.clamp(0, worldSize); 
    p.y = p.y.clamp(0, worldSize);

    world.add(Enemy(position: p, wave: wave));
    enemiesSpawnedInWave++;
  }
}
