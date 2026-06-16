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
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      const Text('Choose the terrain for your procedural survival mission', 
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 20),
                      
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isLandscape = constraints.maxWidth > 500;
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 900),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLandscape ? 4 : 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: isLandscape ? 0.8 : 0.9,
                              ),
                              itemCount: allBiomes.length,
                              itemBuilder: (context, index) {
                                final biome = allBiomes[index];
                                final isSelected = selected == biome;
                                return _biomeCard(biome, isSelected);
                              },
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      if (selected != null)
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    ],
                  ),
                ),
              ),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? biome.groundColor : Colors.white10,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(color: biome.groundColor.withOpacity(0.3), blurRadius: 15)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(biome.icon, size: 36, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(height: 10),
            Text(biome.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                biome.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
