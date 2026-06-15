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
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final spacing = isLandscape ? 40.0 : 25.0;
            
            return Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: isLandscape ? 700 : 420),
                padding: const EdgeInsets.all(35.0),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.15), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Game Logo / Icon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orangeAccent, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bug_report,
                        size: 55,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    SizedBox(height: spacing),
                    
                    // Game Title
                    const Text(
                      'BUGS SHOOTER',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.orangeAccent,
                        fontFamily: 'monospace',
                        letterSpacing: 3,
                        shadows: [
                          Shadow(blurRadius: 15, color: Colors.orange),
                          Shadow(blurRadius: 30, color: Colors.deepOrange),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'A Top-Down Procedural Survival Shooter',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: spacing * 1.5),
                    
                    // Controls Heading
                    const Text(
                      'SELECT CONTROL INTERFACE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Modes Buttons
                    if (isLandscape)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _btn(context, 'JOYSTICK MODE', ControlMode.joystick, Icons.videogame_asset)),
                          const SizedBox(width: 20),
                          Expanded(child: _btn(context, 'KEYBOARD MODE', ControlMode.keyboard, Icons.keyboard)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _btn(context, 'JOYSTICK MODE', ControlMode.joystick, Icons.videogame_asset),
                          const SizedBox(height: 15),
                          _btn(context, 'KEYBOARD MODE', ControlMode.keyboard, Icons.keyboard),
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

  Widget _btn(BuildContext context, String label, ControlMode mode, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade900.withOpacity(0.85),
        foregroundColor: Colors.white,
        shadowColor: Colors.orangeAccent.withOpacity(0.5),
        elevation: 6,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
        ),
      ),
      onPressed: () {
        FlameAudio.play('select-a.ogg');
        game.controlMode = mode;
        game.overlays.remove('MainMenu');
        game.overlays.add('CharacterSelect');
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

