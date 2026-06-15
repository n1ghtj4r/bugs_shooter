import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/bugs_shooter_game.dart';
import 'screens/main_menu.dart';
import 'screens/character_select.dart';
import 'screens/weapon_select.dart';
import 'screens/map_select.dart';
import 'screens/game_over.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bugs Shooter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: Scaffold(
        body: GameWidget<BugsShooterGame>(
          game: BugsShooterGame(),
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenu(game: game),
            'CharacterSelect': (context, game) => CharacterSelect(game: game),
            'WeaponSelect': (context, game) => WeaponSelect(game: game),
            'MapSelect': (context, game) => MapSelect(game: game),
            'GameOver': (context, game) => GameOver(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    );
  }
}

