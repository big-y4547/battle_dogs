
import 'lib.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/Register.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'level',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LevelPage(title: 'level'),
    );
  }
}

class LevelPage extends StatefulWidget {
  const LevelPage({super.key, required String title});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/level.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
