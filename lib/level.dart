import 'dart:math';
import 'package:battle_dogs/Dogs.dart';
import 'package:battle_dogs/levels.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Enemy catalogue — ANIMAL ENEMIES (Battle Cats style)
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> kEnemyTypes = [
  {
    'id': 'angry_rabbit',
    'name': 'Angry Rabbit',
    'icon': '🐰',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFFDDDDDD,
    'outlineColor': 0xFF333333,
    'health': 50,
    'damage': 8,
    'speed': 28.0,
    'attackRange': 55.0,
    'attackCooldown': 1.1,
    'cost': 40,
    'emoji': '🐰',
  },
  {
    'id': 'swift_fox',
    'name': 'Swift Fox',
    'icon': '🦊',
    'bodyColor': 0xFFFF8A65,
    'accentColor': 0xFFFFB74D,
    'outlineColor': 0xFF4A1A00,
    'health': 60,
    'damage': 14,
    'speed': 55.0,
    'attackRange': 60.0,
    'attackCooldown': 0.8,
    'cost': 60,
    'emoji': '🦊',
  },
  {
    'id': 'tank_rhino',
    'name': 'Tank Rhino',
    'icon': '🦏',
    'bodyColor': 0xFF90A4AE,
    'accentColor': 0xFFB0BEC5,
    'outlineColor': 0xFF263238,
    'health': 160,
    'damage': 20,
    'speed': 14.0,
    'attackRange': 58.0,
    'attackCooldown': 1.6,
    'cost': 80,
    'emoji': '🦏',
  },
  {
    'id': 'electric_eel',
    'name': 'Electric Eel',
    'icon': '🐍',
    'bodyColor': 0xFF80DEEA,
    'accentColor': 0xFFE0F7FA,
    'outlineColor': 0xFF004D40,
    'health': 90,
    'damage': 18,
    'speed': 32.0,
    'attackRange': 80.0,
    'attackCooldown': 1.0,
    'cost': 90,
    'emoji': '🐍',
  },
  {
    'id': 'ghost_owl',
    'name': 'Ghost Owl',
    'icon': '🦉',
    'bodyColor': 0xFFCE93D8,
    'accentColor': 0xFFE1BEE7,
    'outlineColor': 0xFF4A148C,
    'health': 70,
    'damage': 22,
    'speed': 38.0,
    'attackRange': 65.0,
    'attackCooldown': 1.3,
    'cost': 100,
    'emoji': '🦉',
  },
  {
    'id': 'war_boar',
    'name': 'War Boar',
    'icon': '🐗',
    'bodyColor': 0xFF8D6E63,
    'accentColor': 0xFFBCAAA4,
    'outlineColor': 0xFF1A0000,
    'health': 130,
    'damage': 26,
    'speed': 22.0,
    'attackRange': 62.0,
    'attackCooldown': 1.4,
    'cost': 110,
    'emoji': '🐗',
  },
  {
    'id': 'storm_eagle',
    'name': 'Storm Eagle',
    'icon': '🦅',
    'bodyColor': 0xFF5C6BC0,
    'accentColor': 0xFF9FA8DA,
    'outlineColor': 0xFF0D1642,
    'health': 80,
    'damage': 30,
    'speed': 20.0,
    'attackRange': 110.0,
    'attackCooldown': 2.0,
    'cost': 120,
    'emoji': '🦅',
  },
  {
    'id': 'mega_bear_king',
    'name': 'Mega Bear King',
    'icon': '🐻',
    'bodyColor': 0xFF6D4C41,
    'accentColor': 0xFF8D6E63,
    'outlineColor': 0xFF1A0000,
    'health': 800,
    'damage': 50,
    'speed': 12.0,
    'attackRange': 90.0,
    'attackCooldown': 1.5,
    'cost': 9999,
    'emoji': '🐻',
    'isBoss': true,
  },
];

Map<String, dynamic> getEnemyById(String id) =>
    kEnemyTypes.firstWhere((e) => e['id'] == id, orElse: () => kEnemyTypes[0]);

const List<List<Color>> kLevelSkyColors = [
  [Color(0xFF87CEEB), Color(0xFFB8E4F0)],
  [Color(0xFF64B5F6), Color(0xFF90CAF9)],
  [Color(0xFF546E7A), Color(0xFF78909C)],
  [Color(0xFF1A237E), Color(0xFF283593)],
  [Color(0xFF4A0000), Color(0xFF7B0000)],
];

const List<List<String>> kLevelEnemyPools = [
  ['angry_rabbit', 'angry_rabbit', 'swift_fox'],
  ['angry_rabbit', 'swift_fox', 'tank_rhino'],
  ['swift_fox', 'tank_rhino', 'electric_eel'],
  ['electric_eel', 'ghost_owl', 'war_boar', 'storm_eagle'],
  ['war_boar', 'storm_eagle', 'mega_bear_king'],
];

// ─────────────────────────────────────────────
//  Level (FlameGame)
// ─────────────────────────────────────────────
class Level extends FlameGame with TapCallbacks {
  final int levelNumber;
  final List<String> squadIds;
  final double enemyStrength;
  final void Function(bool won) onGameEnd;

  Level({
    this.levelNumber = 1,
    this.squadIds = const ['corgi', 'husky', 'bulldog'],
    this.enemyStrength = 1.0,
    required this.onGameEnd,
  });

  int money = 200;
  int baseHealth = 100;
  int enemyBaseHealth = 100;
  double remainingTime = 120.0;
  bool gameEnded = false;
  bool isPaused = false;

  final List<DogUnit> playerUnits = [];
  final List<EnemyUnit> enemyUnits = [];


  late TextComponent moneyText;
  late TextComponent timerText;
  late RectangleComponent playerHealthFill;
  late RectangleComponent enemyHealthFill;

  // Layout constants (fractions of screen height)
  static const double kGroundY = 0.70;
  static const double kUnitY = 0.66;
  static const double kUIBarHeight = 88.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Register overlays
    overlays.addEntry('pause',    (context, game) => _PauseOverlay(game: this));
    overlays.addEntry('gameOver', (context, game) => _GameOverOverlay(game: this));

    final idx = (levelNumber - 1).clamp(0, kLevelSkyColors.length - 1);
    final skyColors = kLevelSkyColors[idx];

