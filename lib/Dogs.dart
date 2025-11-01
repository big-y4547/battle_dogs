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
      title: 'My Dogs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),
      home: const MyDogsPage(),
    );
  }
}

class MyDogsPage extends StatefulWidget {
  const MyDogsPage({super.key});

  @override
  State<MyDogsPage> createState() => _MyDogsPageState();
}

class _MyDogsPageState extends State<MyDogsPage> {
  final List<Map<String, dynamic>> _myDogs = [
    {
      'name': 'Dragon Hound',
      'rarity': 'Legendary',
      'icon': '🐲',
      'level': 25,
      'maxLevel': 50,
      'power': 850,
      'color': Color(0xFFFFD700),
      'owned': true,
    },
    {
      'name': 'Cyber Poodle',
      'rarity': 'Epic',
      'icon': '🐩',
      'level': 18,
      'maxLevel': 40,
      'power': 620,
      'color': Color(0xFF9B59B6),
      'owned': true,
    },
    {
      'name': 'Bulldog Tank',
      'rarity': 'Epic',
      'icon': '🐕',
      'level': 15,
      'maxLevel': 40,
      'power': 580,
      'color': Color(0xFF9B59B6),
      'owned': true,
    },
    {
      'name': 'Wolf Samurai',
      'rarity': 'Rare',
      'icon': '🐺',
      'level': 22,
      'maxLevel': 30,
      'power': 450,
      'color': Color(0xFF3498DB),
      'owned': true,
    },
    {
      'name': 'Golden Knight',
      'rarity': 'Rare',
      'icon': '🐶',
      'level': 20,
      'maxLevel': 30,
      'power': 430,
      'color': Color(0xFF3498DB),
      'owned': true,
    },
    {
      'name': 'Husky Guard',
      'rarity': 'Common',
      'icon': '🐕‍🦺',
      'level': 28,
      'maxLevel': 30,
      'power': 365,
      'color': Color(0xFF95A5A6),
      'owned': true,
    },
    {
      'name': 'Beagle Scout',
      'rarity': 'Common',
      'icon': '🦮',
      'level': 25,
      'maxLevel': 30,
      'power': 350,
      'color': Color(0xFF95A5A6),
      'owned': true,
    },
  ];

  String _selectedFilter = 'All';

  List<Map<String, dynamic>> get _filteredDogs {
    if (_selectedFilter == 'All') {
      return _myDogs;
    }
    return _myDogs.where((dog) => dog['rarity'] == _selectedFilter).toList();
  }

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
              _buildStats(),
              _buildFilterBar(),
              Expanded(
                child: _buildDogsList(),
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
              '🐶 MY PACK',
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

  Widget _buildStats() {
    final totalDogs = _myDogs.length;
    final totalPower = _myDogs.fold(0, (sum, dog) => sum + (dog['power'] as int));
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xF0FFFFFF), Color(0xE6F5F5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🐕', 'Dogs', '$totalDogs', const Color(0xFF3498DB)),
          Container(width: 2, height: 40, color: const Color(0xFFBDC3C7)),
          _buildStatItem('⚡', 'Power', '$totalPower', const Color(0xFFE74C3C)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Legendary', 'Epic', 'Rare', 'Common'];
    
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xE6FFFFFF), Color(0xD9F5F5F5)],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFFBDC3C7),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x66FFD700),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDogs.length,
      itemBuilder: (context, index) {
        return _buildDogCard(_filteredDogs[index]);
      },
    );
  }

  Widget _buildDogCard(Map<String, dynamic> dog) {
    final progress = dog['level'] / dog['maxLevel'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xF0FFFFFF),
            Color(dog['color'].value & 0x00FFFFFF | 0x33000000),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dog['color'], width: 3),
        boxShadow: [
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(dog['color'].value & 0x00FFFFFF | 0x33000000),
            blurRadius: 15,
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
              color: dog['color'],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                dog['icon'],
                style: const TextStyle(fontSize: 45),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dog['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: dog['color'],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        dog['rarity'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFFE74C3C), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Power: ${dog['power']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Level ${dog['level']}/${dog['maxLevel']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [dog['color'], Color(dog['color'].value & 0x00FFFFFF | 0xCC000000)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (dog['level'] < dog['maxLevel']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Level up ${dog['name']}!'),
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dog['level'] < dog['maxLevel'] ? const Color(0xFF27AE60) : const Color(0xFF95A5A6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}