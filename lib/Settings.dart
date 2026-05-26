import 'package:battle_dogs/auth/auth_serviece.dart';
import 'package:battle_dogs/login.dart';
import 'package:battle_dogs/MusicManager.dart';
import 'package:flutter/material.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final authServiece = AuthServiece();

  double _musicVolume = 60.0;
  double _sfxVolume = 85.0;

  bool _isMusicOn = false;

  @override
  void initState() {
    super.initState();
    _isMusicOn = MusicManager.instance.isPlaying;
    _musicVolume = _isMusicOn ? 60.0 : 0.0;
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE74C3C), size: 28),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL',
                  style: TextStyle(
                      color: Color(0xFF95A5A6),
                      fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                await authServiece.signOut();
                if (mounted) {
                  MusicManager.instance.stop();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage(title: 'Login')),
                    (_) => false,
                  );
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
        );
      },
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
              Color(0xFF1E3C72)
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
                      _buildSettingsCard(),
                      const SizedBox(height: 20),
                      _buildLogoutButton(),
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
            colors: [Color(0xF08B4513), Color(0xF0654321)]),
        boxShadow: [
          BoxShadow(
              color: Color(0x80000000),
              blurRadius: 12,
              offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const BattleDogsMainPage()),
            ),
          ),
          const Expanded(
            child: Text(
              '⚙️ SETTINGS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 4)
                  ]),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF0FFFFFF), Color(0xE6F5F5F5)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFFFD700), width: 4),
        boxShadow: const [
          BoxShadow(
              color: Color(0x66000000),
              blurRadius: 15,
              offset: Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🔊 AUDIO'),
          const SizedBox(height: 16),
          _buildVolumeSlider(
            '🎵 Music Volume',
            _musicVolume,
            (value) {
              setState(() {
                _musicVolume = value;
                _isMusicOn = value > 0;
              });
              MusicManager.instance.setVolume(value / 100.0);
              if (value > 0) {
                MusicManager.instance.play();
              } else {
                MusicManager.instance.pause();
              }
            },
          ),
          const SizedBox(height: 20),
          _buildVolumeSlider(
            '🔔 SFX Volume',
            _sfxVolume,
            (value) => setState(() => _sfxVolume = value),
          ),
          const SizedBox(height: 20),
          // Music on/off toggle
          Row(
            children: [
              const Text('🎶 Background Music',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50))),
              const Spacer(),
              Switch(
                value: _isMusicOn,
                activeColor: const Color(0xFF27AE60),
                onChanged: (on) {
                  setState(() {
                    _isMusicOn = on;
                    if (on) {
                      if (_musicVolume == 0) {
                        _musicVolume = 60;
                        MusicManager.instance.setVolume(0.6);
                      }
                      MusicManager.instance.play();
                    } else {
                      MusicManager.instance.pause();
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50)));
  }

  Widget _buildVolumeSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50))),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF3498DB),
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${value.round()}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF3498DB),
            inactiveTrackColor: const Color(0xFFBDC3C7),
            thumbColor: const Color(0xFF2980B9),
            overlayColor: const Color(0x333498DB),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700), width: 4),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 6)),
            BoxShadow(
                color: Color(0x80E74C3C), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: const Text(
          '🚪 LOGOUT',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 4)
              ]),
        ),
      ),
    );
  }
}