    // Sky gradient
    add(RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: skyColors,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    ));

    // Clouds
    for (int i = 0; i < 5; i++) {
      add(BattleCatCloud(
        position: Vector2(
          Random().nextDouble() * size.x,
          30 + Random().nextDouble() * (size.y * kGroundY * 0.35),
        ),
        speed: 14 + Random().nextDouble() * 18,
        cloudScale: 0.6 + Random().nextDouble() * 0.7,
      ));
    }

    // Grass strip (Battle Cats bright green)
    final groundTop = size.y * kGroundY;
    add(RectangleComponent(
      position: Vector2(0, groundTop),
      size: Vector2(size.x, 20),
      paint: Paint()
        ..color = levelNumber >= 4
            ? const Color(0xFF2E7D32)
            : const Color(0xFF7CB342),
    ));
    // Grass highlight stripe
    add(RectangleComponent(
      position: Vector2(0, groundTop),
      size: Vector2(size.x, 5),
      paint: Paint()..color = const Color(0xFFA5D64E),
    ));

    // Zigzag dirt
    add(_ZigzagDirtComponent(
      top: groundTop + 20,
      height: size.y - groundTop - 20,
      width: size.x,
      lightColor: levelNumber >= 5
          ? const Color(0xFF4A1500)
          : const Color(0xFF8D5524),
      darkColor: levelNumber >= 5
          ? const Color(0xFF2A0A00)
          : const Color(0xFF6D4C41),
      zigzagColor: levelNumber >= 5
          ? const Color(0xFF3A1000)
          : const Color(0xFF5D4037),
    ));

    _buildBases(groundTop);
    _buildHUD();
    _buildDeploymentBar();

    add(TimerComponent(
        period: 6.0 / enemyStrength, repeat: true, onTick: _spawnEnemy));
    if (levelNumber == 5) {
      add(TimerComponent(period: 20, repeat: false, onTick: _spawnBoss));
    }
    add(TimerComponent(
        period: 0.5,
        repeat: true,
        onTick: () {
          if (!gameEnded) {
            money += 8;
            moneyText.text = '${money}¢';
          }
        }));
  }

  void togglePause() {
    if (gameEnded) return;
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
      overlays.add('pause');
    } else {
      resumeEngine();
      overlays.remove('pause');
    }
  }

  void _buildBases(double groundTop) {
    // Player castle
    add(BattleCastleComponent(
      position: Vector2(0, groundTop - 155),
      isPlayer: true,
      levelNumber: levelNumber,
    ));

    // Player health bar
    add(RectangleComponent(
        position: Vector2(6, groundTop - 166),
        size: Vector2(110, 10),
        paint: Paint()..color = Colors.black54));
    playerHealthFill = RectangleComponent(
        position: Vector2(6, groundTop - 166),
        size: Vector2(110, 10),
        paint: Paint()..color = const Color(0xFF4CAF50));
    add(playerHealthFill);
    add(TextComponent(
      text: '$baseHealth/100',
      position: Vector2(61, groundTop - 166),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
    ));

    // Enemy castle
    add(BattleCastleComponent(
      position: Vector2(size.x - 138, groundTop - 155),
      isPlayer: false,
      levelNumber: levelNumber,
    ));

    // Enemy health bar
    add(RectangleComponent(
        position: Vector2(size.x - 138, groundTop - 166),
        size: Vector2(130, 10),
        paint: Paint()..color = Colors.black54));
    enemyHealthFill = RectangleComponent(
        position: Vector2(size.x - 138, groundTop - 166),
        size: Vector2(130, 10),
        paint: Paint()..color = const Color(0xFF4CAF50));
    add(enemyHealthFill);
    add(TextComponent(
      text: '$enemyBaseHealth/100',
      position: Vector2(size.x - 73, groundTop - 166),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
    ));
  }

  void _buildHUD() {
    add(RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(size.x, 50),
      paint: Paint()..color = const Color(0xCC000000),
    ));

    add(TextComponent(
      text: '🪙',
      position: Vector2(10, 8),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24)),
    ));
    moneyText = TextComponent(
      text: '${money}¢',
      position: Vector2(44, 10),
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 3)])),
    );
    add(moneyText);

    // Level label box
    add(RectangleComponent(
        position: Vector2(size.x / 2 - 46, 8),
        size: Vector2(92, 34),
        paint: Paint()..color = const Color(0xFF1A1A1A)));
    add(TextComponent(
      text: 'Level $levelNumber',
      position: Vector2(size.x / 2, 25),
      anchor: Anchor.center,
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold)),
    ));

    // Pause button — top right corner
    add(_PauseButton(
      position: Vector2(size.x - 50, 5),
      size: Vector2(44, 40),
      game: this,
    ));

    timerText = TextComponent(
      text: _fmt(remainingTime),
      position: Vector2(size.x - 64, 12),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
    );
    add(timerText);
  }

  void _buildDeploymentBar() {
    final barY = size.y - kUIBarHeight+10;

    // Battle Cats style: dark panel
    add(RectangleComponent(
        position: Vector2(0, barY),
        size: Vector2(size.x, kUIBarHeight),
        paint: Paint()..color = const Color(0xFF1E1E1E)));
    // Thin top separator
    add(RectangleComponent(
        position: Vector2(0, barY),
        size: Vector2(size.x, 2),
        paint: Paint()..color = const Color(0xFF444444)));

    final dogs = squadIds
        .map((id) => getDogById(id))
        .where((d) => d != null && d.isNotEmpty)
        .toList();

    // Always 5 slots left-aligned, like Battle Cats
    const slotW = 72.0;
    const slotH = 78.0;
    const gap = 4.0;
    const startX = 6.0;

    for (int i = 0; i < 5; i++) {
      final slotX = startX + i * (slotW + gap);
      if (i < dogs.length) {
        add(DeploySlot(
          position: Vector2(slotX, barY + 3),
          size: Vector2(slotW, slotH),
          dog: dogs[i]!,
          game: this,
        ));
      } else {
        // Empty greyed slot
        add(RectangleComponent(
            position: Vector2(slotX, barY + 3),
            size: Vector2(slotW, slotH),
            paint: Paint()..color = const Color(0xFF3A3A3A)));
        add(RectangleComponent(
            position: Vector2(slotX, barY + 3),
            size: Vector2(slotW, slotH),
            paint: Paint()
              ..color = const Color(0xFF555555)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameEnded) return;

    remainingTime -= dt;
    timerText.text = _fmt(remainingTime);

    if (remainingTime <= 30) {
      timerText.textRenderer = TextPaint(
          style: TextStyle(
              color: remainingTime <= 10 ? Colors.red : Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold));
    }

    if (remainingTime <= 0) _gameOver(false, "TIME'S UP!");
    _updateHealthBars();
  }

  void _updateHealthBars() {
    final pp = (baseHealth / 100).clamp(0.0, 1.0);
    playerHealthFill.size = Vector2(110 * pp, 10);
    playerHealthFill.paint = Paint()
      ..color = pp > 0.5
          ? const Color(0xFF4CAF50)
          : pp > 0.25
              ? Colors.orange
              : Colors.red;

    final ep = (enemyBaseHealth / 100).clamp(0.0, 1.0);
    enemyHealthFill.size = Vector2(130 * ep, 10);
    enemyHealthFill.paint = Paint()
      ..color = ep > 0.5
          ? const Color(0xFF4CAF50)
          : ep > 0.25
              ? Colors.orange
              : Colors.red;
  }

  void spawnPlayerDog(Map<String, dynamic> dog) {
    final cost = dog['cost'] as int;
    if (money < cost) return;
    money -= cost;
    moneyText.text = '${money}¢';

    final unit = DogUnit(
      position: Vector2(128, size.y * kUnitY),
      dog: dog,
      game: this,
    );
    playerUnits.add(unit);
    add(unit);
  }

  void _spawnEnemy() {
    if (gameEnded) return;
    final pool = kLevelEnemyPools[
            (levelNumber - 1).clamp(0, kLevelEnemyPools.length - 1)]
        .where((id) => id != 'mega_bear_king')
        .toList();
    if (pool.isEmpty) return;
    _spawnEnemyById(pool[Random().nextInt(pool.length)]);
  }

  void _spawnBoss() {
    if (gameEnded) return;
    _spawnEnemyById('mega_bear_king');
  }

  void _spawnEnemyById(String id) {
    final enemy = getEnemyById(id);
    final bH = ((enemy['health'] as int) * enemyStrength).round();
    final bD = ((enemy['damage'] as int) * enemyStrength).round();
    final unit = EnemyUnit(
      position: Vector2(size.x - 160, size.y * kUnitY),
      enemy: enemy,
      boostedHealth: bH,
      boostedDamage: bD,
      game: this,
    );
    enemyUnits.add(unit);
    add(unit);
  }

  void damageBase(int dmg, bool isPlayerBase) {
    if (gameEnded) return;
    if (isPlayerBase) {
      baseHealth -= dmg;
      if (baseHealth <= 0) { baseHealth = 0; _gameOver(false, 'DEFEATED!'); }
    } else {
      enemyBaseHealth -= dmg;
      if (enemyBaseHealth <= 0) { enemyBaseHealth = 0; _gameOver(true, 'VICTORY!'); }
    }
  }

  void _gameOver(bool won, String msg) {
    if (gameEnded) return;
    gameEnded = true;
    pauseEngine();
    // Remove pause overlay if it was up
    if (isPaused) overlays.remove('pause');
    overlays.add('gameOver');
    _gameOverWon = won;
    _gameOverMsg = msg;
  }

  bool _gameOverWon = false;
  String _gameOverMsg = '';

  String _fmt(double s) {
    final m = s ~/ 60;
    final sec = s.toInt() % 60;
    return '${m}:${sec.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────
//  Battle Cats-style stone castle
// ─────────────────────────────────────────────
class BattleCastleComponent extends PositionComponent {
  final bool isPlayer;
  final int levelNumber;

  BattleCastleComponent({
    required Vector2 position,
    required this.isPlayer,
    required this.levelNumber,
  }) : super(position: position, size: Vector2(130, 160));

  @override
  Future<void> onLoad() async {
    final stone = levelNumber >= 5 ? const Color(0xFF6D0000) : const Color(0xFFADADAD);
    final stoneDark = levelNumber >= 5 ? const Color(0xFF3A0000) : const Color(0xFF757575);
    final stoneLight = levelNumber >= 5 ? const Color(0xFF8B0000) : const Color(0xFFD0D0D0);
    final flagColor = isPlayer ? const Color(0xFFE53935) : const Color(0xFF1565C0);

    // Main body
    add(RectangleComponent(
        size: Vector2(110, 128), position: Vector2(10, 30),
        paint: Paint()..color = stone));
    // Horizontal stone lines
    for (int r = 0; r < 5; r++) {
      add(RectangleComponent(
          size: Vector2(110, 2), position: Vector2(10, 30 + r * 26.0),
          paint: Paint()..color = stoneDark));
    }
    // Vertical brick lines
    for (int r = 0; r < 5; r++) {
      final off = (r % 2 == 0) ? 0.0 : 18.0;
      for (double x = off; x < 110; x += 36) {
        add(RectangleComponent(
            size: Vector2(2, 26), position: Vector2(10 + x, 30 + r * 26.0),
            paint: Paint()..color = stoneDark));
      }
    }

    // Battlements
    for (int i = 0; i < 4; i++) {
      add(RectangleComponent(
          size: Vector2(22, 30), position: Vector2(10 + i * 28.0, 0),
          paint: Paint()..color = stone));
      add(RectangleComponent(
          size: Vector2(22, 2), position: Vector2(10 + i * 28.0, 14),
          paint: Paint()..color = stoneDark));
      add(RectangleComponent(
          size: Vector2(22, 5), position: Vector2(10 + i * 28.0, 0),
          paint: Paint()..color = stoneLight));
    }

    // Flag pole + flag
    add(RectangleComponent(
        size: Vector2(4, 42), position: Vector2(54, -40),
        paint: Paint()..color = const Color(0xFF795548)));
    add(RectangleComponent(
        size: Vector2(28, 18), position: Vector2(58, -40),
        paint: Paint()..color = flagColor));
    add(RectangleComponent(
        size: Vector2(28, 5), position: Vector2(58, -40),
        paint: Paint()..color = Colors.white.withOpacity(0.35)));

    // Door
    add(RectangleComponent(
        size: Vector2(36, 42), position: Vector2(37, 116),
        paint: Paint()..color = stoneDark));
    add(RectangleComponent(
        size: Vector2(30, 36), position: Vector2(40, 119),
        paint: Paint()..color = const Color(0xFF0D0D0D)));
    add(RectangleComponent(
        size: Vector2(30, 6), position: Vector2(40, 119),
        paint: Paint()..color = const Color(0xFF2A2A2A)));

    // Windows (x4)
    for (final pos in [Vector2(16, 50), Vector2(74, 50), Vector2(16, 88), Vector2(74, 88)]) {
      add(RectangleComponent(size: Vector2(20, 22), position: pos, paint: Paint()..color = stoneDark));
      add(RectangleComponent(size: Vector2(14, 16), position: Vector2(pos.x + 3, pos.y + 3),
          paint: Paint()..color = const Color(0xFF1A2A3A)));
      add(RectangleComponent(size: Vector2(20, 4), position: Vector2(pos.x, pos.y + 18),
          paint: Paint()..color = stone));
    }
  }
}

// ─────────────────────────────────────────────
//  Zigzag dirt (Battle Cats signature ground)
// ─────────────────────────────────────────────
class _ZigzagDirtComponent extends PositionComponent {
  final double top;
  final double height;
  final double width;
  final Color lightColor;
  final Color darkColor;
  final Color zigzagColor;

  _ZigzagDirtComponent({
    required this.top,
    required this.height,
    required this.width,
    required this.lightColor,
    required this.darkColor,
    required this.zigzagColor,
  }) : super(position: Vector2(0, top), size: Vector2(width, height));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = lightColor);

    const spikeW = 26.0;
    const spikeH = 16.0;
    final path = Path();
    path.moveTo(0, 0);
    double x = 0;
    while (x <= width + spikeW) {
      path.lineTo(x + spikeW / 2, -spikeH);
      path.lineTo(x + spikeW, 0);
      x += spikeW;
    }
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    canvas.drawPath(path, Paint()..color = zigzagColor);

    canvas.drawRect(Rect.fromLTWH(0, height - 18, width, 18), Paint()..color = darkColor);
  }
}

// ─────────────────────────────────────────────
//  Cloud (Battle Cats pillowy style)
// ─────────────────────────────────────────────
class BattleCatCloud extends PositionComponent {
  final double speed;
  final double cloudScale;

  BattleCatCloud({required Vector2 position, required this.speed, this.cloudScale = 1.0})
      : super(position: position);

  @override
  Future<void> onLoad() async {
    final p = Paint()..color = Colors.white.withOpacity(0.9);
    final s = cloudScale;
    add(CircleComponent(radius: 17 * s, position: Vector2(0, 0), paint: p));
    add(CircleComponent(radius: 23 * s, position: Vector2(20 * s, -5 * s), paint: p));
    add(CircleComponent(radius: 19 * s, position: Vector2(44 * s, -2 * s), paint: p));
    add(CircleComponent(radius: 15 * s, position: Vector2(64 * s, 4 * s), paint: p));
    add(RectangleComponent(
        size: Vector2(72 * s, 16 * s),
        position: Vector2(0, 12 * s),
        paint: Paint()..color = Colors.white.withOpacity(0.9)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    if (parent is Level) {
      final g = parent as Level;
      if (position.x > g.size.x + 130) position.x = -130;
    }
  }
}

// ─────────────────────────────────────────────
//  DeploySlot — Battle Cats style unit tile
//  Light grey/white tile, dog portrait, cost below,
//  cyan cooldown bar fills bottom, darkens when on CD
// ─────────────────────────────────────────────
class DeploySlot extends PositionComponent with TapCallbacks {
  final Map<String, dynamic> dog;
  final Level game;

  static const double kCooldown = 2.8;
  double _cdRemaining = 0;
  bool _onCD = false;

  late RectangleComponent _cdFill;
  late RectangleComponent _dimOverlay;

  DeploySlot({
    required Vector2 position,
    required Vector2 size,
    required this.dog,
    required this.game,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // ── Outer border (dark) ──
    add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF111111)));

    // ── White/light inner background (Battle Cats tile) ──
    add(RectangleComponent(
        size: Vector2(size.x - 4, size.y - 4),
        position: Vector2(2, 2),
        paint: Paint()..color = const Color(0xFFE8E8E8)));

    // ── Portrait area (slightly lighter inner square) ──
    add(RectangleComponent(
        size: Vector2(size.x - 8, size.y - 22),
        position: Vector2(4, 4),
        paint: Paint()..color = const Color(0xFFDDDDDD)));

    // ── Mini dog portrait drawn with canvas in render ──
    add(_SlotPortrait(dog: dog, size: size));

    // ── Dim overlay (darkens tile during cooldown) ──
    _dimOverlay = RectangleComponent(
        size: Vector2(size.x - 4, size.y - 4),
        position: Vector2(2, 2),
        paint: Paint()..color = Colors.black.withOpacity(0));
    add(_dimOverlay);

    // ── Cost text (bottom, black on light bg) ──
    add(TextComponent(
      text: '${dog['cost']}¢',
      position: Vector2(size.x / 2, size.y - 14),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    ));

    // ── Cooldown bar bg (bottom strip) ──
    add(RectangleComponent(
        size: Vector2(size.x - 4, 5),
        position: Vector2(2, size.y - 7),
        paint: Paint()..color = const Color(0xFF888888)));

    // ── Cooldown fill (cyan) ──
    _cdFill = RectangleComponent(
        size: Vector2(0, 5),
        position: Vector2(2, size.y - 7),
        paint: Paint()..color = const Color(0xFF00CFFF));
    add(_cdFill);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_onCD) {
      _cdRemaining -= dt;
      if (_cdRemaining <= 0) {
        _cdRemaining = 0;
        _onCD = false;
        _cdFill.size = Vector2(0, 5);
        _dimOverlay.paint = Paint()..color = Colors.black.withOpacity(0);
      } else {
        final pct = 1.0 - (_cdRemaining / kCooldown);
        _cdFill.size = Vector2((size.x - 4) * pct, 5);
      }
    }
  }

  @override
  void onTapDown(TapDownEvent e) {
    if (_onCD) return;
    if (game.money < (dog['cost'] as int)) return;
    game.spawnPlayerDog(dog);
    _onCD = true;
    _cdRemaining = kCooldown;
    _cdFill.size = Vector2(0, 5);
    _dimOverlay.paint = Paint()..color = Colors.black.withOpacity(0.45);
  }
}

// Mini portrait rendered fresh each frame for the slot
class _SlotPortrait extends PositionComponent {
  final Map<String, dynamic> dog;

  _SlotPortrait({required this.dog, required Vector2 size})
      : super(size: size);

  static const _ol = Color(0xFF1A1A2E);
  static const _wh = Colors.white;
  static Paint _p(Color c) => Paint()..color = c;

  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cx = size.x / 2;
    final cy = (size.y - 18) / 2 + 2;
    final r = 13.0;
    final bodyColor = Color(dog['bodyColor'] as int? ?? 0xFFFFFFFF);

    // Shadow
    canvas.drawOval(Rect.fromLTWH(cx - 10, cy + r + 2, 20, 6),
        _p(Colors.black.withOpacity(0.15)));

    // Short legs
    canvas.drawRect(Rect.fromLTWH(cx - 9, cy + r - 2, 6, 7), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 3, cy + r - 2, 6, 7), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy + r + 4, 8, 3), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 2, cy + r + 4, 8, 3), _p(_ol));

    // Tail (small curve right side)
    final tailPath = Path();
    tailPath.moveTo(cx + r - 2, cy + 2);
    tailPath.quadraticBezierTo(cx + r + 8, cy - 4, cx + r + 6, cy - 12);
    canvas.drawPath(tailPath, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);

    // Body outline + fill
    canvas.drawCircle(Offset(cx, cy), r + 1.5, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(bodyColor));

    // Highlight
    canvas.drawCircle(Offset(cx - 4, cy - 5), 4, _p(_wh.withOpacity(0.45)));

    // Pointy ears on top of head
    _drawEar(canvas, cx - 8, cy - r + 2, false, bodyColor);
    _drawEar(canvas, cx + 8, cy - r + 2, true, bodyColor);

    // Eyes
    canvas.drawCircle(Offset(cx - 4, cy - 1), 2.2, _p(_ol));
    canvas.drawCircle(Offset(cx + 4, cy - 1), 2.2, _p(_ol));
    canvas.drawCircle(Offset(cx - 3.5, cy - 1.5), 0.8, _p(_wh));
    canvas.drawCircle(Offset(cx + 4.5, cy - 1.5), 0.8, _p(_wh));

    // Nose + smile
    canvas.drawCircle(Offset(cx, cy + 3), 1.5, _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 4, cy + 6, 8, 1.5), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 4, cy + 4.5, 1.5, 2), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 2.5, cy + 4.5, 1.5, 2), _p(_ol));
  }

  void _drawEar(Canvas canvas, double cx, double cy, bool flip, Color fill) {
    final path = Path();
    if (!flip) {
      path.moveTo(cx + 4, cy + 4);
      path.lineTo(cx - 2, cy - 8);
      path.lineTo(cx + 8, cy - 2);
    } else {
      path.moveTo(cx - 4, cy + 4);
      path.lineTo(cx + 2, cy - 8);
      path.lineTo(cx - 8, cy - 2);
    }
    path.close();
    canvas.drawPath(path, _p(_ol));
    final path2 = Path();
    if (!flip) {
      path2.moveTo(cx + 3, cy + 2);
      path2.lineTo(cx - 0.5, cy - 5);
      path2.lineTo(cx + 6, cy - 1);
    } else {
      path2.moveTo(cx - 3, cy + 2);
      path2.lineTo(cx + 0.5, cy - 5);
      path2.lineTo(cx - 6, cy - 1);
    }
    path2.close();
    canvas.drawPath(path2, _p(fill));
  }
}

