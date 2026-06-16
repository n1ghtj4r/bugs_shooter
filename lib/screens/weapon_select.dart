import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';
import '../game/game_data.dart';

class WeaponSelect extends StatefulWidget {
  final BugsShooterGame game;
  const WeaponSelect({super.key, required this.game});

  @override
  State<WeaponSelect> createState() => _WeaponSelectState();
}

class _WeaponSelectState extends State<WeaponSelect> {
  WeaponData? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'ARSENAL SELECTION',
            style: TextStyle(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: Colors.blueAccent, blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 5),
          const Text('Choose your primary offensive bug-slaying tool', style: TextStyle(color: Colors.white60, fontSize: 14)),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.72,
              ),
              itemCount: allWeapons.length,
              itemBuilder: (context, index) {
                final w = allWeapons[index];
                final isSelected = selected == w;
                return GestureDetector(
                  onTap: () {
                    FlameAudio.play('select-a.ogg');
                    setState(() => selected = w);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.18) : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Colors.blueAccent : Colors.white12,
                        width: isSelected ? 5 : 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Image.asset(
                              'assets/images/${w.tilePath}',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                        ),
                        Text(
                          w.name,
                          style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        _stat('DMG', w.damage / 25.0, Colors.redAccent),
                        _stat('RAT', w.fireRate / 10.0, Colors.greenAccent),
                        _stat('SPD', w.bulletSpeed / 2000.0, Colors.blueAccent),
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
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 10,
                ),
                onPressed: () {
                  FlameAudio.play('select-a.ogg');
                  widget.game.selectedWeapon = selected;
                  widget.game.overlays.remove('WeaponSelect');
                  widget.game.overlays.add('MapSelect');
                },
                child: const Text('DEPLOY ARSENAL', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              backgroundColor: Colors.white12,
              color: color,
              minHeight: 8, // Thicker stat bars
            ),
          ),
        ],
      ),
    );
  }
}
