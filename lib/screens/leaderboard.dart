import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';
import '../game/game_data.dart';

class LeaderboardScreen extends StatelessWidget {
  final BugsShooterGame game;
  const LeaderboardScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final entries = LeaderboardManager.entries;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.25), width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'HALL OF FAME',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.orangeAccent,
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: entries.isEmpty
                      ? const Center(
                          child: Text(
                            'NO RECORDS YET',
                            style: TextStyle(color: Colors.white54, fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: index == 0 ? Colors.orangeAccent : Colors.white12,
                                  width: index == 0 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      color: index == 0 ? Colors.orangeAccent : Colors.white70,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SCORE: ${entry.score}',
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'WAVE: ${entry.wave}',
                                          style: const TextStyle(color: Colors.white54, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${entry.date.day}/${entry.date.month}',
                                    style: const TextStyle(color: Colors.white24, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    FlameAudio.play('select-a.ogg');
                    game.overlays.remove('Leaderboard');
                    game.overlays.add('MainMenu');
                  },
                  child: const Text('BACK TO MENU', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