// ─────────────────────────────────────────────
//  DogUnit — drawn fresh every frame via render()
//  Walking animation: legs swing via sin wave
//  Attack animation: body lunges forward then snaps back
// ─────────────────────────────────────────────
class DogUnit extends PositionComponent {
  final Map<String, dynamic> dog;
  final Level game;

  late double speed;
  late int health;
  late int maxHealth;
  late int damage;
  late double attackRange;
  late double attackCooldown;
  double currentCooldown = 0;
  EnemyUnit? target;

  // Animation state
  double _walkPhase = 0.0;    // drives leg swing
  double _attackAnim = 0.0;   // 0→1→0 lunge
  bool _isAttacking = false;

  static const _ol = Color(0xFF1A1A2E);  // thick outline colour
  static const _wh = Colors.white;

  DogUnit({required Vector2 position, required this.dog, required this.game})
      : super(position: position, size: Vector2(72, 90)) {
    speed = (dog['speed'] as int).toDouble();
    health = maxHealth = dog['health'] as int;
    damage = dog['damage'] as int;
    attackRange = dog['attackRange'] as double;
    attackCooldown = dog['attackCooldown'] as double;
  }

  // No child components — everything drawn in render()
  @override
  Future<void> onLoad() async {}

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final id = dog['id'] as String;

