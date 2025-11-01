import 'package:flutter/material.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Dogs Levels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),
      home: const LevelsPage(),
    );
  }
}

class LevelsPage extends StatefulWidget {
  const LevelsPage({super.key});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  final List<Map<String, dynamic>> _levels = [
    {
      'level': 1,
      'name': 'Puppy Park',
      'difficulty': 'Easy',
      'stars': 3,
      'completed': true,
      'icon': '🏞️',
      'color': Color(0xFF27AE60),
    },
    {
      'level': 2,
      'name': 'Dog Beach',
      'difficulty': 'Easy',
      'stars': 2,
      'completed': true,
      'icon': '🏖️',
      'color': Color(0xFF3498DB),
    },
    {
      'level': 3,
      'name': 'Urban Streets',
      'difficulty': 'Medium',
      'stars': 1,
      'completed': true,
      'icon': '🏙️',
      'color': Color(0xFFF39C12),
    },
    {
      'level': 4,
      'name': 'Dark Forest',
      'difficulty': 'Hard',
      'stars': 0,
      'completed': false,
      'icon': '🌲',
      'color': Color(0xFF8E44AD),
    },
    {
      'level': 5,
      'name': 'Boss Arena',
      'difficulty': 'Boss',
      'stars': 0,
      'completed': false,
      'icon': '🏟️',
      'color': Color(0xFFE74C3C),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6DD5FA),
              Color(0xFF2980B9),
              Color(0xFF1E3C72),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildLevelsList(),
                      const SizedBox(height: 20),
                    ],
                  ),
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
        gradient: LinearGradient(
          colors: [Color(0xF08B4513), Color(0xF0654321)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>BattleDogsMainPage()));
            },
          ),
          const Expanded(
            child: Text(
              '⚔️ SELECT LEVEL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLevelsList() {
    return Column(
      children: _levels.map((level) => _buildLevelButton(level)).toList(),
    );
  }

  Widget _buildLevelButton(Map<String, dynamic> level) {
    final bool isLocked = !level['completed'] && level['level'] > 1 && !_levels[level['level'] - 2]['completed'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: isLocked ? null : () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Starting ${level['name']}...'),
              backgroundColor: level['color'],
            ),
          );
        },
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  level['color'],
                  Color(level['color'].value & 0x00FFFFFF | 0xCC000000),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 4,
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Color(level['color'].value & 0x00FFFFFF | 0x66000000),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      level['icon'],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x4D000000),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              'LEVEL ${level['level']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        level['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(level['difficulty']),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              level['difficulty'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (level['completed'])
                            Row(
                              children: List.generate(3, (index) {
                                return Icon(
                                  index < level['stars'] ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFFFD700),
                                  size: 24,
                                );
                              }),
                            ),
                          if (!level['completed'] && !isLocked)
                            const Icon(
                              Icons.lock_open,
                              color: Colors.white,
                              size: 24,
                            ),
                          if (isLocked)
                            const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLocked)
                  const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF27AE60);
      case 'Medium':
        return const Color(0xFFF39C12);
      case 'Hard':
        return const Color(0xFFE67E22);
      case 'Boss':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}