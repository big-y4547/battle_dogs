import 'package:flutter/material.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Arial',
      ),
      home: const BattleDogsMainPage(),
    );
  }
}

class BattleDogsMainPage extends StatefulWidget {
  const BattleDogsMainPage({super.key});

  @override
  State<BattleDogsMainPage> createState() => _BattleDogsMainPageState();
}

class _BattleDogsMainPageState extends State<BattleDogsMainPage> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  final int _coins = 15750;
  final int _level = 23;
    void _showDialog(){
    showDialog(context: context, builder: (BuildContext context) { 
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C), size: 28),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Color(0xFF95A5A6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage(title: 'Login'),));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
     },);
  }

  final List<Map<String, dynamic>> _leaderboard = [
    {'rank': 1, 'name': 'DogMaster99', 'level': 45, 'avatar': '🦮'},
    {'rank': 2, 'name': 'PuppyKing', 'level': 42, 'avatar': '🐕‍🦺'},
    {'rank': 3, 'name': 'CanineChamp', 'level': 40, 'avatar': '🐶'},
    {'rank': 4, 'name': 'WolfWarrior', 'level': 38, 'avatar': '🐺'},
    {'rank': 5, 'name': 'HuskyHero', 'level': 36, 'avatar': '🐕'},
    {'rank': 6, 'name': 'RetrieverRex', 'level': 34, 'avatar': '🦴'},
    {'rank': 7, 'name': 'BulldogBoss', 'level': 32, 'avatar': '🐾'},
    {'rank': 8, 'name': 'BeagleBeast', 'level': 30, 'avatar': '🐕‍🦺'},
  ];

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6DD5FA),
              const Color(0xFF2980B9),
              const Color(0xFF1E3C72),
            ],
            stops: const [0.0, 0.6, 1.0],
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
                    SingleChildScrollView(
                      child:                       Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildLogo(),
                          const SizedBox(height: 20),
                          _buildLeaderboard(),
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
        gradient: LinearGradient(
          colors: [
            const Color(0xF08B4513),
            const Color(0xF0654321),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(72, 152, 75, 16), width: 3),
        boxShadow: [
          const BoxShadow(
            color: Color(0x80000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResourceDisplay(Icons.star_rounded, 'LV.$_level', const Color(0xFFFF6B9D)),
          _buildResourceDisplay(Icons.monetization_on_rounded, '$_coins', const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildResourceDisplay(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22, shadows: const [
            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)
          ]),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              shadows: [
                Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 2)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 60,
              left: -50 + (_cloudController.value * MediaQuery.of(context).size.width * 1.5),
              child: _buildCloud(100, 0.7),
            ),
            Positioned(
              top: 150,
              left: -80 + (_cloudController.value * MediaQuery.of(context).size.width * 1.3),
              child: _buildCloud(80, 0.6),
            ),
            Positioned(
              top: 100,
              left: -100 + (_cloudController.value * MediaQuery.of(context).size.width * 1.4),
              child: _buildCloud(70, 0.5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCloud(double size, double opacity) {
    final cloudOpacity = (opacity * 255).toInt();
    final colorValue = 0xFFFFFF | (cloudOpacity << 24);
    
    return Row(
      children: [
        Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: Color(colorValue),
            shape: BoxShape.circle,
          ),
        ),
        Transform.translate(
          offset: Offset(-size * 0.3, 0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(-size * 0.6, 0),
          child: Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrassGround() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
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
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color.fromARGB(153, 247, 132, 2), width: 5),
        boxShadow: [
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
          const BoxShadow(
            color: Color(0x99F7931E),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Text(
        '🦴 BATTLE DOGS 🦴',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
          shadows: [
            Shadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 6),
            Shadow(color: Color(0xFF8B0000), offset: Offset(-2, -2), blurRadius: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF0FFFFFF),
            Color(0xE6F5F5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
                SizedBox(width: 8),
                Text(
                  'LEADERBOARD',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
              ],
            ),
          ),
          const Divider(thickness: 2, color: Color(0xFFFFD700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                return _buildLeaderboardItem(_leaderboard[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player) {
    Color rankColor;
    if (player['rank'] == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
    } else if (player['rank'] == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
    } else if (player['rank'] == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankColor = const Color(0xFF95A5A6); // Gray
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFFFF),
            // ignore: deprecated_member_use
            Color(rankColor.value & 0x00FFFFFF | 0x1A000000),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '#${player['rank']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            player['avatar'],
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B9D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Lv.${player['level']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                child: _buildBattleButton(
                  '⚔️ BATTLE',
                  const Color.fromARGB(255, 183, 37, 21),
                  const Color(0xFFE74C3C),
                  const Color(0xFFC0392B),
                  () {},
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSettingsButton(
                  '⚙️ SETTINGS',
                  const Color.fromARGB(255, 220, 227, 227),
                  const Color(0xFF95A5A6),
                  const Color(0xFF7F8C8D),
                  () {},
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGachaButton(
                  '🎁 GACHA',
                  const Color.fromARGB(255, 189, 92, 231),
                  const Color(0xFF9B59B6),
                  const Color(0xFF8E44AD),
                  () {},
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildogsButton(
                  '🐶 MY PACK',
                  const Color.fromARGB(255, 215, 149, 42),
                  const Color(0xFFF39C12),
                  const Color(0xFFE67E22),
                  () {},
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(
            '🚪 LOGOUT',
            const Color.fromARGB(255, 223, 119, 23),
            const Color(0xFFE74C3C),
            const Color(0xFFC0392B),
            () {},
            isSmall: true,
          ),
        ],
      ),
    );
  }

    Widget _buildLogoutButton(String text,Color bordercolor, Color topColor, Color bottomColor, VoidCallback onTap, {bool isSmall = false}) {
    return GestureDetector(
      onTap: _showDialog,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: bordercolor, width: 4),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              Shadow(color: Colors.black54, offset: Offset(-1, -1), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
   Widget _buildBattleButton(String text,Color bordercolor, Color topColor, Color bottomColor, VoidCallback onTap, {bool isSmall = false}) {
    return ElevatedButton(
      onPressed:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LevelsPage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: bordercolor, width: 4),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              Shadow(color: Colors.black54, offset: Offset(-1, -1), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
     Widget _buildSettingsButton(String text,Color bordercolor, Color topColor, Color bottomColor, VoidCallback onTap, {bool isSmall = false}) {
    return ElevatedButton(
      onPressed:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingsPage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: bordercolor, width: 4),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              Shadow(color: Colors.black54, offset: Offset(-1, -1), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
     Widget _buildGachaButton(String text,Color bordercolor, Color topColor, Color bottomColor, VoidCallback onTap, {bool isSmall = false}) {
    return ElevatedButton(
      onPressed:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>GachaPage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: bordercolor, width: 4),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              Shadow(color: Colors.black54, offset: Offset(-1, -1), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
     Widget _buildogsButton(String text,Color bordercolor, Color topColor, Color bottomColor, VoidCallback onTap, {bool isSmall = false}) {
    return ElevatedButton(
      onPressed:(){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MyDogsPage()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, bottomColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: bordercolor, width: 4),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 18 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 4),
              Shadow(color: Colors.black54, offset: Offset(-1, -1), blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }
}