    // Attack lunge: shift body right by up to 10px at peak
    final lungeX = _isAttacking ? sin(_attackAnim * pi) * 10.0 : 0.0;

    switch (id) {
      case 'basic_dog':   _drawBasicDog(canvas, lungeX);   break;
      case 'tank_dog':    _drawTankDog(canvas, lungeX);    break;
      case 'axe_dog':     _drawAxeDog(canvas, lungeX);     break;
      case 'gross_dog':   _drawBulldog(canvas, lungeX);    break; // reuses long-leg design
      case 'cow_dog':     _drawCowDog(canvas, lungeX);     break;
      case 'bird_dog':    _drawBirdDog(canvas, lungeX);    break;
      case 'fish_dog':    _drawFishDog(canvas, lungeX);    break;
      case 'lizard_dog':  _drawLizardDog(canvas, lungeX);  break;
      case 'titan_dog':   _drawTitanDog(canvas, lungeX);   break;
      case 'dragon_dog':  _drawDragonDog(canvas, lungeX);  break;
      // legacy IDs (backwards compat)
      case 'corgi':        _drawBasicDog(canvas, lungeX);  break;
      case 'husky':        _drawTankDog(canvas, lungeX);   break;
      case 'bulldog':      _drawBulldog(canvas, lungeX);   break;
      default: _drawDefaultDog(canvas, lungeX);
    }

