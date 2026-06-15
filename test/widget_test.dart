import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugs_shooter/screens/main_menu.dart';
import 'package:bugs_shooter/game/bugs_shooter_game.dart';

void main() {
  testWidgets('Main Menu UI Smoke Test', (WidgetTester tester) async {
    final game = BugsShooterGame();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainMenu(game: game),
        ),
      ),
    );

    // Verify that the title "BUGS SHOOTER" is displayed
    expect(find.text('BUGS SHOOTER'), findsOneWidget);

    // Verify that the buttons for control mode options are present
    expect(find.text('JOYSTICK MODE'), findsOneWidget);
    expect(find.text('KEYBOARD MODE'), findsOneWidget);
  });
}
