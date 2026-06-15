import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';

class GameOver extends StatelessWidget {
  final BugsShooterGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final themeColor = game.selectedMapTheme?.themeColor ?? Colors.red;
    
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final spacing = isLandscape ? 30.0 : 20.0;
            
            return Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: isLandscape ? 580 : 380),
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.25), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Danger/Death Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent, width: 2),
                      ),
                      child: const Icon(
                        Icons.dangerous,
                        size: 40,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: spacing),
                    
                    // Game Over Text
                    const Text(
                      'MISSION FAILED',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.red),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your survivor was overrun by the bugs.',
                      style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'monospace'),
                    ),
                    
                    SizedBox(height: spacing * 1.5),
                    
                    // Scoreboard panel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: Column(
                        children: [
                          _statsRow('FINAL SCORE', '${game.score}', Colors.white),
                          const Divider(color: Colors.white10, height: 20),
                          _statsRow('WAVES SURVIVED', '${game.wave - 1}', Colors.orangeAccent),
                          const Divider(color: Colors.white10, height: 20),
                          _statsRow('ACTIVE MAP', game.selectedMapTheme?.name.toUpperCase() ?? 'DESERT', themeColor),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: spacing * 1.5),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(color: Colors.greenAccent, width: 1),
                              ),
                            ),
                            onPressed: () {
                              FlameAudio.play('select-a.ogg');
                              game.overlays.remove('GameOver');
                              game.startNewGame();
                            },
                            child: const Text(
                              'RETRY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              FlameAudio.play('select-a.ogg');
                              game.overlays.remove('GameOver');
                              game.overlays.add('MainMenu');
                            },
                            child: const Text(
                              'MAIN MENU',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _statsRow(String label, String value, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