    // Health bar (always on top)
    final pct = (health / maxHealth).clamp(0.0, 1.0);
    final barW = size.x - 4;
    canvas.drawRect(Rect.fromLTWH(2, -12, barW, 6),
        _p(Colors.black54));
    canvas.drawRect(Rect.fromLTWH(2, -12, barW * pct, 6),
        _p(pct > 0.5 ? const Color(0xFF4CAF50) : pct > 0.25 ? Colors.orange : Colors.red));
  }

  // ─────────────────────────────────────────
  //  Shared helpers
  // ─────────────────────────────────────────

  /// Dog tail — curves upward from right side of body
  void _drawTail(Canvas canvas, double cx, double cy, {double curve = -12.0, bool left = false}) {
    final path = Path();
    if (!left) {
      path.moveTo(cx + 18, cy + 4);
      path.quadraticBezierTo(cx + 28, cy + curve, cx + 24, cy + curve - 10);
    } else {
      path.moveTo(cx - 18, cy + 4);
      path.quadraticBezierTo(cx - 28, cy + curve, cx - 24, cy + curve - 10);
    }
    canvas.drawPath(path, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round);
    final path2 = Path();
    if (!left) {
      path2.moveTo(cx + 18, cy + 4);
      path2.quadraticBezierTo(cx + 27, cy + curve + 1, cx + 24, cy + curve - 9);
    } else {
      path2.moveTo(cx - 18, cy + 4);
      path2.quadraticBezierTo(cx - 27, cy + curve + 1, cx - 24, cy + curve - 9);
    }
    canvas.drawPath(path2, Paint()
      ..color = _wh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round);
  }

  /// Dog nose — shared by all dogs (dogification key feature!)
  void _drawDogNose(Canvas canvas, double cx, double cy) {
    canvas.drawOval(Rect.fromLTWH(cx - 5, cy - 2, 10, 7), _p(_ol));
    canvas.drawOval(Rect.fromLTWH(cx - 3.5, cy - 0.5, 7, 5), _p(const Color(0xFF2E2E2E)));
    canvas.drawCircle(Offset(cx - 2, cy + 1), 1.2, _p(_ol));
    canvas.drawCircle(Offset(cx + 2, cy + 1), 1.2, _p(_ol));
  }

  /// Pointy dog ear (triangle sitting ON TOP of head)
  void _drawPointyEar(Canvas canvas, double cx, double cy, bool flip) {
    final path = Path();
    if (!flip) {
      path.moveTo(cx + 5, cy + 5);
      path.lineTo(cx - 4, cy - 12);
      path.lineTo(cx + 10, cy - 6);
    } else {
      path.moveTo(cx - 5, cy + 5);
      path.lineTo(cx + 4, cy - 12);
      path.lineTo(cx - 10, cy - 6);
    }
    path.close();
    canvas.drawPath(path, _p(_ol));
    final path2 = Path();
    if (!flip) {
      path2.moveTo(cx + 4, cy + 2);
      path2.lineTo(cx - 2, cy - 8);
      path2.lineTo(cx + 8, cy - 4);
    } else {
      path2.moveTo(cx - 4, cy + 2);
      path2.lineTo(cx + 2, cy - 8);
      path2.lineTo(cx - 8, cy - 4);
    }
    path2.close();
    canvas.drawPath(path2, _p(_wh));
  }

  /// Floppy round ear (for dogs like gross_dog)
  void _drawFloppyEar(Canvas canvas, double cx, double cy, bool flip) {
    canvas.drawCircle(Offset(cx, cy), 8, _p(_ol));
    canvas.drawCircle(Offset(cx + (flip ? 1.0 : -1.0), cy + 1), 6, _p(_wh));
  }

  // ─────────────────────────────────────────
  //  1. BASIC DOG — like Basic Cat
  //     Pure white round blob, pointy ears,
  //     dog nose, curly tail. The mascot.
  // ─────────────────────────────────────────
  void _drawBasicDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 40.0;
    const r = 20.0;
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 8);
    _drawTail(canvas, cx, cy, curve: -10.0);
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(_wh));
    canvas.drawCircle(Offset(cx - 8, cy - 8), 6, _p(_wh.withOpacity(0.5)));
    _drawPointyEar(canvas, cx - 10, cy - r + 4, false);
    _drawPointyEar(canvas, cx + 10, cy - r + 4, true);
    canvas.drawCircle(Offset(cx - 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, cy - 2.5), 1.2, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, cy - 2.5), 1.2, _p(_wh));
    _drawDogNose(canvas, cx, cy + 5);
    // Smile
    canvas.drawRect(Rect.fromLTWH(cx - 6, cy + 11, 12, 2.5), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 6, cy + 9, 2.5, 3), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 3.5, cy + 9, 2.5, 3), _p(_ol));
  }

  // ─────────────────────────────────────────
  //  2. TANK DOG — like Tank Cat
  //     Wider body, armoured look, shield-
  //     shaped head, tough expression
  // ─────────────────────────────────────────
  void _drawTankDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 42.0;
    _drawLegs(canvas, cx, cy + 18, _walkPhase, legH: 8, legW: 11);
    _drawTail(canvas, cx, cy, curve: -8.0);
    // Wide body — oval not circle
    canvas.drawOval(Rect.fromLTWH(cx - 24, cy - 18, 48, 38), _p(_ol));
    canvas.drawOval(Rect.fromLTWH(cx - 22, cy - 16, 44, 34), _p(const Color(0xFFBDBDBD)));
    // Armour lines
    canvas.drawRect(Rect.fromLTWH(cx - 22, cy - 4, 44, 2), _p(_ol.withOpacity(0.2)));
    canvas.drawRect(Rect.fromLTWH(cx - 22, cy + 6, 44, 2), _p(_ol.withOpacity(0.2)));
    canvas.drawCircle(Offset(cx - 9, cy - 9), 6, _p(_wh.withOpacity(0.35)));
    // Flat-top ears (tank style)
    canvas.drawRect(Rect.fromLTWH(cx - 22, cy - 18, 12, 8), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 21, cy - 17, 10, 6), _p(const Color(0xFFBDBDBD)));
    canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 18, 12, 8), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 11, cy - 17, 10, 6), _p(const Color(0xFFBDBDBD)));
    // Serious face
    canvas.drawCircle(Offset(cx - 7, cy - 2), 4, _p(_ol));
    canvas.drawCircle(Offset(cx + 7, cy - 2), 4, _p(_ol));
    canvas.drawCircle(Offset(cx - 6, cy - 2.5), 1.5, _p(_wh));
    canvas.drawCircle(Offset(cx + 8, cy - 2.5), 1.5, _p(_wh));
    _drawDogNose(canvas, cx, cy + 6);
    canvas.drawRect(Rect.fromLTWH(cx - 7, cy + 12, 14, 2.5), _p(_ol));
  }

  // ─────────────────────────────────────────
  //  3. AXE DOG — like Axe Cat
  //     Round blob holding a big axe,
  //     determined face, action pose
  // ─────────────────────────────────────────
  void _drawAxeDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 40.0;
    const r = 19.0;
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 8);
    _drawTail(canvas, cx, cy, curve: -10.0);
    // Axe (drawn first so body overlaps handle)
    canvas.drawRect(Rect.fromLTWH(cx + r - 2, cy - 20, 4, 36), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + r, cy - 20, 2, 34), _p(const Color(0xFF795548)));
    // Axe head
    final axePath = Path();
    axePath.moveTo(cx + r + 2, cy - 20);
    axePath.lineTo(cx + r + 18, cy - 14);
    axePath.lineTo(cx + r + 18, cy + 2);
    axePath.lineTo(cx + r + 2, cy + 8);
    axePath.close();
    canvas.drawPath(axePath, _p(const Color(0xFF9E9E9E)));
    canvas.drawPath(axePath, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8);
    // Axe blade shine
    canvas.drawRect(Rect.fromLTWH(cx + r + 4, cy - 12, 3, 12), _p(_wh.withOpacity(0.4)));
    // Body
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(const Color(0xFFFF8A65)));
    canvas.drawCircle(Offset(cx - 8, cy - 8), 6, _p(_wh.withOpacity(0.35)));
    _drawPointyEar(canvas, cx - 10, cy - r + 4, false);
    _drawPointyEar(canvas, cx + 10, cy - r + 4, true);
    // Determined eyes
    canvas.drawCircle(Offset(cx - 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, cy - 2.5), 1.2, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, cy - 2.5), 1.2, _p(_wh));
    _drawDogNose(canvas, cx, cy + 5);
    canvas.drawRect(Rect.fromLTWH(cx - 5, cy + 11, 10, 2.5), _p(_ol));
  }

  // ─────────────────────────────────────────
  //  4. GROSS DOG — like Gross Cat
  //     Round head on two very long stilty
  //     legs, no arms, floppy ears, tail
  // ─────────────────────────────────────────
  void _drawBulldog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    final legSwing = sin(_walkPhase) * 8.0;
    canvas.drawOval(Rect.fromLTWH(cx - 14, 80, 28, 8), _p(Colors.black.withOpacity(0.2)));
    // Long stilty legs with swing animation
    final leftAngle = legSwing * 0.04;
    canvas.save();
    canvas.translate(cx - 9, 46);
    canvas.rotate(-leftAngle);
    canvas.drawRect(Rect.fromLTWH(-4, 0, 8, 36), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(-3, 1, 6, 34), _p(_wh));
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(-3, 9 + i * 11.0, 6, 2), _p(_ol.withOpacity(0.2)));
    }
    canvas.drawRect(Rect.fromLTWH(-7, 34, 14, 5), _p(_ol));
    canvas.restore();
    canvas.save();
    canvas.translate(cx + 9, 46);
    canvas.rotate(leftAngle);
    canvas.drawRect(Rect.fromLTWH(-4, 0, 8, 36), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(-3, 1, 6, 34), _p(_wh));
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(Rect.fromLTWH(-3, 9 + i * 11.0, 6, 2), _p(_ol.withOpacity(0.2)));
    }
    canvas.drawRect(Rect.fromLTWH(-7, 34, 14, 5), _p(_ol));
    canvas.restore();
    _drawTail(canvas, cx, 26, curve: -12.0);
    // Round head high up
    canvas.drawCircle(Offset(cx, 26), 22, _p(_ol));
    canvas.drawCircle(Offset(cx, 26), 20, _p(_wh));
    canvas.drawCircle(Offset(cx - 8, 18), 7, _p(_wh.withOpacity(0.45)));
    _drawFloppyEar(canvas, cx - 20, 22, false);
    _drawFloppyEar(canvas, cx + 20, 22, true);
    canvas.drawCircle(Offset(cx - 6, 24), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 6, 24), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, 23.5), 1.2, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, 23.5), 1.2, _p(_wh));
    _drawDogNose(canvas, cx, 30);
  }

  // ─────────────────────────────────────────
  //  5. COW DOG — like Cow Cat
  //     White body with black spots, horns,
  //     fast charging dog
  // ─────────────────────────────────────────
  void _drawCowDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 40.0;
    const r = 20.0;
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 8);
    _drawTail(canvas, cx, cy, curve: -12.0);
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(_wh));
    // Black spots (cow pattern)
    canvas.drawCircle(Offset(cx - 8, cy + 4), 7, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx + 6, cy - 8), 5, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx + 5, cy + 8), 4, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx - 7, cy - 8), 5, _p(_wh.withOpacity(0.4)));
    // Horns (cow signature)
    _drawHorn(canvas, cx - 11, cy - r + 4, -0.4);
    _drawHorn(canvas, cx + 11, cy - r + 4, 0.4);
    // Pointy dog ears between horns
    _drawPointyEar(canvas, cx - 6, cy - r + 6, false);
    _drawPointyEar(canvas, cx + 6, cy - r + 6, true);
    canvas.drawCircle(Offset(cx - 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 6, cy - 2), 3.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, cy - 2.5), 1.2, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, cy - 2.5), 1.2, _p(_wh));
    _drawDogNose(canvas, cx, cy + 5);
    canvas.drawRect(Rect.fromLTWH(cx - 5, cy + 11, 10, 2.5), _p(_ol));
  }

  // ─────────────────────────────────────────
  //  6. BIRD DOG — like Bird Cat
  //     White blob with big golden wings,
  //     flies above, dog nose + ears + tail
  // ─────────────────────────────────────────
  void _drawBirdDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 38.0;
    const r = 18.0;
    // Wing flap animation via walkPhase
    final flapAngle = sin(_walkPhase) * 0.25;
    // Left wing
    canvas.save();
    canvas.translate(cx - r, cy);
    canvas.rotate(-flapAngle - 0.3);
    final lWing = Path();
    lWing.moveTo(0, 0);
    lWing.lineTo(-18, -12);
    lWing.lineTo(-20, 2);
    lWing.lineTo(-14, 14);
    lWing.lineTo(-4, 8);
    lWing.close();
    canvas.drawPath(lWing, _p(_ol));
    final lWing2 = Path();
    lWing2.moveTo(-1, 0);
    lWing2.lineTo(-15, -9);
    lWing2.lineTo(-17, 2);
    lWing2.lineTo(-12, 11);
    lWing2.lineTo(-3, 7);
    lWing2.close();
    canvas.drawPath(lWing2, _p(const Color(0xFFFFD700)));
    canvas.restore();
    // Right wing
    canvas.save();
    canvas.translate(cx + r, cy);
    canvas.rotate(flapAngle + 0.3);
    final rWing = Path();
    rWing.moveTo(0, 0);
    rWing.lineTo(18, -12);
    rWing.lineTo(20, 2);
    rWing.lineTo(14, 14);
    rWing.lineTo(4, 8);
    rWing.close();
    canvas.drawPath(rWing, _p(_ol));
    final rWing2 = Path();
    rWing2.moveTo(1, 0);
    rWing2.lineTo(15, -9);
    rWing2.lineTo(17, 2);
    rWing2.lineTo(12, 11);
    rWing2.lineTo(3, 7);
    rWing2.close();
    canvas.drawPath(rWing2, _p(const Color(0xFFFFD700)));
    canvas.restore();
    // Small legs (bird style)
    _drawLegs(canvas, cx, cy + r, _walkPhase, legH: 6, legW: 6);
    _drawTail(canvas, cx, cy, curve: -8.0);
    // Body
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(_wh));
    canvas.drawCircle(Offset(cx - 7, cy - 7), 5, _p(_wh.withOpacity(0.5)));
    _drawPointyEar(canvas, cx - 9, cy - r + 4, false);
    _drawPointyEar(canvas, cx + 9, cy - r + 4, true);
    canvas.drawCircle(Offset(cx - 5, cy - 2), 3.2, _p(_ol));
    canvas.drawCircle(Offset(cx + 5, cy - 2), 3.2, _p(_ol));
    canvas.drawCircle(Offset(cx - 4, cy - 2.5), 1.1, _p(_wh));
    canvas.drawCircle(Offset(cx + 6, cy - 2.5), 1.1, _p(_wh));
    _drawDogNose(canvas, cx, cy + 4);
  }

  // ─────────────────────────────────────────
  //  7. FISH DOG — like Fish Cat
  //     Round body with fish tail fin,
  //     dorsal fin on top, scales, dog nose
  // ─────────────────────────────────────────
  void _drawFishDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 40.0;
    const r = 19.0;
    final body = const Color(0xFF80DEEA);
    // Fish tail (instead of normal dog tail)
    final tailPath = Path();
    tailPath.moveTo(cx + r - 2, cy);
    tailPath.lineTo(cx + r + 16, cy - 10);
    tailPath.lineTo(cx + r + 14, cy);
    tailPath.lineTo(cx + r + 16, cy + 10);
    tailPath.close();
    canvas.drawPath(tailPath, _p(_ol));
    final tailPath2 = Path();
    tailPath2.moveTo(cx + r - 1, cy);
    tailPath2.lineTo(cx + r + 13, cy - 8);
    tailPath2.lineTo(cx + r + 12, cy);
    tailPath2.lineTo(cx + r + 13, cy + 8);
    tailPath2.close();
    canvas.drawPath(tailPath2, _p(body));
    // Dorsal fin on top
    final finPath = Path();
    finPath.moveTo(cx - 6, cy - r);
    finPath.lineTo(cx - 10, cy - r - 16);
    finPath.lineTo(cx + 6, cy - r);
    finPath.close();
    canvas.drawPath(finPath, _p(_ol));
    canvas.drawPath(Path()
      ..moveTo(cx - 5, cy - r)
      ..lineTo(cx - 8, cy - r - 12)
      ..lineTo(cx + 5, cy - r)
      ..close(), _p(body));
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 7);
    // Body
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(body));
    // Scale texture
    canvas.drawCircle(Offset(cx - 6, cy + 4), 5, _p(body.withOpacity(0.6)));
    canvas.drawCircle(Offset(cx + 4, cy + 6), 4, _p(body.withOpacity(0.6)));
    canvas.drawCircle(Offset(cx - 7, cy - 6), 5, _p(_wh.withOpacity(0.4)));
    // Dog ears (dogification!)
    _drawPointyEar(canvas, cx - 9, cy - r + 4, false);
    _drawPointyEar(canvas, cx + 9, cy - r + 4, true);
    canvas.drawCircle(Offset(cx - 6, cy - 2), 3.2, _p(_ol));
    canvas.drawCircle(Offset(cx + 6, cy - 2), 3.2, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, cy - 2.5), 1.1, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, cy - 2.5), 1.1, _p(_wh));
    _drawDogNose(canvas, cx, cy + 5);
  }

  // ─────────────────────────────────────────
  //  8. LIZARD DOG — like Lizard Cat
  //     Body with long neck stretching right,
  //     small head on neck tip, dog ears/nose
  // ─────────────────────────────────────────
  void _drawLizardDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 44.0;
    const r = 17.0;
    final body = const Color(0xFF81C784);
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 8);
    _drawTail(canvas, cx, cy, left: true, curve: -10.0);
    // Body
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(body));
    canvas.drawCircle(Offset(cx - 6, cy - 7), 5, _p(_wh.withOpacity(0.35)));
    // Long neck stretching right
    final neckPath = Path();
    neckPath.moveTo(cx + r - 2, cy - 4);
    neckPath.quadraticBezierTo(cx + r + 14, cy - 10, cx + r + 22, cy - 2);
    canvas.drawPath(neckPath, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round);
    canvas.drawPath(neckPath, Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round);
    // Small head at tip of neck
    final hx = cx + r + 28.0;
    final hy = cy - 2.0;
    canvas.drawCircle(Offset(hx, hy), 12, _p(_ol));
    canvas.drawCircle(Offset(hx, hy), 10, _p(body));
    // Dog ears on head
    _drawPointyEar(canvas, hx - 6, hy - 9, false);
    _drawPointyEar(canvas, hx + 6, hy - 9, true);
    // Dog eyes and nose on small head
    canvas.drawCircle(Offset(hx - 4, hy - 1), 2.5, _p(_ol));
    canvas.drawCircle(Offset(hx + 4, hy - 1), 2.5, _p(_ol));
    canvas.drawCircle(Offset(hx - 3.5, hy - 1.5), 0.9, _p(_wh));
    canvas.drawCircle(Offset(hx + 4.5, hy - 1.5), 0.9, _p(_wh));
    _drawDogNose(canvas, hx, hy + 4);
    // Dog's main body eyes (hidden by neck angle)
    canvas.drawCircle(Offset(cx - 5, cy - 2), 3, _p(_ol));
  }

  // ─────────────────────────────────────────
  //  9. TITAN DOG — like Titan Cat
  //     HUGE round blob, massive presence,
  //     extra thick outline, double size
  // ─────────────────────────────────────────
  void _drawTitanDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 42.0;
    const r = 26.0;
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 11, legW: 12);
    _drawTail(canvas, cx, cy, curve: -14.0);
    // Outer glow ring for TITAN feel
    canvas.drawCircle(Offset(cx, cy), r + 6, _p(Colors.white.withOpacity(0.12)));
    canvas.drawCircle(Offset(cx, cy), r + 3, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(_wh));
    canvas.drawCircle(Offset(cx - 11, cy - 11), 9, _p(_wh.withOpacity(0.45)));
    // Large flat-top ears (titan style)
    canvas.drawRect(Rect.fromLTWH(cx - r - 4, cy - r + 2, 14, 10), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - r - 3, cy - r + 3, 12, 8), _p(_wh));
    canvas.drawRect(Rect.fromLTWH(cx + r - 10, cy - r + 2, 14, 10), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + r - 9, cy - r + 3, 12, 8), _p(_wh));
    // Titan large eyes
    canvas.drawCircle(Offset(cx - 9, cy - 3), 5.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 9, cy - 3), 5.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 7.5, cy - 4), 2.2, _p(_wh));
    canvas.drawCircle(Offset(cx + 10.5, cy - 4), 2.2, _p(_wh));
    _drawDogNose(canvas, cx, cy + 7);
    // Wide mouth
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy + 14, 20, 3), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy + 10, 3, 5), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 7, cy + 10, 3, 5), _p(_ol));
  }

  // ─────────────────────────────────────────
  //  10. DRAGON DOG — like Mythical Titan Cat
  //      Gold body, triple horn spikes, fire
  //      eyes, dog nose, dramatic tail
  // ─────────────────────────────────────────
  void _drawDragonDog(Canvas canvas, double lx) {
    final cx = 36.0 + lx;
    const cy = 40.0;
    const r = 22.0;
    _drawLegs(canvas, cx, cy + r - 2, _walkPhase, legH: 9);
    _drawTail(canvas, cx, cy, curve: -18.0);
    // Gold aura glow
    canvas.drawCircle(Offset(cx, cy), r + 6, _p(const Color(0xFFFFD700).withOpacity(0.2)));
    canvas.drawCircle(Offset(cx, cy), r + 2, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), r, _p(const Color(0xFFFFD700)));
    canvas.drawCircle(Offset(cx - 9, cy - 9), 8, _p(_wh.withOpacity(0.3)));
    // Triple dragon horns
    _drawHorn(canvas, cx - 14, cy - r + 2, -0.35);
    _drawHorn(canvas, cx, cy - r - 4, 0);
    _drawHorn(canvas, cx + 14, cy - r + 2, 0.35);
    // Pointy dog ears between horns
    _drawPointyEar(canvas, cx - 8, cy - r + 6, false);
    _drawPointyEar(canvas, cx + 8, cy - r + 6, true);
    // Fire eyes
    canvas.drawCircle(Offset(cx - 7, cy - 2), 5.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 7, cy - 2), 3.5, _p(const Color(0xFFFF5722)));
    canvas.drawCircle(Offset(cx - 7, cy - 2), 1.5, _p(_wh));
    canvas.drawCircle(Offset(cx + 7, cy - 2), 5.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 7, cy - 2), 3.5, _p(const Color(0xFFFF5722)));
    canvas.drawCircle(Offset(cx + 7, cy - 2), 1.5, _p(_wh));
    _drawDogNose(canvas, cx, cy + 7);
    // Double fangs
    canvas.drawRect(Rect.fromLTWH(cx - 8, cy + 13, 16, 2.5), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 7, cy + 13, 4, 8), _p(_wh));
    canvas.drawRect(Rect.fromLTWH(cx + 3, cy + 13, 4, 8), _p(_wh));
  }

  /// Horn helper (for cow and dragon)
  void _drawHorn(Canvas canvas, double cx, double cy, double angle) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRect(Rect.fromLTWH(-3.5, -16, 7, 16), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(-2, -14, 4, 12), _p(const Color(0xFFDAA520)));
    canvas.restore();
  }

  /// Rectangular pointy ear for Husky's block body (kept for compat)
  void _drawPointyEarRect(Canvas canvas, double x, double y, bool flip) {
    final path = Path();
    if (!flip) {
      path.moveTo(x, y + 10); path.lineTo(x, y); path.lineTo(x + 10, y + 10);
    } else {
      path.moveTo(x, y + 10); path.lineTo(x + 10, y); path.lineTo(x + 10, y + 10);
    }
    path.close();
    canvas.drawPath(path, _p(_ol));
    final path2 = Path();
    if (!flip) {
      path2.moveTo(x + 1, y + 9); path2.lineTo(x + 1, y + 3); path2.lineTo(x + 8, y + 9);
    } else {
      path2.moveTo(x + 9, y + 9); path2.lineTo(x + 9, y + 3); path2.lineTo(x + 2, y + 9);
    }
    path2.close();
    canvas.drawPath(path2, _p(_wh));
  }

  void _drawDefaultDog(Canvas canvas, double lx) => _drawBasicDog(canvas, lx);

    /// Short animated legs
  void _drawLegs(Canvas canvas, double cx, double baseY, double phase,
      {double legW = 8, double legH = 8}) {
    final swing = sin(phase) * 4.0;
    _drawSingleLeg(canvas, cx - 10, baseY, legW, legH, swing);
    _drawSingleLeg(canvas, cx + 2, baseY, legW, legH, -swing);
  }

  void _drawSingleLeg(Canvas canvas, double lx, double ly,
      double w, double h, double footShift) {
    canvas.drawRect(Rect.fromLTWH(lx, ly, w, h * 0.55), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(lx, ly + 2, w, 1.5), _p(_wh.withOpacity(0.22)));
    canvas.drawRect(
        Rect.fromLTWH(lx + footShift * 0.4, ly + h * 0.52, w, h * 0.48), _p(_ol));
    canvas.drawRect(
        Rect.fromLTWH(lx + footShift * 0.6 - 1, ly + h, w + 2, 3), _p(_ol));
  }

  /// Convenience paint factory
  static Paint _p(Color c) => Paint()..color = c;

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameEnded || !isMounted) return;
    if (currentCooldown > 0) currentCooldown -= dt;

    // Tick attack animation
    if (_isAttacking) {
      _attackAnim += dt * 5.0; // full lunge in 0.2s
      if (_attackAnim >= 1.0) {
        _attackAnim = 0;
        _isAttacking = false;
      }
    }

    _findTarget();

    if (target != null && isMounted) {
      final dist = position.distanceTo(target!.position);
      if (dist <= attackRange) {
        if (currentCooldown <= 0) _attack();
      } else {
        position.x += speed * dt;
        _walkPhase += dt * 10;
      }
    } else {
      if (position.x > game.size.x - 165) {
        if (currentCooldown <= 0) _attack();
      } else {
        position.x += speed * dt;
        _walkPhase += dt * 10;
      }
    }
    // Gentle vertical bob while walking
    position.y = game.size.y * Level.kUnitY + sin(_walkPhase * 0.5) * 1.5;
  }

  void _findTarget() {
    double best = double.infinity;
    EnemyUnit? c;
    for (final e in game.enemyUnits) {
      if (!e.isMounted) continue;
      final d = position.distanceTo(e.position);
      if (d < best) { best = d; c = e; }
    }
    target = c;
  }

  void _attack() {
    currentCooldown = attackCooldown;
    _isAttacking = true;
    _attackAnim = 0;
    if (target != null) {
      target!.takeDamage(damage);
    } else {
      game.damageBase(damage, false);
    }
  }

  void takeDamage(int dmg) {
    health -= dmg;
    if (health <= 0) {
      game.playerUnits.remove(this);
      removeFromParent();
    }
  }
}

