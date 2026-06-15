import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';
import '../game/game_data.dart';

class MapSelect extends StatefulWidget {
  final BugsShooterGame game;
  const MapSelect({super.key, required this.game});

  @override
  State<MapSelect> createState() => _MapSelectState();
}

class _MapSelectState extends State<MapSelect> {
  MapThemeData? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            'SELECT BIOME',
            style: TextStyle(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(40),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                childAspectRatio: 1.1,
              ),
              itemCount: allMaps.length,
              itemBuilder: (context, index) {
                final map = allMaps[index];
                final isSelected = selected == map;
                return GestureDetector(
                  onTap: () {
                    FlameAudio.play('select-a.ogg');
                    setState(() => selected = map);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? map.themeColor.withOpacity(0.3) : Colors.white10,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? map.themeColor : Colors.white24,
                        width: 4,
                      ),
                      boxShadow: isSelected 
                        ? [BoxShadow(color: map.themeColor.withOpacity(0.4), blurRadius: 20)] 
                        : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIconForBiome(map.id),
                          size: 60,
                          color: isSelected ? map.themeColor : Colors.white60,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          map.name,
                          style: TextStyle(
                            fontSize: 22,
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            map.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected!.themeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  FlameAudio.play('select-a.ogg');
                  widget.game.selectedMapTheme = selected;
                  widget.game.overlays.remove('MapSelect');
                  widget.game.startNewGame();
                },
                child: const Text(
                  'CONFIRM BIOME',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForBiome(int id) {
    switch (id) {
      case 0: return Icons.wb_sunny;
      case 1: return Icons.forest;
      case 2: return Icons.pool;
      case 3: return Icons.visibility;
      default: return Icons.map;
    }
  }
}
