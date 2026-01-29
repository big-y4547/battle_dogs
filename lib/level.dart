
import 'package:flame/flame.dart';

import 'lib.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/Register.dart';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(GameWidget(game: Level()));
}

class Level extends FlameGame with TapCallbacks {
  late TextComponent moneyText;
  late TextComponent baseHealthText;
  late RectangleComponent playerBase;
  late RectangleComponent enemyBase;
  
  int money = 150;
  int baseHealth = 100;
  int enemyBaseHealth = 100;
  
  final List<DogUnit> playerUnits = [];
  final List<DogUnit> enemyUnits = [];
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Player base
    playerBase = RectangleComponent(
      position: Vector2(20, size.y / 2 + 170),
      size: Vector2(40, 100),
      paint: Paint()..color = Colors.blue,
    );
    add(playerBase);
    
    // Enemy base
    enemyBase = RectangleComponent(
      position: Vector2(size.x - 60, size.y / 2 + 170),
      size: Vector2(40, 100),
      paint: Paint()..color = Colors.red,
    );
    add(enemyBase);
    
    // Ground
    add(RectangleComponent(
      position: Vector2(0, size.y - 80),
      size: Vector2(size.x, 80),
      paint: Paint()..color = const Color(0xFF8B7355),
    ));
    
    // Money display
    moneyText = TextComponent(
      text: 'Money: $money',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
    add(moneyText);
    
    // Base health display
    baseHealthText = TextComponent(
      text: 'Base: $baseHealth HP',
      position: Vector2(10, 35),
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
    add(baseHealthText);
    
    // Spawn buttons
    final dogTypes = ['Corgi', 'Husky', 'Bulldog'];
    final costs = [50, 100, 150];
    
    for (int i = 0; i < dogTypes.length; i++) {
      add(DogButton(
        position: Vector2(10 + i * 120, size.y - 60),
        dogType: dogTypes[i],
        cost: costs[i],
        game: this,
      ));
    }
    
    // Start enemy spawner
    add(TimerComponent(
      period: 10,
      repeat: true,
      onTick: spawnEnemy,
    ));
    
    // Money generator
    add(TimerComponent(
      period: 0.2,
      repeat: true,
      onTick: () => updateMoney(10),
    ));
  }
  
  void spawnPlayerDog(String type) {
    int cost = type == 'Corgi' ? 50 : type == 'Husky' ? 100 : 150;
    
    if (money >= cost) {
      money -= cost;
      moneyText.text = 'Money: $money';
      
      final dog = DogUnit(
        position: Vector2(80, size.y - 120),
        dogType: type,
        isPlayer: true,
        game: this,
      );
      playerUnits.add(dog);
      add(dog);
    }
  }
  
  void spawnEnemy() {
    final types = ['Corgi', 'Husky', 'Bulldog'];
    final type = types[Random().nextInt(types.length)];
    
    final dog = DogUnit(
      position: Vector2(size.x - 80, size.y - 120),
      dogType: type,
      isPlayer: false,
      game: this,
    );
    enemyUnits.add(dog);
    add(dog);
  }
  
  void updateMoney(int amount) {
    money += amount;
    moneyText.text = 'Money: $money';
  }
  
  void damageBase(int damage, bool isPlayerBase) {
    if (isPlayerBase) {
      baseHealth -= damage;
      baseHealthText.text = 'Base: $baseHealth HP';
      if (baseHealth <= 0) {
        gameOver(false);
      }
    } else {
      enemyBaseHealth -= damage;
      if (enemyBaseHealth <= 0) {
        gameOver(true);
      }
    }
  }
  
  void gameOver(bool playerWon) {
    pauseEngine();
    add(TextComponent(
      text: playerWon ? 'YOU WIN!' : 'GAME OVER',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: playerWon ? Colors.green : Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }
}

class DogButton extends PositionComponent with TapCallbacks {
  final String dogType;
  final int cost;
  final Level game;
  
  DogButton({
    required Vector2 position,
    required this.dogType,
    required this.cost,
    required this.game,
  }) : super(position: position, size: Vector2(100, 40));
  
  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF4CAF50),
    ));
    
    add(TextComponent(
      text: '$dogType\n\$$cost',
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    ));
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    game.spawnPlayerDog(dogType);
  }
}

