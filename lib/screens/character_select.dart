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
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'SELECT YOUR SURVIVOR',
            style: TextStyle(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.greenAccent, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 5),
          const Text('Choose a character with unique attributes', style: TextStyle(color: Colors.white60, fontSize: 14)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                childAspectRatio: 0.65,
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
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green.withOpacity(0.18) : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.greenAccent : Colors.white12,
                        width: isSelected ? 5 : 2,
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 15)] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        Expanded(
                          flex: 3,
                          child: Image.asset(
                            'assets/images/${char.menuTilePath}',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          char.name,
                          style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 15),
                        _statRow('HP', char.maxHp / 5.0, Colors.redAccent),
                        _statRow('SPD', char.speedMultiplier / 1.3, Colors.blueAccent),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            char.ability.toUpperCase(),
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(height: 15),
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
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 10,
                ),
                onPressed: () {
                  FlameAudio.play('select-a.ogg');
                  widget.game.selectedCharacter = selected;
                  widget.game.overlays.remove('CharacterSelect');
                  widget.game.overlays.add('WeaponSelect');
                },
                child: const Text('CONFIRM SURVIVOR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: val,
              backgroundColor: Colors.white12,
              color: color,
              minHeight: 10, // Thicker stat bars
            ),
          ),
        ],
      ),
    );
  }
}
