import "package:flame/game.dart";
import 'package:flutter/material.dart';
class BattleDogLevel extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load your level assets and initialize the level here
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render your level elements here
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update your level logic here
  }
} 