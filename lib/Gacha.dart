import 'package:flutter/material.dart';
import 'dart:math';
import 'package:battle_dogs/BattleDogsMainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Dogs Gacha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),
      home: const GachaPage(),
    );
  }
}

class GachaPage extends StatefulWidget {
  const GachaPage({super.key});

  @override
  State<GachaPage> createState() => _GachaPageState();
}

class _GachaPageState extends State<GachaPage> with TickerProviderStateMixin {
  int _coins = 15750;
  late AnimationController _capsuleController;
  late AnimationController _shineController;
  bool _isRolling = false;

  final List<Map<String, dynamic>> _dogPool = [
    {'name': 'Husky Guard', 'rarity': 'Common', 'icon': '🐕‍🦺', 'color': Color(0xFF95A5A6)},
    {'name': 'Beagle Scout', 'rarity': 'Common', 'icon': '🦮', 'color': Color(0xFF95A5A6)},
    {'name': 'Golden Knight', 'rarity': 'Rare', 'icon': '🐶', 'color': Color(0xFF3498DB)},
    {'name': 'Wolf Samurai', 'rarity': 'Rare', 'icon': '🐺', 'color': Color(0xFF3498DB)},
    {'name': 'Bulldog Tank', 'rarity': 'Epic', 'icon': '🐕', 'color': Color(0xFF9B59B6)},
    {'name': 'Cyber Poodle', 'rarity': 'Epic', 'icon': '🐩', 'color': Color(0xFF9B59B6)},
    {'name': 'Dragon Hound', 'rarity': 'Legendary', 'icon': '🐲', 'color': Color(0xFFFFD700)},
  ];

  @override
  void initState() {
    super.initState();
    _capsuleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _capsuleController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _rollGacha(bool isMulti) async {
    final cost = isMulti ? 1500 : 150;
    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isRolling = true;
      _coins -= cost;
    });

    _capsuleController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 1500));

    final random = Random();
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < (isMulti ? 10 : 1); i++) {
      final roll = random.nextDouble();
      Map<String, dynamic> result;
      
      if (roll < 0.01) {
        result = _dogPool.where((d) => d['rarity'] == 'Legendary').toList()[random.nextInt(1)];
      } else if (roll < 0.10) {
        final epics = _dogPool.where((d) => d['rarity'] == 'Epic').toList();
        result = epics[random.nextInt(epics.length)];
      } else if (roll < 0.35) {
        final rares = _dogPool.where((d) => d['rarity'] == 'Rare').toList();
        result = rares[random.nextInt(rares.length)];
      } else {
        final commons = _dogPool.where((d) => d['rarity'] == 'Common').toList();
        result = commons[random.nextInt(commons.length)];
      }
      results.add(result);
    }

    setState(() {
      _isRolling = false;
    });

    _showResultDialog(results);
  }

  void _showResultDialog(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎉 YOU GOT! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: results.length > 1 ? 300 : 150,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: results.length > 1 ? 2 : 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _buildResultCard(results[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'AWESOME!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> dog) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dog['color'],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dog['icon'],
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            dog['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x4D000000),
              borderRadius: BorderRadius.circular(8),
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
    );
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCoinDisplay(),
                      const SizedBox(height: 30),
                      _buildGachaMachine(),
                      const SizedBox(height: 40),
                      _buildGachaButtons(),
                      const SizedBox(height: 30),
                      _buildRatesInfo(),
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
              '🎁 DOG GACHA',
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

  Widget _buildCoinDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Text(
            '$_coins',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaMachine() {
    return AnimatedBuilder(
      animation: _capsuleController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_capsuleController.value * pi * 4) * 20),
          child: Transform.rotate(
            angle: _capsuleController.value * pi * 2,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF6B9D),
                    const Color(0xFFE74C3C),
                  ],
                ),
                border: Border.all(color: const Color(0xFFFFD700), width: 8),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0x99FF6B9D),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🎁',
                  style: TextStyle(fontSize: 100),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGachaButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _buildGachaButton(
            'ROLL x1',
            '150',
            const Color(0xFF3498DB),
            const Color(0xFF2980B9),
            () => _rollGacha(false),
          ),
          const SizedBox(height: 16),
          _buildGachaButton(
            'ROLL x10',
            '1,500',
            const Color(0xFF9B59B6),
            const Color(0xFF8E44AD),
            () => _rollGacha(true),
            special: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGachaButton(String text, String cost, Color topColor, Color bottomColor, VoidCallback onTap, {bool special = false}) {
    return GestureDetector(
      onTap: _isRolling ? null : onTap,
      child: Opacity(
        opacity: _isRolling ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFD700), width: 4),
            boxShadow: [
              const BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                // ignore: deprecated_member_use
                color: Color(topColor.value & 0x00FFFFFF | 0x80000000),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
                      ],
                    ),
                  ),
                  if (special) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.stars, color: Color(0xFFFFD700), size: 28),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    cost,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatesInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
      ),
      child: Column(
        children: [
          const Text(
            '📊 DROP RATES',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 12),
          _buildRateRow('Common', '65%', const Color(0xFF95A5A6)),
          _buildRateRow('Rare', '25%', const Color(0xFF3498DB)),
          _buildRateRow('Epic', '9%', const Color(0xFF9B59B6)),
          _buildRateRow('Legendary', '1%', const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildRateRow(String rarity, String rate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rarity,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          Text(
            rate,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }
}