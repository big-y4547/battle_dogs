import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  await Supabase.initialize(
    url: 'https://opxtpberhhpizcbzaarp.supabase.co',
    anonKey: 'sb_publishable_WYzQnGMI5jpUrO0JOTxZpA_N4gr1rKX',
  );
  runApp(const MyApp());
}
  class MyApp extends StatelessWidget {
    const MyApp({super.key});
    
      @override
      Widget build(BuildContext context) {
        return const MaterialApp(
          home: AuthGate(),
        );
      }
  }

