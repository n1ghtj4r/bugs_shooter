import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';
import '../game/game_data.dart';

class CharacterSelect extends StatefulWidget {
  final BugsShooterGame game;
  const CharacterSelect({super.key, required this.game});

  @override
  State<CharacterSelect> createState() => _CharacterSelectState();
}

class _CharacterSelectState extends State<CharacterSelect> {
  CharacterData? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            
            return Column(
              children: [
                const SizedBox(height: 30),
                // Screen Title
                const Text(
                  'SELECT YOUR SURVIVOR',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.greenAccent, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose a character with unique attributes',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
                
                // Character List / Details
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(30),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isLandscape ? 0.70 : 0.76,
                    ),
                    itemCount: allCharacters.length,
                    itemBuilder: (context, index) {
                      final char = allCharacters[index];
                      final isSelected = selected == char;
                      
                      return GestureDetector(
                        onTap: () {
                          FlameAudio.play('select-a.ogg');
                          setState(() => selected = char);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? Colors.greenAccent : Colors.white24,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Character Image Sprite
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/images/${char.menuTilePath}',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Name
                              Text(
                                char.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              
                              // Mini Stats
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _statRow('HP', char.maxHp / 5.0, Colors.redAccent),
                                    const SizedBox(height: 4),
                                    _statRow('SPD', char.speedMultiplier / 1.3, Colors.blueAccent),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Text(
                                        char.description,
                                        style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Confirm Button
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, left: 40, right: 40),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.greenAccent, width: 1.5),
                          ),
                          elevation: 8,
                          shadowColor: Colors.greenAccent,
                        ),
                        onPressed: () {
                          FlameAudio.play('select-a.ogg');
                          widget.game.selectedCharacter = selected;
                          widget.game.overlays.remove('CharacterSelect');
                          widget.game.overlays.add('WeaponSelect');
                        },
                        child: const Text(
                          'CONFIRM SELECTION',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statRow(String label, double ratio, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 25,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, fontFamily: 'monospace'),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

