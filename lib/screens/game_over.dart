import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';

class GameOver extends StatelessWidget {
  final BugsShooterGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final themeColor = game.selectedBiome?.groundColor ?? Colors.red;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Overlay
          Container(color: Colors.black.withOpacity(0.85)),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  
                  return Container(
                    width: isLandscape ? 580 : 380,
                    padding: const EdgeInsets.all(35),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent, width: 2),
                          ),
                          child: const Icon(Icons.dangerous, size: 45, color: Colors.redAccent),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'MISSION FAILED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            letterSpacing: 2,
                            shadows: [Shadow(blurRadius: 15, color: Colors.red)],
                          ),
                        ),
                        const Text(
                          'Your survivor was overrun by the bugs.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 35),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              _statsRow('FINAL SCORE', '${game.score}', Colors.white),
                              const Divider(color: Colors.white10, height: 25),
                              _statsRow('WAVES SURVIVED', '${game.wave - 1}', Colors.orangeAccent),
                              const Divider(color: Colors.white10, height: 25),
                              _statsRow('BATTLEFIELD', game.selectedBiome?.name.toUpperCase() ?? 'N/A', themeColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  FlameAudio.play('select-a.ogg');
                                  game.overlays.remove('GameOver');
                                  game.startNewGame();
                                },
                                child: const Text('RETRY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  FlameAudio.play('select-a.ogg');
                                  game.overlays.remove('GameOver');
                                  game.overlays.add('MainMenu');
                                },
                                child: const Text('MENU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
