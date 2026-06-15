import 'package:flutter/material.dart';

enum ControlMode { joystick, keyboard }

class MapThemeData {
  final int id;
  final String name;
  final String description;
  final Color themeColor;
  final int floorRow;
  final int floorCol;
  final int altCol;
  final List<int> obstacleIds;
  final List<int> hazardIds;
  final double enemySpeedMultiplier;

  MapThemeData({
    required this.id, required this.name, required this.description, 
    required this.themeColor, required this.floorRow, required this.floorCol,
    required this.altCol, required this.obstacleIds, required this.hazardIds,
    required this.enemySpeedMultiplier,
  });
}

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

final List<MapThemeData> allMaps = [
  MapThemeData(id: 0, name: 'Burning Sands', description: 'Scorching desert wasteland.', themeColor: Colors.orange, floorRow: 1, floorCol: 0, altCol: 1, obstacleIds: [38, 39], hazardIds: [41], enemySpeedMultiplier: 1.0),
  MapThemeData(id: 1, name: 'Emerald Jungle', description: 'Dense greenery and hidden dangers.', themeColor: Colors.green, floorRow: 3, floorCol: 2, altCol: 3, obstacleIds: [102, 103], hazardIds: [110], enemySpeedMultiplier: 1.1),
  MapThemeData(id: 2, name: 'Crystal Lagoon', description: 'Tropical shores and deep waters.', themeColor: Colors.cyan, floorRow: 0, floorCol: 2, altCol: 3, obstacleIds: [39, 40], hazardIds: [7], enemySpeedMultiplier: 0.9),
  MapThemeData(id: 3, name: 'Mystic Cavern', description: 'Subterranean alien dungeon.', themeColor: Colors.purple, floorRow: 0, floorCol: 0, altCol: 1, obstacleIds: [188], hazardIds: [201], enemySpeedMultiplier: 1.2),
];

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
