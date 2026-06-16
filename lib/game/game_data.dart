import 'package:flutter/material.dart';

enum ControlMode { joystick, keyboard }

class BiomeData {
  final String name;
  final String description;
  final Color groundColor;
  final IconData icon;
  final String tmxFile;

  const BiomeData({
    required this.name,
    required this.description,
    required this.groundColor,
    required this.icon,
    required this.tmxFile,
  });
}

final List<BiomeData> allBiomes = [
  BiomeData(
    name: 'Burning Sands',
    description: 'Scorching desert wasteland.',
    groundColor: const Color(0xFFD4A96A),
    icon: Icons.wb_sunny,
    tmxFile: 'burning_sands.tmx',
  ),
  BiomeData(
    name: 'Emerald Jungle',
    description: 'Dense greenery and hidden dangers.',
    groundColor: const Color(0xFF4A7C59),
    icon: Icons.forest,
    tmxFile: 'emerald_jungle.tmx',
  ),
  BiomeData(
    name: 'Crystal Lagoon',
    description: 'Tropical shores and deep waters.',
    groundColor: const Color(0xFF2A7F8F),
    icon: Icons.pool,
    tmxFile: 'crystal_lagoon.tmx',
  ),
  BiomeData(
    name: 'Mystic Cavern',
    description: 'Subterranean alien dungeon.',
    groundColor: const Color(0xFF2D1B4E),
    icon: Icons.remove_red_eye,
    tmxFile: 'mystic_cavern.tmx',
  ),
];

class CharacterData {
  final int id;
  final String name;
  final int tileRow;
  final String menuTilePath;
  final double speedMultiplier;
  final int maxHp;
  final String ability;
  final String description;

  CharacterData({
    required this.id, required this.name, required this.tileRow, 
    required this.menuTilePath, required this.speedMultiplier, 
    required this.maxHp, required this.ability, required this.description,
  });
}

class WeaponData {
  final int id;
  final String name;
  final int tileId;
  final String tilePath;
  final double bulletSpeed;
  final double damage;
  final double fireRate;
  final int crosshairId;
  final String shootSound;
  final int spreadCount;
  final String description;
  final bool isLaser;

  WeaponData({
    required this.id, required this.name, required this.tileId, 
    required this.tilePath, required this.bulletSpeed, required this.damage, 
    required this.fireRate, required this.crosshairId, required this.shootSound,
    required this.description, this.spreadCount = 1, this.isLaser = false,
  });
}

final List<CharacterData> allCharacters = [
  CharacterData(id: 0, name: 'Fox', tileRow: 0, menuTilePath: 'Players/Tiles/tile_0000.png', speedMultiplier: 1.2, maxHp: 3, ability: 'Lightning Dash', description: 'Extremely fast. Dash cooldown is 30% faster.'),
  CharacterData(id: 1, name: 'Monkey', tileRow: 1, menuTilePath: 'Players/Tiles/tile_0004.png', speedMultiplier: 1.0, maxHp: 4, ability: 'Double Tap', description: 'Higher health. Weapons have faster fire rate.'),
  CharacterData(id: 2, name: 'Mouse', tileRow: 2, menuTilePath: 'Players/Tiles/tile_0008.png', speedMultiplier: 1.1, maxHp: 3, ability: 'Loot Magnet', description: 'Small target. Pulls in loot from further away.'),
  CharacterData(id: 3, name: 'Rabbit', tileRow: 3, menuTilePath: 'Players/Tiles/tile_0012.png', speedMultiplier: 0.9, maxHp: 5, ability: 'Heavy Armor', description: 'Tank class. Starts with 5 HP but moves slower.'),
];

final List<WeaponData> allWeapons = [
  WeaponData(id: 0, name: 'Pistol', tileId: 0, tilePath: 'Weapons/Tiles/tile_0000.png', bulletSpeed: 800, damage: 3.5, fireRate: 3.5, crosshairId: 23, shootSound: 'shoot-a.ogg', description: 'Reliable sidearm.'),
  WeaponData(id: 1, name: 'Shotgun', tileId: 1, tilePath: 'Weapons/Tiles/tile_0001.png', bulletSpeed: 600, damage: 15.0, fireRate: 1.2, crosshairId: 20, shootSound: 'shoot-b.ogg', description: 'Devastating close-range burst.'),
  WeaponData(id: 2, name: 'Uzi', tileId: 2, tilePath: 'Weapons/Tiles/tile_0002.png', bulletSpeed: 1000, damage: 1.5, fireRate: 10.0, crosshairId: 26, shootSound: 'shoot-c.ogg', description: 'High fire-rate submachine gun.'),
  WeaponData(id: 3, name: 'Sniper', tileId: 3, tilePath: 'Weapons/Tiles/tile_0003.png', bulletSpeed: 2200, damage: 25.0, fireRate: 0.6, crosshairId: 25, shootSound: 'shoot-d.ogg', description: 'Long range armor-piercing rifle.'),
  WeaponData(id: 4, name: 'Rifle', tileId: 4, tilePath: 'Weapons/Tiles/tile_0004.png', bulletSpeed: 1200, damage: 4.0, fireRate: 6.0, crosshairId: 24, shootSound: 'shoot-e.ogg', description: 'Balanced assault combat rifle.'),
  WeaponData(id: 5, name: 'Blaster', tileId: 5, tilePath: 'Weapons/Tiles/tile_0005.png', bulletSpeed: 950, damage: 6.5, fireRate: 2.5, crosshairId: 22, shootSound: 'shoot-f.ogg', isLaser: true, description: 'Fires large plasma energy balls.'),
  WeaponData(id: 6, name: 'Heavy MG', tileId: 6, tilePath: 'Weapons/Tiles/tile_0006.png', bulletSpeed: 900, damage: 3.0, fireRate: 8.5, crosshairId: 21, shootSound: 'shoot-g.ogg', description: 'Rapid suppression machine gun.'),
  WeaponData(id: 7, name: 'Hand Cannon', tileId: 7, tilePath: 'Weapons/Tiles/tile_0007.png', bulletSpeed: 1100, damage: 10.0, fireRate: 1.0, crosshairId: 28, shootSound: 'shoot-h.ogg', description: 'Classic heavy impact handgun.'),
];

class ScoreEntry {
  final int score;
  final int wave;
  final DateTime date;

  ScoreEntry({required this.score, required this.wave, required this.date});
}

class LeaderboardManager {
  static final List<ScoreEntry> _entries = [];

  static List<ScoreEntry> get entries => List.unmodifiable(_entries);

  static void addEntry(int score, int wave) {
    _entries.add(ScoreEntry(score: score, wave: wave, date: DateTime.now()));
    _entries.sort((a, b) => b.score.compareTo(a.score));
    if (_entries.length > 10) {
      _entries.removeRange(10, _entries.length);
    }
  }
}
