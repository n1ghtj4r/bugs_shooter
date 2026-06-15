import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Wall extends PositionComponent with HasGameRef {
  Wall({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
