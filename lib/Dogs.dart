import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battle_dogs/BattleDogsMainPage.dart';

// ─────────────────────────────────────────────
//  Master dog catalogue — 10 dogified Battle Cats
//  Each dog mirrors a Battle Cats unit but dogified:
//  dog nose, tail, dog ears instead of cat ears
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> kAllDogs = [

  // ── 3 starters ──────────────────────────────

  // 1. Basic Cat → Basic Dog
  {
    'id': 'basic_dog',
    'name': 'Basic Dog',
    'rarity': 'Common',
    'icon': '🐕',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFFDDDDDD,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 30,
    'power': 180,
    'speed': 35,
    'health': 60,
    'damage': 12,
    'attackRange': 60.0,
    'attackCooldown': 1.0,
    'cost': 50,
    'starter': true,
    'unlockedByLevel': null,
    'description': 'The reliable all-rounder. Never lets you down!',
  },

  // 2. Tank Cat → Tank Dog
  {
    'id': 'tank_dog',
    'name': 'Tank Dog',
    'rarity': 'Rare',
    'icon': '🛡️',
    'bodyColor': 0xFFBDBDBD,
    'accentColor': 0xFF757575,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 30,
    'power': 310,
    'speed': 18,
    'health': 200,
    'damage': 10,
    'attackRange': 55.0,
    'attackCooldown': 2.0,
    'cost': 100,
    'starter': true,
    'unlockedByLevel': null,
    'description': 'Built like a fortress. Soaks up hits for the pack.',
  },

  // 3. Axe Cat → Axe Dog
  {
    'id': 'axe_dog',
    'name': 'Axe Dog',
    'rarity': 'Rare',
    'icon': '🪓',
    'bodyColor': 0xFFFF8A65,
    'accentColor': 0xFFBF360C,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 30,
    'power': 260,
    'speed': 28,
    'health': 90,
    'damage': 30,
    'attackRange': 65.0,
    'attackCooldown': 1.5,
    'cost': 150,
    'starter': true,
    'unlockedByLevel': null,
    'description': 'Swings a big axe. Hits hard and looks great doing it.',
  },

  // ── 2 level-unlock dogs ──────────────────────

  // 4. Gross Cat → Gross Dog (long stilty legs)
  {
    'id': 'gross_dog',
    'name': 'Gross Dog',
    'rarity': 'Epic',
    'icon': '🦯',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFFEEEEEE,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 40,
    'power': 390,
    'speed': 22,
    'health': 120,
    'damage': 28,
    'attackRange': 70.0,
    'attackCooldown': 1.6,
    'cost': 180,
    'starter': false,
    'unlockedByLevel': 2,
    'description': 'Freakishly long legs. Nobody knows how it walks. Unlock at Level 2.',
  },

  // 5. Cow Cat → Cow Dog (cow spots, horns)
  {
    'id': 'cow_dog',
    'name': 'Cow Dog',
    'rarity': 'Epic',
    'icon': '🐄',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFF1A1A2E,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 40,
    'power': 440,
    'speed': 42,
    'health': 110,
    'damage': 25,
    'attackRange': 75.0,
    'attackCooldown': 1.1,
    'cost': 200,
    'starter': false,
    'unlockedByLevel': 3,
    'description': 'Moo. Charges at full speed. Unlock at Level 3.',
  },

  // ── 5 gacha-only dogs ────────────────────────

  // 6. Bird Cat → Bird Dog (wings!)
  {
    'id': 'bird_dog',
    'name': 'Bird Dog',
    'rarity': 'Legendary',
    'icon': '🦅',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFFFFD700,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 50,
    'power': 700,
    'speed': 50,
    'health': 150,
    'damage': 45,
    'attackRange': 90.0,
    'attackCooldown': 1.2,
    'cost': 250,
    'starter': false,
    'unlockedByLevel': null,
    'description': 'Soars through battle on majestic wings. Gacha only.',
  },

  // 7. Fish Cat → Fish Dog (fish fins/tail)
  {
    'id': 'fish_dog',
    'name': 'Fish Dog',
    'rarity': 'Epic',
    'icon': '🐟',
    'bodyColor': 0xFF80DEEA,
    'accentColor': 0xFF0097A7,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 40,
    'power': 550,
    'speed': 48,
    'health': 100,
    'damage': 38,
    'attackRange': 80.0,
    'attackCooldown': 1.0,
    'cost': 220,
    'starter': false,
    'unlockedByLevel': null,
    'description': 'Half dog, half fish. All fighter. Gacha only.',
  },

  // 8. Lizard Cat → Lizard Dog (long neck, spits)
  {
    'id': 'lizard_dog',
    'name': 'Lizard Dog',
    'rarity': 'Epic',
    'icon': '🦎',
    'bodyColor': 0xFF81C784,
    'accentColor': 0xFF2E7D32,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 40,
    'power': 580,
    'speed': 30,
    'health': 130,
    'damage': 42,
    'attackRange': 115.0,
    'attackCooldown': 2.2,
    'cost': 210,
    'starter': false,
    'unlockedByLevel': null,
    'description': 'Long neck means long range attacks. Gacha only.',
  },

  // 9. Titan Cat → Titan Dog (huge, powerful)
  {
    'id': 'titan_dog',
    'name': 'Titan Dog',
    'rarity': 'Legendary',
    'icon': '💪',
    'bodyColor': 0xFFFFFFFF,
    'accentColor': 0xFF9E9E9E,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 50,
    'power': 900,
    'speed': 14,
    'health': 280,
    'damage': 60,
    'attackRange': 70.0,
    'attackCooldown': 2.5,
    'cost': 280,
    'starter': false,
    'unlockedByLevel': null,
    'description': 'Absolutely massive. Shakes the ground when it walks. Gacha only.',
  },

  // 10. Mythical Titan Cat → Dragon Dog
  {
    'id': 'dragon_dog',
    'name': 'Dragon Dog',
    'rarity': 'Legendary',
    'icon': '🐲',
    'bodyColor': 0xFFFFD700,
    'accentColor': 0xFFFF4500,
    'outlineColor': 0xFF1A1A2E,
    'level': 1,
    'maxLevel': 50,
    'power': 1100,
    'speed': 35,
    'health': 220,
    'damage': 70,
    'attackRange': 85.0,
    'attackCooldown': 1.8,
    'cost': 320,
    'starter': false,
    'unlockedByLevel': null,
    'description': 'Ancient power of dragon and dog combined. Gacha only.',
  },
];

