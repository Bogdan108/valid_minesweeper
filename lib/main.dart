import 'package:flutter/material.dart';
import 'package:valid_minesweeper/activities/game.dart';
import 'package:valid_minesweeper/activities/home.dart';
import 'package:valid_minesweeper/activities/menu.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Game',
      theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            color: Colors.green,
          )),
      initialRoute: 'home',
      routes: {
        'home': (context) => const Home(),
        'game': (context) => const Game(),
        'menu': (context) => const Menu(),
      },
    );
  }
}