// ─────────────────────────────────────────────
//  EnemyUnit — Battle Cats blob enemy
//  Rendered fresh each frame with animated legs,
//  angry face, tail, short legs. Boss is bigger.
// ─────────────────────────────────────────────
class EnemyUnit extends PositionComponent {
  final Map<String, dynamic> enemy;
  final Level game;
  final int boostedHealth;
  final int boostedDamage;

  late double speed;
  late int health;
  late int maxHealth;
  late double attackRange;
  late double attackCooldown;
  double currentCooldown = 0;
  DogUnit? target;
  final bool isBoss;
  double _walkPhase = 0;
  double _attackAnim = 0.0;
  bool _isAttacking = false;

  EnemyUnit({
    required Vector2 position,
    required this.enemy,
    required this.boostedHealth,
    required this.boostedDamage,
    required this.game,
  })  : isBoss = enemy['isBoss'] == true,
        super(
            position: position,
            size: enemy['isBoss'] == true ? Vector2(96, 110) : Vector2(66, 76)) {
    speed = (enemy['speed'] as num).toDouble();
    health = maxHealth = boostedHealth;
    attackRange = enemy['attackRange'] as double;
    attackCooldown = enemy['attackCooldown'] as double;
  }

  @override
  Future<void> onLoad() async {}  // pure render — no child components

