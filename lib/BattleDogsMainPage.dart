import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battle_dogs/auth/auth_serviece.dart';
import 'package:battle_dogs/login.dart';
import 'package:battle_dogs/Gacha.dart';
import 'package:battle_dogs/Dogs.dart';
import 'package:battle_dogs/levels.dart';
import 'package:battle_dogs/Settings.dart';

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
  bool _isAdmin = false;
  String? _userEmail;
  bool _loading = true;
  bool _leaderboardLoading = true;

  int _currentLeaderboardPage = 0;

  List<Map<String, dynamic>> _leaderboard = [];

  final List<String> _avatars = [
    '🦮', '🐕‍🦺', '🐶', '🐺', '🐕', '🦴', '🐾', '🐩',
  ];

  @override
  void initState() {
    super.initState();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _leaderboardPageController = PageController(viewportFraction: 1.0);

    _leaderboardController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _leaderboardController.reset();
          _leaderboardController.forward();
          if (mounted && _leaderboardPageController.hasClients && _leaderboard.isNotEmpty) {
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

    _loadPlayerData();
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _leaderboardController.dispose();
    _leaderboardPageController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await _supabase
          .from('players')
          .select('user_id, level, coins')
          .order('level', ascending: false)
          .limit(10);

      final List<Map<String, dynamic>> entries = [];
      for (int i = 0; i < data.length; i++) {
        final row = data[i];
        // Try to get email from auth — fall back to shortened user_id
        String displayName = 'Player ${i + 1}';
        try {
          final userId = row['user_id'] as String;
          displayName = 'Dog#${userId.substring(0, 6).toUpperCase()}';
        } catch (_) {}

        entries.add({
          'rank': i + 1,
          'name': displayName,
          'level': row['level'] ?? 1,
          'coins': row['coins'] ?? 0,
          'avatar': _avatars[i % _avatars.length],
          'userId': row['user_id'],
        });
      }

      if (mounted) {
        setState(() {
          _leaderboard = entries;
          _leaderboardLoading = false;
        });
        if (entries.isNotEmpty) {
          _leaderboardController.forward();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _leaderboardLoading = false);
      }
    }
  }

Future<void> _loadPlayerData() async {
  final user = _supabase.auth.currentUser;
  _userEmail = user?.email;

  if (user != null) {
    final existing = await _supabase
        .from('players')
        .select('coins, level, is_admin')  // ← הוסף is_admin
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      setState(() {
        _coins = existing['coins'] ?? 0;
        _level = existing['level'] ?? 1;
        _isAdmin = existing['is_admin'] == true;  // ← הוסף שורה זו
      });
    } else {
      await _supabase.from('players').upsert({
        'user_id': user.id,
        'coins': 500,
        'level': 1,
        'owned_dogs': ['basic_dog', 'tank_dog', 'axe_dog'],
        'squad': ['basic_dog', 'tank_dog', 'axe_dog'],
        'completed_levels': [],
        'is_admin': false,
      }, onConflict: 'user_id');
      setState(() {
        _coins = 500;
        _level = 1;
        _isAdmin = false;
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
            onPressed: () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
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
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
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
                          child: CircularProgressIndicator(color: Colors.white))
                    else
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildLogo(),
                            const SizedBox(height: 16),
                            _buildLeaderboardCarousel(),
                            const SizedBox(height: 16),
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
    // Shrink email to fit on narrow screens
    final shortEmail = _userEmail != null && _userEmail!.length > 14
        ? '${_userEmail!.substring(0, 12)}…'
        : (_userEmail ?? '');

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          _buildResourceDisplay(
              Icons.email_rounded, shortEmail, const Color(0xFF3498DB)),
        ],
      ),
    );
  }

  Widget _buildResourceDisplay(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2)
                  ])),
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
                Color(0xFF229954),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
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
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                    color: Colors.black, offset: Offset(3, 3), blurRadius: 6)
              ]),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24),
              SizedBox(width: 8),
              Text('LEADERBOARD',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
              SizedBox(width: 8),
              Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 24),
            ],
          ),
          const Divider(thickness: 2, color: Color(0xFFFFD700)),
          const SizedBox(height: 6),

          // Body
          if (_leaderboardLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          else if (_leaderboard.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No players yet!',
                  style: TextStyle(
                      fontSize: 15, color: Color(0xFF7F8C8D))),
            )
          else ...[
            SizedBox(
              height: 110,
              child: PageView.builder(
                controller: _leaderboardPageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) {
                  setState(() => _currentLeaderboardPage = i);
                  if (_leaderboardPageController.hasClients) {
                    _leaderboardController.reset();
                    _leaderboardController.forward();
                  }
                },
                itemCount: _leaderboard.length,
                itemBuilder: (_, i) => _buildSpotlightCard(_leaderboard[i]),
              ),
            ),
            const SizedBox(height: 8),
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
            AnimatedBuilder(
              animation: _leaderboardController,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _leaderboardController.value,
                  minHeight: 4,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFFFFD700)),
                ),
              ),
            ),
          ],
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
      child: GestureDetector(
        onLongPress: _isAdmin ? () => _showRemoveDialog(player) : null,
        child: Container(
          key: ValueKey(player['rank']),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(12),
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
                width: 48,
                height: 48,
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
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 10),
              // Avatar
              Text(player['avatar'], style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 10),
              // Name + level + coins
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(player['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50))),
                        ),
                        if (_isAdmin)
                          const Icon(Icons.remove_circle_outline,
                              size: 14, color: Color(0xFFE74C3C)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 13, color: Color(0xFFFF6B9D)),
                        const SizedBox(width: 3),
                        Text('Lv.${player['level']}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7F8C8D))),
                        const SizedBox(width: 10),
                        const Icon(Icons.monetization_on,
                            size: 13, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text('${player['coins']}',
                            style: const TextStyle(
                                fontSize: 13,
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
      ),
    );
  }

  void _showRemoveDialog(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.remove_circle, color: Color(0xFFE74C3C), size: 28),
            SizedBox(width: 10),
            Text('Remove from Leaderboard'),
          ],
        ),
        content: Text(
          'Reset ${player['name']}\'s progress?\nThis will remove them from the leaderboard.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: Color(0xFF95A5A6), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeFromLeaderboard(player['userId'] as String);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('REMOVE',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromLeaderboard(String userId) async {
    try {
      await _supabase
          .from('players')
          .update({'coins': 0, 'level': 1})
          .eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player removed from leaderboard'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
        _loadLeaderboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildMainMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LevelsPage())))),
              const SizedBox(width: 12),
              Expanded(
                  child: _menuBtn(
                      '⚙️ SETTINGS',
                      const Color(0xFF7F8C8D),
                      const Color(0xFF95A5A6),
                      const Color(0xFF7F8C8D),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsPage())))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _menuBtn(
                      '🎁 GACHA',
                      const Color(0xFFBD5CE7),
                      const Color(0xFF9B59B6),
                      const Color(0xFF8E44AD),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const GachaPage())))),
              const SizedBox(width: 12),
              Expanded(
                  child: _menuBtn(
                      '🐶 MY PACK',
                      const Color(0xFFD7952A),
                      const Color(0xFFF39C12),
                      const Color(0xFFE67E22),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MyDogsPage())))),
            ],
          ),
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
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
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
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