Map<String, dynamic>? getDogById(String id) =>
    kAllDogs.firstWhere((d) => d['id'] == id, orElse: () => <String, dynamic>{});

// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────
class MyDogsPage extends StatefulWidget {
  const MyDogsPage({super.key});

  @override
  State<MyDogsPage> createState() => _MyDogsPageState();
}

class _MyDogsPageState extends State<MyDogsPage> {
  final _supabase = Supabase.instance.client;

  List<String> _ownedIds = [];
  List<String> _squadIds = [];
  bool _loading = true;
  String _selectedFilter = 'All';

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
        .select('owned_dogs, squad')
        .eq('user_id', user.id)
        .maybeSingle();

    // Map old IDs to new IDs for migration
    const idMap = {
      'corgi':        'basic_dog',
      'husky':        'tank_dog',
      'bulldog':      'gross_dog',
      'dalmation':    'fish_dog',
      'shepherd':     'cow_dog',
      'dragon_hound': 'dragon_dog',
      'cyber_poodle': 'bird_dog',
      'wolf_samurai': 'lizard_dog',
      'golden_knight':'titan_dog',
      'beagle_scout': 'axe_dog',
    };

    final validIds = kAllDogs.map((d) => d['id'] as String).toSet();

    List<String> migrateIds(List<String> ids) {
      return ids
          .map((id) => idMap[id] ?? id)
          .where((id) => validIds.contains(id))
          .toList();
    }

    final starterIds = kAllDogs
        .where((d) => d['starter'] == true)
        .map((d) => d['id'] as String)
        .toList();

