import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battle_dogs/auth/auth_serviece.dart';
import 'package:battle_dogs/login.dart';
import 'package:battle_dogs/Gacha.dart';
import 'package:battle_dogs/Dogs.dart';
import 'package:battle_dogs/levels.dart';
import 'package:battle_dogs/Settings.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Dogs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Arial'),
      home: const BattleDogsMainPage(),
    );
  }
}

class BattleDogsMainPage extends StatefulWidget {
  const BattleDogsMainPage({super.key});

  @override
  State<BattleDogsMainPage> createState() => _BattleDogsMainPageState();
}

class _BattleDogsMainPageState extends State<BattleDogsMainPage>
    with TickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final authServiece = AuthServiece();

  late AnimationController _cloudController;
  late AnimationController _leaderboardController;
  late PageController _leaderboardPageController;

  int _coins = 0;
  int _level = 1;
  String? _userEmail;
  bool _loading = true;

  int _currentLeaderboardPage = 0;

  // Fake leaderboard entries (no summable numbers)
  final List<Map<String, dynamic>> _leaderboard = [
    {'rank': 1, 'name': 'DogMaster99',   'level': 45, 'avatar': '🦮'},
    {'rank': 2, 'name': 'PuppyKing',     'level': 42, 'avatar': '🐕‍🦺'},
    {'rank': 3, 'name': 'CanineChamp',   'level': 40, 'avatar': '🐶'},
    {'rank': 4, 'name': 'WolfWarrior',   'level': 38, 'avatar': '🐺'},
    {'rank': 5, 'name': 'HuskyHero',     'level': 36, 'avatar': '🐕'},
    {'rank': 6, 'name': 'RetrieverRex',  'level': 34, 'avatar': '🦴'},
    {'rank': 7, 'name': 'BulldogBoss',   'level': 32, 'avatar': '🐾'},
    {'rank': 8, 'name': 'BeagleBeast',   'level': 30, 'avatar': '🐕‍🦺'},
  ];

  @override
  void initState() {
    super.initState();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _leaderboardPageController = PageController(viewportFraction: 1.0);

    // Auto-rotate leaderboard every 3 seconds
    _leaderboardController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _leaderboardController.reset();
          _leaderboardController.forward();
          if (mounted) {
            setState(() {
              _currentLeaderboardPage =
                  (_currentLeaderboardPage + 1) % _leaderboard.length;
            });
            _leaderboardPageController.animateToPage(
              _currentLeaderboardPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    _leaderboardController.forward();

    _loadPlayerData();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _leaderboardController.dispose();
    _leaderboardPageController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayerData() async {
    final user = _supabase.auth.currentUser;
    _userEmail = user?.email;

    if (user != null) {
      // Try to fetch existing record
      final existing = await _supabase
          .from('players')
          .select('coins, level')
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Existing player — use their real data
        setState(() {
          _coins = existing['coins'] ?? 0;
          _level = existing['level'] ?? 1;
        });
      } else {
        // Brand-new player — create record with 0 coins
        await _supabase.from('players').insert({
          'user_id': user.id,
          'coins': 0,
          'level': 1,
          'owned_dogs': [],
        });
        setState(() {
          _coins = 0;
          _level = 1;
        });
      }
    }

    setState(() => _loading = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 28),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: Color(0xFF95A5A6), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              await authServiece.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage(title: 'Login')),
                    (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('LOGOUT',
                style: TextStyle(color: Colors.white)),
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
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildAnimatedClouds(),
                    _buildGrassGround(),
                    if (_loading)
                      const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white))
                    else
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildLogo(),
                            const SizedBox(height: 20),
                            _buildLeaderboardCarousel(),
                            const SizedBox(height: 20),
                            _buildMainMenuButtons(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xF08B4513), Color(0xF0654321)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color.fromARGB(72, 152, 75, 16), width: 3),
        boxShadow: const [
          BoxShadow(
              color: Color(0x80000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResourceDisplay(
              Icons.star_rounded, 'LV.$_level', const Color(0xFFFF6B9D)),
          _buildResourceDisplay(Icons.monetization_on_rounded, '$_coins',
              const Color(0xFFFFD700)),
          _buildResourceDisplay(Icons.email_rounded, _userEmail ?? '',
              const Color(0xFF3498DB)),
        ],
      ),
    );
  }

  Widget _buildResourceDisplay(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 2)
                    ])),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, _) {
        final w = MediaQuery.of(context).size.width;
        return Stack(
          children: [
            Positioned(
                top: 60,
                left: -50 + _cloudController.value * w * 1.5,
                child: _buildCloud(100, 0.7)),
            Positioned(
                top: 150,
                left: -80 + _cloudController.value * w * 1.3,
                child: _buildCloud(80, 0.6)),
            Positioned(
                top: 100,
                left: -100 + _cloudController.value * w * 1.4,
                child: _buildCloud(70, 0.5)),
          ],
        );
      },
    );
  }

  Widget _buildCloud(double size, double opacity) {
    final c = Color((opacity * 255).toInt() << 24 | 0xFFFFFF);
    return Row(
      children: [
        Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        Transform.translate(
            offset: Offset(-size * 0.3, 0),
            child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
        Transform.translate(
            offset: Offset(-size * 0.6, 0),
            child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
      ],
    );
  }

  Widget _buildGrassGround() {
    return const Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x002ECC71),
                Color(0xFF27AE60),
                Color(0xFF229954)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFF7931E)]),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
            color: const Color.fromARGB(153, 247, 132, 2), width: 5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000),
              blurRadius: 15,
              offset: Offset(0, 6)),
          BoxShadow(
              color: Color(0x99F7931E), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: const Text(
        '🦴 BATTLE DOGS 🦴',
        style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                  color: Colors.black, offset: Offset(3, 3), blurRadius: 6)
            ]),
      ),
    );
  }

  // ── Leaderboard as an animated review carousel ─────────────────────────────
  Widget _buildLeaderboardCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF0FFFFFF), Color(0xE6F5F5F5)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 4),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000), blurRadius: 15, offset: Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 26),
              SizedBox(width: 8),
              Text('LEADERBOARD',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              SizedBox(width: 8),
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 26),
            ],
          ),
          const Divider(thickness: 2, color: Color(0xFFFFD700)),
          const SizedBox(height: 8),

          // Animated spotlight card — shows ONE player at a time
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: _leaderboardPageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _currentLeaderboardPage = i);
                // Restart the auto-advance timer
                _leaderboardController.reset();
                _leaderboardController.forward();
              },
              itemCount: _leaderboard.length,
              itemBuilder: (_, i) =>
                  _buildSpotlightCard(_leaderboard[i]),
            ),
          ),

          const SizedBox(height: 10),

          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _leaderboard.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentLeaderboardPage ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentLeaderboardPage
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFBDC3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar showing time until next slide
          AnimatedBuilder(
            animation: _leaderboardController,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _leaderboardController.value,
                minHeight: 4,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(Map<String, dynamic> player) {
    final rankColor = player['rank'] == 1
        ? const Color(0xFFFFD700)
        : player['rank'] == 2
            ? const Color(0xFFC0C0C0)
            : player['rank'] == 3
                ? const Color(0xFFCD7F32)
                : const Color(0xFF95A5A6);

    final rankLabel = player['rank'] == 1
        ? '🥇'
        : player['rank'] == 2
            ? '🥈'
            : player['rank'] == 3
                ? '🥉'
                : '#${player['rank']}';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(player['rank']),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, rankColor.withOpacity(0.15)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: rankColor, width: 3),
          boxShadow: [
            BoxShadow(
                color: rankColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ]),
              child: Center(
                  child: Text(rankLabel,
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 14),
            // Avatar
            Text(player['avatar'], style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            // Name + level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(player['name'],
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFF6B9D)),
                      const SizedBox(width: 4),
                      Text('Level ${player['level']}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7F8C8D))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _menuBtn(
                      '⚔️ BATTLE',
                      const Color(0xFFB72515),
                      const Color(0xFFE74C3C),
                      const Color(0xFFC0392B),
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LevelsPage())))),
              const SizedBox(width: 14),
              Expanded(
                  child: _menuBtn(
                      '⚙️ SETTINGS',
                      const Color(0xFF7F8C8D),
                      const Color(0xFF95A5A6),
                      const Color(0xFF7F8C8D),
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage())))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _menuBtn(
                      '🎁 GACHA',
                      const Color(0xFFBD5CE7),
                      const Color(0xFF9B59B6),
                      const Color(0xFF8E44AD),
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GachaPage())))),
              const SizedBox(width: 14),
              Expanded(
                  child: _menuBtn(
                      '🐶 MY PACK',
                      const Color(0xFFD7952A),
                      const Color(0xFFF39C12),
                      const Color(0xFFE67E22),
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyDogsPage())))),
            ],
          ),
          const SizedBox(height: 14),
          _menuBtn(
              '🚪 LOGOUT',
              const Color(0xFFDF7717),
              const Color(0xFFE74C3C),
              const Color(0xFFC0392B),
              _showLogoutDialog),
        ],
      ),
    );
  }

  Widget _menuBtn(String text, Color border, Color top, Color bottom,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom]),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: border, width: 4),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 6))
          ],
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 4)
                ])),
      ),
    );
  }
}