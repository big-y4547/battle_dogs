import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/Dogs.dart';

class GachaPage extends StatefulWidget {
  const GachaPage({super.key});

  @override
  State<GachaPage> createState() => _GachaPageState();
}

class _GachaPageState extends State<GachaPage> with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;

  int _coins = 0;
  List<String> _ownedIds = [];
  bool _loading = true;

  late AnimationController _capsuleController;
  late AnimationController _shineController;
  bool _isRolling = false;

  // Only gacha dogs (no starters, no level-unlock dogs)
  static final List<Map<String, dynamic>> _gachaPool = kAllDogs
      .where((d) => d['starter'] != true && d['unlockedByLevel'] == null)
      .toList();

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
    _loadPlayerData();
  }

  @override
  void dispose() {
    _capsuleController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayerData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final res = await _supabase
        .from('players')
        .select('coins, owned_dogs')
        .eq('user_id', user.id)
        .maybeSingle();
    if (res != null) {
      setState(() {
        _coins = res['coins'] ?? 0;
        _ownedIds = List<String>.from(res['owned_dogs'] ?? []);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _persistWins(List<Map<String, dynamic>> won) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final newIds = won.map((d) => d['id'] as String).toList();
    final merged = {..._ownedIds, ...newIds}.toList();

    await _supabase.from('players').update({
      'coins': _coins,
      'owned_dogs': merged,
    }).eq('user_id', user.id);

    setState(() => _ownedIds = merged);
  }

  void _rollGacha(bool isMulti) async {
    final cost = isMulti ? 1500 : 150;
    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!'), backgroundColor: Color(0xFFE74C3C)),
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
      List<Map<String, dynamic>> pool;
      if (roll < 0.01) {
        pool = _gachaPool.where((d) => d['rarity'] == 'Legendary').toList();
      } else if (roll < 0.10) {
        pool = _gachaPool.where((d) => d['rarity'] == 'Epic').toList();
      } else if (roll < 0.35) {
        pool = _gachaPool.where((d) => d['rarity'] == 'Rare').toList();
      } else {
        pool = _gachaPool.where((d) => d['rarity'] == 'Common').toList();
      }
      if (pool.isEmpty) pool = _gachaPool;
      results.add(pool[random.nextInt(pool.length)]);
    }

    setState(() => _isRolling = false);
    await _persistWins(results);
    _showResultDialog(results);
  }

  void _showResultDialog(List<Map<String, dynamic>> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD700), Color(0xFFF39C12)]),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉 YOU GOT! 🎉',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)])),
              const SizedBox(height: 16),
              SizedBox(
                height: results.length > 1 ? 300 : 130,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: results.length > 1 ? 2 : 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: results.length,
                  itemBuilder: (_, i) => _buildResultCard(results[i]),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                child: const Text('AWESOME!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> dog) {
    final color = Color(dog['bodyColor'] as int);
    final alreadyOwned = _ownedIds.contains(dog['id']);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(dog['icon'], style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 4),
          Text(dog['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          if (alreadyOwned)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                  color: Colors.black38, borderRadius: BorderRadius.circular(6)),
              child: const Text('DUPE', style: TextStyle(fontSize: 9, color: Colors.white)),
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
              colors: [Color(0xFF6DD5FA), Color(0xFF2980B9), Color(0xFF1E3C72)],
              stops: [0.0, 0.6, 1.0]),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
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
        gradient: LinearGradient(colors: [Color(0xF08B4513), Color(0xF0654321)]),
        boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const BattleDogsMainPage())),
          ),
          const Expanded(
            child: Text('🎁 DOG GACHA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
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
        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF39C12)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: Colors.white, size: 30),
          const SizedBox(width: 10),
          Text('$_coins',
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                  shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)])),
        ],
      ),
    );
  }

  Widget _buildGachaMachine() {
    return AnimatedBuilder(
      animation: _capsuleController,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, sin(_capsuleController.value * pi * 4) * 20),
        child: Transform.rotate(
          angle: _capsuleController.value * pi * 2,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFFFF6B9D), Color(0xFFE74C3C)]),
              border: Border.all(color: const Color(0xFFFFD700), width: 8),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 10)),
                BoxShadow(color: Color(0x99FF6B9D), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: const Center(child: Text('🎁', style: TextStyle(fontSize: 90))),
          ),
        ),
      ),
    );
  }

  Widget _buildGachaButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          _buildRollButton('ROLL x1', '150', const Color(0xFF3498DB), const Color(0xFF2980B9),
              () => _rollGacha(false)),
          const SizedBox(height: 16),
          _buildRollButton('ROLL x10', '1,500', const Color(0xFF9B59B6), const Color(0xFF8E44AD),
              () => _rollGacha(true), special: true),
        ],
      ),
    );
  }

  Widget _buildRollButton(String text, String cost, Color top, Color bot, VoidCallback onTap,
      {bool special = false}) {
    return GestureDetector(
      onTap: _isRolling ? null : onTap,
      child: Opacity(
        opacity: _isRolling ? 0.5 : 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bot]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFFFD700), width: 4),
            boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 6))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(text,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4)])),
                  if (special) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.stars, color: Color(0xFFFFD700), size: 26),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(cost, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatesInfo() {
    const rates = [
      ['Common', '65%', Color(0xFF95A5A6)],
      ['Rare', '25%', Color(0xFF3498DB)],
      ['Epic', '9%', Color(0xFF9B59B6)],
      ['Legendary', '1%', Color(0xFFFFD700)],
    ];
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
          const Text('📊 DROP RATES',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 10),
          ...rates.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(radius: 6, backgroundColor: r[2] as Color),
                      const SizedBox(width: 8),
                      Text(r[0] as String,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                    ]),
                    Text(r[1] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7F8C8D))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}