import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/bugs_shooter_game.dart';
import '../game/game_data.dart';

class MainMenu extends StatelessWidget {
  final BugsShooterGame game;
  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Center(
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.05), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'BUGS SHOOTER',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: Colors.orangeAccent,
                  letterSpacing: 2,
                  shadows: [Shadow(blurRadius: 15, color: Colors.orange)],
                ),
              ),
              const Text(
                'A Top-Down Procedural Survival Shooter',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 50),
              const Text(
                'SELECT CONTROL INTERFACE',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _btn(
                      context,
                      'JOYSTICK',
                      ControlMode.joystick,
                      Icons.videogame_asset,
                      'MOVE: JOYSTICK\nSHOOT: ATTACK BTN\nDASH: DASH BTN',
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: _btn(
                      context,
                      'KEYBOARD',
                      ControlMode.keyboard,
                      Icons.keyboard,
                      'MOVE: WASD KEYS\nSHOOT: MOUSE CLICK\nDASH: SPACEBAR',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: () {
                  FlameAudio.play('select-a.ogg');
                  game.overlays.remove('MainMenu');
                  game.overlays.add('Leaderboard');
                },
                icon: const Icon(Icons.leaderboard, color: Colors.orangeAccent, size: 24),
                label: const Text(
                  'VIEW HALL OF FAME',
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, String label, ControlMode mode, IconData icon, String manual) {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22),
            minimumSize: const Size(double.infinity, 70),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 10,
          ),
          onPressed: () {
            FlameAudio.play('select-a.ogg');
            game.controlMode = mode;
            game.overlays.remove('MainMenu');
            game.overlays.add('CharacterSelect');
          },
          icon: Icon(icon, size: 28),
          label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            manual,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