  static Paint _ep(Color c) => Paint()..color = c;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final body    = Color(enemy['bodyColor']    as int);
    final outline = Color(enemy['outlineColor'] as int? ?? 0xFF222222);
    final uW      = isBoss ? 96.0 : 66.0;
    final bR      = isBoss ? 30.0 : 18.0;
    final cx      = uW / 2;
    // Lunge LEFT on attack
    final lunge   = _isAttacking ? -sin(_attackAnim * pi) * 8.0 : 0.0;
    final ecx     = cx + lunge;
    final cy      = isBoss ? 38.0 : 30.0;
    final legW    = isBoss ? 11.0 : 7.0;
    final legH    = isBoss ? 10.0 : 8.0;
    final swing   = sin(_walkPhase) * 4.0;

    // Shadow
    canvas.drawOval(
      Rect.fromLTWH(ecx - bR * 0.8, cy + bR + legH + 1, bR * 1.6, 6),
      _ep(Colors.black.withOpacity(0.18)));

    // Short animated legs (enemies march LEFT so legs mirror)
    _drawEnemyLeg(canvas, ecx - 10, cy + bR - 2, legW, legH, -swing, outline);
    _drawEnemyLeg(canvas, ecx + 2,  cy + bR - 2, legW, legH,  swing, outline);

    // Tail (LEFT side since enemy faces left)
    final tailPath = Path();
    tailPath.moveTo(ecx - bR + 2, cy + 4);
    tailPath.quadraticBezierTo(ecx - bR - 10, cy - 4, ecx - bR - 8, cy - 14);
    canvas.drawPath(tailPath, Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBoss ? 5.5 : 4.0
      ..strokeCap = StrokeCap.round);
    final tailPath2 = Path();
    tailPath2.moveTo(ecx - bR + 2, cy + 4);
    tailPath2.quadraticBezierTo(ecx - bR - 9, cy - 3, ecx - bR - 8, cy - 13);
    canvas.drawPath(tailPath2, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBoss ? 2.5 : 1.8
      ..strokeCap = StrokeCap.round);

    // Body blob
    canvas.drawCircle(Offset(ecx, cy), bR + 2, _ep(outline));
    canvas.drawCircle(Offset(ecx, cy), bR,     _ep(body));
    canvas.drawCircle(Offset(ecx - bR * 0.3, cy - bR * 0.3),
        bR * 0.28, _ep(Colors.white.withOpacity(0.28)));

    // Ears — pointy triangles on top of head
    _drawAngryEar(canvas, ecx - bR * 0.5, cy - bR + 4, false, outline, body);
    _drawAngryEar(canvas, ecx + bR * 0.5, cy - bR + 4, true,  outline, body);

    // Angry brow lines (diagonal)
    final browW = isBoss ? 14.0 : 9.0;
    canvas.save();
    canvas.translate(ecx - bR * 0.42, cy - bR * 0.22);
    canvas.rotate(-0.32);
    canvas.drawRect(Rect.fromLTWH(-browW / 2, 0, browW, isBoss ? 3.0 : 2.5), _ep(outline));
    canvas.restore();
    canvas.save();
    canvas.translate(ecx + bR * 0.42, cy - bR * 0.22);
    canvas.rotate(0.32);
    canvas.drawRect(Rect.fromLTWH(-browW / 2, 0, browW, isBoss ? 3.0 : 2.5), _ep(outline));
    canvas.restore();

