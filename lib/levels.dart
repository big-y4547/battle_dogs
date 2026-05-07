import 'package:battle_dogs/level.dart';
import 'package:battle_dogs/Dogs.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  final _supabase = Supabase.instance.client;
  List<int> _completedLevels = [];
  List<String> _ownedDogs = [];
  bool _loading = true;

  static const List<Map<String, dynamic>> _levels = [
    {
      'level': 1,
      'name': 'Puppy Park',
      'difficulty': 'Easy',
      'icon': '🏞️',
      'bgColor': Color(0xFF27AE60),
      'unlocksDog': null,
      'enemyStrength': 1.2,       // was 0.6
      'description': 'A peaceful park overrun by stray cats!',
    },
    {
      'level': 2,
      'name': 'Dog Beach',
      'difficulty': 'Medium',
      'icon': '🏖️',
      'bgColor': Color(0xFF3498DB),
      'unlocksDog': 'gross_dog',
      'enemyStrength': 1.8,       // was 0.8
      'description': 'Sandy shores, angry seagull-cats. Unlock: Gross Dog!',
    },
    {
      'level': 3,
      'name': 'Urban Streets',
      'difficulty': 'Hard',
      'icon': '🏙️',
      'bgColor': Color(0xFFF39C12),
      'unlocksDog': 'cow_dog',
      'enemyStrength': 2.5,       // was 1.0
      'description': 'City alley brawl. Unlock: Cow Dog!',
    },
    {
      'level': 4,
      'name': 'Dark Forest',
      'difficulty': 'Very Hard',
      'icon': '🌲',
      'bgColor': Color(0xFF8E44AD),
      'unlocksDog': null,
      'enemyStrength': 3.5,       // was 1.4
      'description': 'Danger lurks between ancient trees.',
    },
    {
      'level': 5,
      'name': 'Boss Arena',
      'difficulty': 'Boss',
      'icon': '🏟️',
      'bgColor': Color(0xFFE74C3C),
      'unlocksDog': null,
      'enemyStrength': 5.0,       // was 2.0
      'description': 'Face the ultimate Cat Boss!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final res = await _supabase
        .from('players')
        .select('completed_levels, owned_dogs')
        .eq('user_id', user.id)
        .maybeSingle();
    if (res != null) {
      setState(() {
        _completedLevels = List<int>.from(res['completed_levels'] ?? []);
        _ownedDogs = List<String>.from(res['owned_dogs'] ?? []);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  bool _isUnlocked(int levelNum) {
    if (levelNum == 1) return true;
    return _completedLevels.contains(levelNum - 1);
  }

  // ── FIXED: no nested duplicates, dialog shown AFTER navigation ──
  Future<void> _onLevelComplete(int levelNum) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final updated = {..._completedLevels, levelNum}.toList();
    final levelDef = _levels.firstWhere((l) => l['level'] == levelNum);
    final unlockDogId = levelDef['unlocksDog'] as String?;

    final newOwned = List<String>.from(_ownedDogs);
    bool didUnlockDog = false;

    if (unlockDogId != null && !newOwned.contains(unlockDogId)) {
      newOwned.add(unlockDogId);
      didUnlockDog = true;
    }

    await _supabase.from('players').update({
      'completed_levels': updated,
      'owned_dogs': newOwned,
    }).eq('user_id', user.id);

    if (!mounted) return;

    setState(() {
      _completedLevels = updated;
      _ownedDogs = newOwned;
    });

    // Show unlock dialog AFTER setState, while we're definitely mounted
    if (didUnlockDog && unlockDogId != null && mounted) {
      final dog = getDogById(unlockDogId);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🔓 Dog Unlocked!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dog?['icon'] ?? '', style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Text(dog?['name'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(dog?['description'] ?? ''),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('AWESOME!')),
          ],
        ),
      );
    }
  }

  void _startLevel(int levelNum) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final res = await _supabase
        .from('players')
        .select('squad')
        .eq('user_id', user.id)
        .maybeSingle();
    final squadIds = List<String>.from(res?['squad'] ?? []);

    if (squadIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least 1 dog to your squad in My Pack!'),
            backgroundColor: Color(0xFFE74C3C)),
      );
      return;
    }

    final levelDef = _levels.firstWhere((l) => l['level'] == levelNum);
    bool? didWin;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameWidget(
          game: Level(
            levelNumber: levelNum,
            squadIds: squadIds,
            enemyStrength: (levelDef['enemyStrength'] as double),
            onGameEnd: (won) {
              didWin = won; // just store, never touch setState here
            },
          ),
        ),
      ),
    );

    // Back on LevelsPage now — safe to update state
    if (didWin == true && mounted) {
      await _onLevelComplete(levelNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6DD5FA), Color(0xFF2980B9), Color(0xFF1E3C72)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _levels.length,
                        itemBuilder: (_, i) => _buildLevelCard(_levels[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xF08B4513), Color(0xF0654321)]),
        boxShadow: [
          BoxShadow(
              color: Color(0x80000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const BattleDogsMainPage())),
          ),
          const Expanded(
            child: Text('⚔️ SELECT LEVEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLevelCard(Map<String, dynamic> level) {
    final int num = level['level'] as int;
    final bool unlocked = _isUnlocked(num);
    final bool completed = _completedLevels.contains(num);
    final Color bgColor = level['bgColor'] as Color;
    final String? unlockDogId = level['unlocksDog'] as String?;
    final unlockDog = unlockDogId != null ? getDogById(unlockDogId) : null;

    return GestureDetector(
      onTap: unlocked ? () => _startLevel(num) : null,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.5,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor, bgColor.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: completed
                    ? const Color(0xFFFFD700)
                    : Colors.white.withOpacity(0.5),
                width: completed ? 4 : 2),
            boxShadow: [
              BoxShadow(
                  color: bgColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                          child: Text(level['icon'],
                              style: const TextStyle(fontSize: 38))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _pill('LEVEL $num', Colors.black26),
                              const SizedBox(width: 8),
                              _pill(level['difficulty'],
                                  _difficultyColor(level['difficulty'] as String)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(level['name'],
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                        blurRadius: 4)
                                  ])),
                          const SizedBox(height: 4),
                          Text(level['description'],
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9))),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(
                                3,
                                (i) => Icon(
                                    i < (completed ? 3 : 0)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFD700),
                                    size: 22)),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      unlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ],
                ),
              ),
              if (unlockDog != null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_open,
                          color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 6),
                      Text('Beat this level → unlock ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12)),
                      Text(unlockDog['icon'] ?? '',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(unlockDog['name'] ?? '',
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10)),
      );

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Easy':      return const Color(0xFF27AE60);
      case 'Medium':    return const Color(0xFFF39C12);
      case 'Hard':      return const Color(0xFFE67E22);
      case 'Very Hard': return const Color(0xFFE74C3C);
      case 'Boss':      return const Color(0xFF8E44AD);
      default:          return Colors.grey;
    }
  }
}