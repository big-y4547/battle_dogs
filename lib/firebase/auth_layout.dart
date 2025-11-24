import 'package:battle_dogs/BattleDogsMainPage.dart';
import 'package:battle_dogs/firebase/auth_service.dart';
import 'package:battle_dogs/firebase/loading_page.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.pageIfNotConnected});
  final Widget pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authServies,
      builder: (context, authServies, child) {
        return StreamBuilder(
          stream: authServies.authStateChnages,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = BattleDogsMainPage();
            } else {
              widget = pageIfNotConnected;
            }
            return widget;
          },
        );
      },
    );
  }
}