    // Angry red eyes
    final eyeR = isBoss ? 5.0 : 3.5;
    canvas.drawCircle(Offset(ecx - bR * 0.38, cy - 2), eyeR,        _ep(outline));
    canvas.drawCircle(Offset(ecx + bR * 0.38, cy - 2), eyeR,        _ep(outline));
    canvas.drawCircle(Offset(ecx - bR * 0.38, cy - 2), eyeR * 0.55, _ep(const Color(0xFFE53935)));
    canvas.drawCircle(Offset(ecx + bR * 0.38, cy - 2), eyeR * 0.55, _ep(const Color(0xFFE53935)));
    canvas.drawCircle(Offset(ecx - bR * 0.34, cy - 2.5), eyeR * 0.22, _ep(Colors.white));
    canvas.drawCircle(Offset(ecx + bR * 0.42, cy - 2.5), eyeR * 0.22, _ep(Colors.white));

    // Fang (single centre tooth)
    final fW = isBoss ? 6.0 : 4.0;
    final fH = isBoss ? 9.0 : 6.0;
    canvas.drawRect(Rect.fromLTWH(ecx - fW / 2, cy + bR * 0.28, fW, fH), _ep(Colors.white));
    canvas.drawRect(Rect.fromLTWH(ecx - fW / 2, cy + bR * 0.28, fW, 2),  _ep(outline));

    // Boss extras: gold glow ring + crown text
    if (isBoss) {
      canvas.drawCircle(Offset(ecx, cy), bR + 9,
          Paint()
            ..color = const Color(0xFFFFD700).withOpacity(0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5);
      // Draw crown as simple shapes
      canvas.drawRect(Rect.fromLTWH(ecx - 14, cy - bR - 10, 28, 7), _ep(const Color(0xFFFFD700)));
      canvas.drawRect(Rect.fromLTWH(ecx - 14, cy - bR - 17, 6, 9),  _ep(const Color(0xFFFFD700)));
      canvas.drawRect(Rect.fromLTWH(ecx - 3,  cy - bR - 20, 6, 12), _ep(const Color(0xFFFFD700)));
      canvas.drawRect(Rect.fromLTWH(ecx + 8,  cy - bR - 17, 6, 9),  _ep(const Color(0xFFFFD700)));
      canvas.drawCircle(Offset(ecx, cy - bR - 20), 3, _ep(Colors.red));
    }

    // Health bar
    final pct = (health / maxHealth).clamp(0.0, 1.0);
    final barW = isBoss ? 88.0 : 58.0;
    canvas.drawRect(Rect.fromLTWH((uW - barW) / 2, -13, barW, 6),
        _ep(Colors.black54));
    canvas.drawRect(Rect.fromLTWH((uW - barW) / 2, -13, barW * pct, 6),
        _ep(pct > 0.5 ? const Color(0xFF4CAF50) : pct > 0.25 ? Colors.orange : Colors.red));
  }

  void _drawEnemyLeg(Canvas canvas, double lx, double ly,
      double w, double h, double swing, Color outline) {
    canvas.drawRect(Rect.fromLTWH(lx, ly, w, h * 0.55),
        Paint()..color = outline);
    canvas.drawRect(Rect.fromLTWH(lx + swing * 0.4, ly + h * 0.52, w, h * 0.48),
        Paint()..color = outline);
    canvas.drawRect(Rect.fromLTWH(lx + swing * 0.6 - 1, ly + h, w + 2, 3),
        Paint()..color = outline);
  }

  void _drawAngryEar(Canvas canvas, double cx, double cy, bool flip,
      Color outline, Color fill) {
    final path = Path();
    if (!flip) {
      path.moveTo(cx + 5, cy + 5);
      path.lineTo(cx - 4, cy - 11);
      path.lineTo(cx + 9, cy - 5);
    } else {
      path.moveTo(cx - 5, cy + 5);
      path.lineTo(cx + 4, cy - 11);
      path.lineTo(cx - 9, cy - 5);
    }
    path.close();
    canvas.drawPath(path, _ep(outline));
    final path2 = Path();
    if (!flip) {
      path2.moveTo(cx + 3, cy + 2);
      path2.lineTo(cx - 2, cy - 7);
      path2.lineTo(cx + 7, cy - 3);
    } else {
      path2.moveTo(cx - 3, cy + 2);
      path2.lineTo(cx + 2, cy - 7);
      path2.lineTo(cx - 7, cy - 3);
    }
    path2.close();
    canvas.drawPath(path2, _ep(fill));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.gameEnded || !isMounted) return;
    if (currentCooldown > 0) currentCooldown -= dt;

    if (_isAttacking) {
      _attackAnim += dt * 5.0;
      if (_attackAnim >= 1.0) { _attackAnim = 0; _isAttacking = false; }
    }

    _findTarget();

    if (target != null && target!.isMounted) {
      final dist = position.distanceTo(target!.position);
      if (dist <= attackRange) {
        if (currentCooldown <= 0) _attack();
      } else {
        position.x -= speed * dt;
        _walkPhase += dt * 10;
      }
    } else {
      if (position.x < 165) {
        if (currentCooldown <= 0) _attack();
      } else {
        position.x -= speed * dt;
        _walkPhase += dt * 10;
      }
    }
    position.y = game.size.y * Level.kUnitY + sin(_walkPhase * 0.5) * 1.5;
  }

  void _findTarget() {
    double best = double.infinity;
    DogUnit? c;
    for (final d in game.playerUnits) {
      if (!d.isMounted) continue;
      final dist = position.distanceTo(d.position);
      if (dist < best) { best = dist; c = d; }
    }
    target = c;
  }

  void _attack() {
    currentCooldown = attackCooldown;
    _isAttacking = true;
    _attackAnim = 0;
    if (target != null) {
      target!.takeDamage(boostedDamage);
    } else {
      game.damageBase(boostedDamage, true);
    }
  }

  void takeDamage(int dmg) {
    health -= dmg;
    if (health <= 0) {
      game.enemyUnits.remove(this);
      game.money += isBoss ? 500 : 80;
      game.moneyText.text = '${game.money}¢';
      removeFromParent();
    }
  }
}

// ─────────────────────────────────────────────
//  Pause button — tap to pause/resume
// ─────────────────────────────────────────────
class _PauseButton extends PositionComponent with TapCallbacks {
  final Level game;

  _PauseButton({
    required Vector2 position,
    required Vector2 size,
    required this.game,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Dark background pill
    add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xCC000000)
          ..style = PaintingStyle.fill));
    add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(0xFF555555)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw two vertical pause bars (classic pause icon)
    final paint = Paint()..color = Colors.white;
    final bw = size.x * 0.18;
    final bh = size.y * 0.55;
    final by = (size.y - bh) / 2;
    final left = size.x / 2 - bw - 3;
    final right = size.x / 2 + 3;
    canvas.drawRect(Rect.fromLTWH(left, by, bw, bh), paint);
    canvas.drawRect(Rect.fromLTWH(right, by, bw, bh), paint);
  }

  @override
  void onTapDown(TapDownEvent e) => game.togglePause();
}

// ─────────────────────────────────────────────
//  Pause overlay — Flutter widget shown over game
// ─────────────────────────────────────────────
class _PauseOverlay extends StatelessWidget {
  final Level game;
  const _PauseOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF444444), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x88000000), blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pause icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF555555), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 6, height: 22, color: Colors.white),
                      const SizedBox(width: 6),
                      Container(width: 6, height: 22, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 28),

                // Resume button
                _PauseMenuBtn(
                  label: '▶  RESUME',
                  color: const Color(0xFF27AE60),
                  onTap: () => game.togglePause(),
                ),
                const SizedBox(height: 12),

                // Quit button
                _PauseMenuBtn(
                  label: '✕  QUIT',
                  color: const Color(0xFFE74C3C),
                  onTap: () {
                    game.gameEnded = true;
                    game.onGameEnd(false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseMenuBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PauseMenuBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Game Over overlay — shown on win or loss
// ─────────────────────────────────────────────
class _GameOverOverlay extends StatefulWidget {
  final Level game;
  const _GameOverOverlay({required this.game});

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.game.onGameEnd(widget.game._gameOverWon);
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.game._gameOverWon;
    final msg = widget.game._gameOverMsg;
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.70),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg,
                style: TextStyle(
                  color: won ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                won ? '🎉 You Win!' : '💀 Game Over',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              // Tap anywhere to go back early
              GestureDetector(
                onTap: () {
                  widget.game.onGameEnd(won);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  decoration: BoxDecoration(
                    color: won ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (won ? const Color(0xFF27AE60) : const Color(0xFFE74C3C)).withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    won ? 'CONTINUE' : 'TRY AGAIN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}