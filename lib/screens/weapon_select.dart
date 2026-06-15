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
                  'ARSENAL SELECTION',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: Colors.blueAccent, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Choose your primary bug-slaying weapon',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
                
                // Weapon Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(25),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLandscape ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isLandscape ? 0.72 : 0.78,
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.white24,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Weapon Image Sprite
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    'assets/images/${w.tilePath}',
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Name
                              Text(
                                w.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              
                              // Stats section
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _statBar('DMG', w.damage / 10.0, Colors.redAccent),
                                    const SizedBox(height: 4),
                                    _statBar('SPD', w.bulletSpeed / 1700.0, Colors.blueAccent),
                                    const SizedBox(height: 4),
                                    _statBar('RAT', w.fireRate / 9.0, Colors.orangeAccent),
                                    const SizedBox(height: 6),
                                    Expanded(
                                      child: Text(
                                        w.description,
                                        style: const TextStyle(color: Colors.white60, fontSize: 9.5, fontFamily: 'monospace'),
                                        maxLines: 2,
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
                
                // Confirm Deploy Button
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, left: 40, right: 40),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                          ),
                          elevation: 8,
                          shadowColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                          FlameAudio.play('select-a.ogg');
                          widget.game.selectedWeapon = selected;
                          widget.game.overlays.remove('WeaponSelect');
                          widget.game.overlays.add('MapSelect'); // Route to battlefield selection
                        },
                        child: const Text(
                          'CONFIRM ARSENAL',
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

  Widget _statBar(String label, double ratio, Color color) {
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
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}

