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
  BiomeData? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F12),
              image: DecorationImage(
                image: AssetImage('assets/images/Tiles/Tiles/tile_0154.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.05,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'SELECT BATTLEFIELD',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Colors.orangeAccent, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Choose the terrain for your procedural survival mission', style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = constraints.maxWidth > constraints.maxHeight;
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLandscape ? 4 : 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: isLandscape ? 0.9 : 0.85,
                        ),
                        itemCount: allBiomes.length,
                        itemBuilder: (context, index) {
                          final biome = allBiomes[index];
                          final isSelected = selected == biome;
                          return _biomeCard(biome, isSelected);
                        },
                      );
                    },
                  ),
                ),
                // Footer
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected!.groundColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 10,
                        ),
                        onPressed: () {
                          FlameAudio.play('select-a.ogg');
                          widget.game.selectedBiome = selected;
                          widget.game.overlays.remove('MapSelect');
                          widget.game.startNewGame();
                        },
                        child: const Text('CONFIRM BATTLEFIELD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: () {
                FlameAudio.play('select-a.ogg');
                widget.game.overlays.remove('MapSelect');
                widget.game.overlays.add('WeaponSelect');
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _biomeCard(BiomeData biome, bool isSelected) {
    return GestureDetector(
      onTap: () {
        FlameAudio.play('select-a.ogg');
        setState(() => selected = biome);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? biome.groundColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? biome.groundColor : Colors.white10,
            width: isSelected ? 4 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(color: biome.groundColor.withOpacity(0.3), blurRadius: 20)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(biome.icon, size: 40, color: isSelected ? Colors.white : Colors.white54),
            ),
            const SizedBox(height: 15),
            Text(biome.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                biome.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