    if (res == null) {
      await _supabase.from('players').upsert({
        'user_id': user.id,
        'owned_dogs': starterIds,
        'squad': starterIds,
        'coins': 500,
        'level': 1,
        'completed_levels': <int>[],
      });
      setState(() {
        _ownedIds = starterIds;
        _squadIds = List<String>.from(starterIds);
        _loading = false;
      });
    } else {
      var ownedIds = migrateIds(List<String>.from(res['owned_dogs'] ?? []));
      var squadIds = migrateIds(List<String>.from(res['squad'] ?? []));

      // If nothing valid remains after migration, give starters
      if (ownedIds.isEmpty) ownedIds = List<String>.from(starterIds);
      if (squadIds.isEmpty) squadIds = List<String>.from(starterIds);

      // Persist migrated IDs back to Supabase
      await _supabase.from('players').update({
        'owned_dogs': ownedIds,
        'squad': squadIds,
      }).eq('user_id', user.id);

      setState(() {
        _ownedIds = ownedIds;
        _squadIds = squadIds;
        _loading = false;
      });
    }
  }

  Future<void> _saveSquad() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from('players')
        .update({'squad': _squadIds}).eq('user_id', user.id);
  }

  void _toggleSquad(String dogId) {
    setState(() {
      if (_squadIds.contains(dogId)) {
        _squadIds.remove(dogId);
      } else {
        if (_squadIds.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Squad is full! Remove a dog first.'),
            backgroundColor: Color(0xFFE74C3C),
          ));
          return;
        }
        _squadIds.add(dogId);
      }
    });
    _saveSquad();
  }

  List<Map<String, dynamic>> get _filteredDogs {
    final owned = kAllDogs.where((d) => _ownedIds.contains(d['id'])).toList();
    if (_selectedFilter == 'All') return owned;
    return owned.where((d) => d['rarity'] == _selectedFilter).toList();
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
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    _buildHeader(),
                    _buildSquadBar(),
                    _buildFilterBar(),
                    Expanded(child: _buildDogsList()),
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
            child: Text('🐶 MY PACK',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSquadBar() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xE6FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚔️ SQUAD (${_squadIds.length}/5)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              if (i < _squadIds.length) {
                final dog = getDogById(_squadIds[i]);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleSquad(_squadIds[i]),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(dog?['bodyColor'] ?? 0xFF95A5A6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(dog?['icon'] ?? '?', style: const TextStyle(fontSize: 22)),
                          Text(dog?['name']?.toString().split(' ').first ?? '',
                              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Legendary', 'Epic', 'Rare', 'Common'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          final sel = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel
                    ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFF39C12)])
                    : const LinearGradient(colors: [Color(0xE6FFFFFF), Color(0xD9F5F5F5)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? Colors.white : const Color(0xFFBDC3C7), width: 2),
              ),
              child: Text(f,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: sel ? Colors.white : const Color(0xFF2C3E50))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDogsList() {
    final dogs = _filteredDogs;
    if (dogs.isEmpty) {
      return const Center(
          child: Text('No dogs here yet!',
              style: TextStyle(color: Colors.white, fontSize: 18)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dogs.length,
      itemBuilder: (_, i) => _buildDogCard(dogs[i]),
    );
  }

  Widget _buildDogCard(Map<String, dynamic> dog) {
    final inSquad = _squadIds.contains(dog['id']);
    final cardColor = Color(dog['bodyColor'] as int);
    final borderColor = cardColor == const Color(0xFFFFFFFF) ? const Color(0xFF9E9E9E) : cardColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xF0FFFFFF), borderColor.withOpacity(0.15)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: inSquad ? const Color(0xFFFFD700) : borderColor,
            width: inSquad ? 4 : 3),
        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          // Avatar — drawn with CustomPaint to match in-game look
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(painter: _DogCardPainter(dog: dog)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(dog['name'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)))),
                    _rarityBadge(dog['rarity'], borderColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(dog['description'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF7F8C8D))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statChip('⚡', '${dog['power']}', const Color(0xFFE74C3C)),
                    const SizedBox(width: 8),
                    _statChip('💨', '${dog['speed']}', const Color(0xFF3498DB)),
                    const SizedBox(width: 8),
                    _statChip('❤️', '${dog['health']}', const Color(0xFF27AE60)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _toggleSquad(dog['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: inSquad ? const Color(0xFFFFD700) : const Color(0xFF27AE60),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(inSquad ? Icons.check : Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rarityBadge(String rarity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(rarity,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _statChip(String icon, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 2),
          Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CustomPainter that draws a mini version of
//  the in-game dog in the My Pack card
// ─────────────────────────────────────────────
class _DogCardPainter extends CustomPainter {
  final Map<String, dynamic> dog;
  const _DogCardPainter({required this.dog});

  static const _ol = Color(0xFF1A1A2E);
  static const _wh = Colors.white;
  static Paint _p(Color c) => Paint()..color = c;

  @override
  void paint(Canvas canvas, Size size) {
    final id = dog['id'] as String;
    final body = Color(dog['bodyColor'] as int);
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;

    // Draw based on dog type — simplified versions
    switch (id) {
      case 'basic_dog':
        _drawBasic(canvas, cx, cy, body);
        break;
      case 'tank_dog':
        _drawTank(canvas, cx, cy, body);
        break;
      case 'axe_dog':
        _drawAxe(canvas, cx, cy, body);
        break;
      case 'gross_dog':
        _drawGross(canvas, cx, cy, body);
        break;
      case 'cow_dog':
        _drawCow(canvas, cx, cy, body);
        break;
      case 'bird_dog':
        _drawBird(canvas, cx, cy, body);
        break;
      case 'fish_dog':
        _drawFish(canvas, cx, cy, body);
        break;
      case 'lizard_dog':
        _drawLizard(canvas, cx, cy, body);
        break;
      case 'titan_dog':
        _drawTitan(canvas, cx, cy, body);
        break;
      case 'dragon_dog':
        _drawDragon(canvas, cx, cy, body);
        break;
      default:
        _drawBasic(canvas, cx, cy, body);
    }
  }

  void _dogNose(Canvas canvas, double cx, double cy) {
    // Shared dog nose: small dark oval
    canvas.drawOval(
        Rect.fromLTWH(cx - 3.5, cy - 1, 7, 5), _p(_ol));
    canvas.drawOval(
        Rect.fromLTWH(cx - 2.5, cy, 5, 3.5), _p(const Color(0xFF4A4A4A)));
    // Nostrils
    canvas.drawCircle(Offset(cx - 1.5, cy + 1), 0.8, _p(_ol));
    canvas.drawCircle(Offset(cx + 1.5, cy + 1), 0.8, _p(_ol));
  }

  void _dogTail(Canvas canvas, double cx, double cy, {bool left = false}) {
    final path = Path();
    if (!left) {
      path.moveTo(cx + 13, cy + 2);
      path.quadraticBezierTo(cx + 20, cy - 6, cx + 18, cy - 14);
    } else {
      path.moveTo(cx - 13, cy + 2);
      path.quadraticBezierTo(cx - 20, cy - 6, cx - 18, cy - 14);
    }
    canvas.drawPath(path, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round);
    final path2 = Path();
    if (!left) {
      path2.moveTo(cx + 13, cy + 2);
      path2.quadraticBezierTo(cx + 19, cy - 5, cx + 18, cy - 13);
    } else {
      path2.moveTo(cx - 13, cy + 2);
      path2.quadraticBezierTo(cx - 19, cy - 5, cx - 18, cy - 13);
    }
    canvas.drawPath(path2, Paint()
      ..color = _wh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round);
  }

  void _pointyEar(Canvas canvas, double cx, double cy, bool flip, Color fill) {
    final p = Path();
    if (!flip) {
      p.moveTo(cx + 3, cy + 3);
      p.lineTo(cx - 3, cy - 9);
      p.lineTo(cx + 7, cy - 5);
    } else {
      p.moveTo(cx - 3, cy + 3);
      p.lineTo(cx + 3, cy - 9);
      p.lineTo(cx - 7, cy - 5);
    }
    p.close();
    canvas.drawPath(p, _p(_ol));
    final p2 = Path();
    if (!flip) {
      p2.moveTo(cx + 2, cy + 1);
      p2.lineTo(cx - 1, cy - 6);
      p2.lineTo(cx + 5, cy - 3);
    } else {
      p2.moveTo(cx - 2, cy + 1);
      p2.lineTo(cx + 1, cy - 6);
      p2.lineTo(cx - 5, cy - 3);
    }
    p2.close();
    canvas.drawPath(p2, _p(fill));
  }

  void _eyes(Canvas canvas, double cx, double cy) {
    canvas.drawCircle(Offset(cx - 5, cy), 2.5, _p(_ol));
    canvas.drawCircle(Offset(cx + 5, cy), 2.5, _p(_ol));
    canvas.drawCircle(Offset(cx - 4.5, cy - 0.5), 0.9, _p(_wh));
    canvas.drawCircle(Offset(cx + 5.5, cy - 0.5), 0.9, _p(_wh));
  }

  void _smile(Canvas canvas, double cx, double cy) {
    canvas.drawRect(Rect.fromLTWH(cx - 5, cy, 10, 1.8), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 5, cy - 1.5, 1.8, 2), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 3.2, cy - 1.5, 1.8, 2), _p(_ol));
  }

  void _legs(Canvas canvas, double cx, double cy) {
    canvas.drawRect(Rect.fromLTWH(cx - 8, cy, 5, 7), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 3, cy, 5, 7), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 9, cy + 6, 7, 3), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 2, cy + 6, 7, 3), _p(_ol));
  }

  // ── Individual dog card drawings ──

  void _drawBasic(Canvas canvas, double cx, double cy, Color body) {
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy);
    canvas.drawCircle(Offset(cx, cy), 17, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 15, _p(body));
    canvas.drawCircle(Offset(cx - 6, cy - 6), 5, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 8, cy - 13, false, body);
    _pointyEar(canvas, cx + 8, cy - 13, true, body);
    _eyes(canvas, cx, cy - 2);
    _dogNose(canvas, cx, cy + 4);
    _smile(canvas, cx, cy + 9);
  }

  void _drawTank(Canvas canvas, double cx, double cy, Color body) {
    // Wider, shield-like
    _legs(canvas, cx, cy + 12);
    _dogTail(canvas, cx, cy);
    canvas.drawOval(Rect.fromLTWH(cx - 19, cy - 16, 38, 30), _p(_ol));
    canvas.drawOval(Rect.fromLTWH(cx - 17, cy - 14, 34, 26), _p(body));
    canvas.drawCircle(Offset(cx - 7, cy - 8), 5, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 10, cy - 15, false, body);
    _pointyEar(canvas, cx + 10, cy - 15, true, body);
    _eyes(canvas, cx, cy - 4);
    _dogNose(canvas, cx, cy + 2);
    _smile(canvas, cx, cy + 7);
  }

  void _drawAxe(Canvas canvas, double cx, double cy, Color body) {
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy - 2);
    canvas.drawCircle(Offset(cx, cy), 15, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 13, _p(body));
    canvas.drawCircle(Offset(cx - 5, cy - 5), 4, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 7, cy - 12, false, body);
    _pointyEar(canvas, cx + 7, cy - 12, true, body);
    _eyes(canvas, cx, cy - 2);
    _dogNose(canvas, cx, cy + 4);
    _smile(canvas, cx, cy + 8);
    // Axe — right side
    canvas.drawRect(Rect.fromLTWH(cx + 14, cy - 14, 3, 22), _p(_ol));
    final axePath = Path();
    axePath.moveTo(cx + 17, cy - 14);
    axePath.lineTo(cx + 26, cy - 10);
    axePath.lineTo(cx + 26, cy - 2);
    axePath.lineTo(cx + 17, cy + 2);
    axePath.close();
    canvas.drawPath(axePath, _p(const Color(0xFF9E9E9E)));
    canvas.drawPath(axePath, Paint()
      ..color = _ol
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  void _drawGross(Canvas canvas, double cx, double cy, Color body) {
    // Long legs, small head high up
    // Legs
    canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 2, 5, 22), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx - 7, cy - 1, 3, 20), _p(_wh));
    canvas.drawRect(Rect.fromLTWH(cx + 3, cy - 2, 5, 22), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 4, cy - 1, 3, 20), _p(_wh));
    canvas.drawRect(Rect.fromLTWH(cx - 10, cy + 19, 9, 3), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 1, cy + 19, 9, 3), _p(_ol));
    // Tail
    _dogTail(canvas, cx, cy - 22);
    // Head (high up)
    canvas.drawCircle(Offset(cx, cy - 20), 13, _p(_ol));
    canvas.drawCircle(Offset(cx, cy - 20), 11, _p(body));
    canvas.drawCircle(Offset(cx - 4, cy - 26), 3.5, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 7, cy - 31, false, body);
    _pointyEar(canvas, cx + 7, cy - 31, true, body);
    _eyes(canvas, cx, cy - 22);
    _dogNose(canvas, cx, cy - 16);
  }

  void _drawCow(Canvas canvas, double cx, double cy, Color body) {
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy);
    canvas.drawCircle(Offset(cx, cy), 16, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 14, _p(body));
    // Black spots
    canvas.drawCircle(Offset(cx - 6, cy + 2), 5, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx + 5, cy - 5), 4, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx + 3, cy + 7), 3, _p(const Color(0xFF1A1A2E)));
    canvas.drawCircle(Offset(cx - 6, cy - 6), 4, _p(_wh.withOpacity(0.4)));
    // Horns
    _drawHorn(canvas, cx - 9, cy - 15, -0.4, const Color(0xFFDAA520));
    _drawHorn(canvas, cx + 9, cy - 15, 0.4, const Color(0xFFDAA520));
    _eyes(canvas, cx, cy - 2);
    _dogNose(canvas, cx, cy + 5);
    _smile(canvas, cx, cy + 9);
  }

  void _drawHorn(Canvas canvas, double cx, double cy, double angle, Color color) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.drawRect(Rect.fromLTWH(-2.5, -10, 5, 10), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(-1.5, -9, 3, 8), _p(color));
    canvas.restore();
  }

  void _drawBird(Canvas canvas, double cx, double cy, Color body) {
    // Wings behind body
    _drawWing(canvas, cx - 14, cy - 2, false);
    _drawWing(canvas, cx + 14, cy - 2, true);
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy - 2);
    canvas.drawCircle(Offset(cx, cy), 15, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 13, _p(body));
    canvas.drawCircle(Offset(cx - 5, cy - 5), 4, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 7, cy - 12, false, body);
    _pointyEar(canvas, cx + 7, cy - 12, true, body);
    _eyes(canvas, cx, cy - 2);
    _dogNose(canvas, cx, cy + 4);
    _smile(canvas, cx, cy + 8);
  }

  void _drawWing(Canvas canvas, double cx, double cy, bool flip) {
    final path = Path();
    if (!flip) {
      path.moveTo(cx + 6, cy);
      path.lineTo(cx - 8, cy - 10);
      path.lineTo(cx - 6, cy + 4);
      path.lineTo(cx - 2, cy + 10);
      path.lineTo(cx + 4, cy + 6);
    } else {
      path.moveTo(cx - 6, cy);
      path.lineTo(cx + 8, cy - 10);
      path.lineTo(cx + 6, cy + 4);
      path.lineTo(cx + 2, cy + 10);
      path.lineTo(cx - 4, cy + 6);
    }
    path.close();
    canvas.drawPath(path, _p(_ol));
    final path2 = Path();
    if (!flip) {
      path2.moveTo(cx + 4, cy);
      path2.lineTo(cx - 6, cy - 7);
      path2.lineTo(cx - 4, cy + 3);
      path2.lineTo(cx - 1, cy + 7);
      path2.lineTo(cx + 3, cy + 5);
    } else {
      path2.moveTo(cx - 4, cy);
      path2.lineTo(cx + 6, cy - 7);
      path2.lineTo(cx + 4, cy + 3);
      path2.lineTo(cx + 1, cy + 7);
      path2.lineTo(cx - 3, cy + 5);
    }
    path2.close();
    canvas.drawPath(path2, _p(const Color(0xFFFFD700)));
  }

  void _drawFish(Canvas canvas, double cx, double cy, Color body) {
    // Fish tail instead of normal tail
    final tailPath = Path();
    tailPath.moveTo(cx + 13, cy + 2);
    tailPath.lineTo(cx + 24, cy - 6);
    tailPath.lineTo(cx + 22, cy + 2);
    tailPath.lineTo(cx + 24, cy + 10);
    tailPath.close();
    canvas.drawPath(tailPath, _p(_ol));
    canvas.drawPath(tailPath..shift(const Offset(-1, 0)), _p(body));
    // Fins on top
    final finPath = Path();
    finPath.moveTo(cx - 4, cy - 14);
    finPath.lineTo(cx - 8, cy - 24);
    finPath.lineTo(cx + 4, cy - 14);
    finPath.close();
    canvas.drawPath(finPath, _p(_ol));
    canvas.drawPath(finPath, Paint()..color = body.withOpacity(0.7));
    _legs(canvas, cx, cy + 10);
    canvas.drawCircle(Offset(cx, cy), 15, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 13, _p(body));
    // Scales texture
    canvas.drawCircle(Offset(cx - 5, cy + 3), 3, _p(body.withOpacity(0.5)));
    canvas.drawCircle(Offset(cx + 3, cy + 5), 3, _p(body.withOpacity(0.5)));
    canvas.drawCircle(Offset(cx - 4, cy - 4), 3, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 7, cy - 12, false, body);
    _pointyEar(canvas, cx + 7, cy - 12, true, body);
    _eyes(canvas, cx, cy - 2);
    _dogNose(canvas, cx, cy + 4);
  }

  void _drawLizard(Canvas canvas, double cx, double cy, Color body) {
    // Long neck extending right
    canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 4, 16, 10), _p(_ol));
    canvas.drawRect(Rect.fromLTWH(cx + 11, cy - 3, 14, 8), _p(body));
    // Small head at end of neck
    canvas.drawCircle(Offset(cx + 30, cy), 9, _p(_ol));
    canvas.drawCircle(Offset(cx + 30, cy), 7, _p(body));
    _pointyEar(canvas, cx + 25, cy - 8, false, body);
    _pointyEar(canvas, cx + 31, cy - 8, true, body);
    canvas.drawCircle(Offset(cx + 28, cy - 1), 1.8, _p(_ol));
    canvas.drawCircle(Offset(cx + 33, cy - 1), 1.8, _p(_ol));
    _dogNose(canvas, cx + 30, cy + 3);
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy, left: true);
    canvas.drawCircle(Offset(cx, cy), 14, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 12, _p(body));
    canvas.drawCircle(Offset(cx - 5, cy - 5), 4, _p(_wh.withOpacity(0.35)));
    _eyes(canvas, cx - 2, cy - 1);
  }

  void _drawTitan(Canvas canvas, double cx, double cy, Color body) {
    // BIG — larger radius
    _legs(canvas, cx, cy + 14);
    _dogTail(canvas, cx, cy + 2);
    canvas.drawCircle(Offset(cx, cy), 21, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 19, _p(body));
    canvas.drawCircle(Offset(cx - 8, cy - 9), 7, _p(_wh.withOpacity(0.4)));
    _pointyEar(canvas, cx - 12, cy - 19, false, body);
    _pointyEar(canvas, cx + 12, cy - 19, true, body);
    _eyes(canvas, cx, cy - 3);
    _dogNose(canvas, cx, cy + 4);
    _smile(canvas, cx, cy + 9);
    // Size marking lines
    canvas.drawRect(Rect.fromLTWH(cx - 18, cy + 6, 4, 2), _p(_ol.withOpacity(0.3)));
    canvas.drawRect(Rect.fromLTWH(cx + 14, cy + 6, 4, 2), _p(_ol.withOpacity(0.3)));
  }

  void _drawDragon(Canvas canvas, double cx, double cy, Color body) {
    _legs(canvas, cx, cy + 10);
    _dogTail(canvas, cx, cy, left: false);
    // Dragon body
    canvas.drawCircle(Offset(cx, cy), 17, _p(_ol));
    canvas.drawCircle(Offset(cx, cy), 15, _p(body));
    canvas.drawCircle(Offset(cx - 7, cy - 7), 5, _p(_wh.withOpacity(0.3)));
    // Spiky horns
    _drawHorn(canvas, cx - 8, cy - 15, -0.3, const Color(0xFFFF5722));
    _drawHorn(canvas, cx, cy - 17, 0, const Color(0xFFFF5722));
    _drawHorn(canvas, cx + 8, cy - 15, 0.3, const Color(0xFFFF5722));
    // Fire eyes
    canvas.drawCircle(Offset(cx - 5, cy - 2), 3, _p(_ol));
    canvas.drawCircle(Offset(cx - 5, cy - 2), 1.8, _p(const Color(0xFFFF5722)));
    canvas.drawCircle(Offset(cx + 5, cy - 2), 3, _p(_ol));
    canvas.drawCircle(Offset(cx + 5, cy - 2), 1.8, _p(const Color(0xFFFF5722)));
    _dogNose(canvas, cx, cy + 5);
    // Fang
    canvas.drawRect(Rect.fromLTWH(cx - 2, cy + 10, 4, 5), _p(_wh));
  }

  @override
  bool shouldRepaint(covariant _DogCardPainter oldDelegate) => false;
}