class DogUnit extends PositionComponent with HasGameReference<Level> {
  final String dogType;
  final bool isPlayer;
  final Level game;
  
  late double speed;
  late int health;
  late int maxHealth;
  late int damage;
  late double attackRange;
  late double attackCooldown;
  
  double currentCooldown = 0;
  bool isAttacking = false;
  double attackAnimationTime = 0;
  DogUnit? target;
  
  DogUnit({
    required Vector2 position,
    required this.dogType,
    required this.isPlayer,
    required this.game,
  }) : super(position: position, size: Vector2(50, 40)) {
    _initStats();
  }
  
  void _initStats() {
    switch (dogType) {
      case 'Corgi':
        speed = 30;
        health = maxHealth = 50;
        damage = 10;
        attackRange = 60;
        attackCooldown = 1.0;
        break;
      case 'Husky':
        speed = 50;
        health = maxHealth = 80;
        damage = 15;
        attackRange = 70;
        attackCooldown = 1.2;
        break;
      case 'Bulldog':
        speed = 20;
        health = maxHealth = 120;
        damage = 25;
        attackRange = 65;
        attackCooldown = 1.5;
        break;
    }
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Body
    add(RectangleComponent(
      size: Vector2(30, 20),
      position: Vector2(10, 10),
      paint: Paint()..color = isPlayer ? Colors.blue : Colors.red,
    ));
    
    // Head
    add(CircleComponent(
      radius: 8,
      position: Vector2(isPlayer ? 38 : 12, 15),
      paint: Paint()..color = isPlayer ? Colors.lightBlue : Colors.pink,
    ));
    
    // Legs
    for (int i = 0; i < 2; i++) {
      add(RectangleComponent(
        size: Vector2(5, 10),
        position: Vector2(15 + i * 15, 28),
        paint: Paint()..color = isPlayer ? Colors.blue.shade700 : Colors.red.shade700,
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (currentCooldown > 0) {
      currentCooldown -= dt;
    }
    
    if (isAttacking) {
      attackAnimationTime += dt;
      if (attackAnimationTime > 0.3) {
        isAttacking = false;
        attackAnimationTime = 0;
      }
    }
    
    // Find target
    findTarget();
    
    if (target != null) {
      double distance = position.distanceTo(target!.position);
      
      if (distance <= attackRange) {
        // Attack
        if (currentCooldown <= 0) {
          attack();
        }
      } else {
        // Move towards target
        move(dt);
      }
    } else {
      // Move towards enemy base
      move(dt);
    }
    
    // Check if reached enemy base
    checkBaseCollision();
  }
  
  void findTarget() {
    final enemies = isPlayer ? game.enemyUnits : game.playerUnits;
    double closestDistance = double.infinity;
    DogUnit? closest;
    
    for (final enemy in enemies) {
      if (!enemy.isMounted) continue;
      double dist = position.distanceTo(enemy.position);
      if (dist < closestDistance) {
        closestDistance = dist;
        closest = enemy;
      }
    }
    
    target = closest;
  }
  
  void move(double dt) {
    double direction = isPlayer ? 1 : -1;
    position.x += speed * direction * dt;
    
    // Animation bounce
    double bounce = sin(position.x * 0.1) * 2;
    position.y = game.size.y - 120 + bounce;
  }
  
  void attack() {
    currentCooldown = attackCooldown;
    isAttacking = true;
    attackAnimationTime = 0;
    
    if (target != null && target!.isMounted) {
      target!.takeDamage(damage);
    }
  }
  
  void takeDamage(int dmg) {
    health -= dmg;
    if (health <= 0) {
      die();
    }
  }
  
  void die() {
    if (isPlayer) {
      game.playerUnits.remove(this);
    } else {
      game.enemyUnits.remove(this);
    }
    removeFromParent();
  }
  
  void checkBaseCollision() {
    if (isPlayer && position.x > game.size.x - 100) {
      game.damageBase(damage, false);
      die();
    } else if (!isPlayer && position.x < 100) {
      game.damageBase(damage, true);
      die();
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Attack animation - lunge forward
    if (isAttacking) {
      double lunge = sin(attackAnimationTime * 10) * 10;
      canvas.translate(isPlayer ? lunge : -lunge, 0);
    }
  }
}