import 'package:app_planetarium/random_universe.dart';
import 'package:app_planetarium/universe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum UniverseType { universe, randomUniverse }

/// アプリケーションのメインウィジェット
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// アプリケーションの状態を管理するクラス
/// Tickerを使用して経過時間を利用してアニメーションを実装
class _AppState extends State<App> {
  late Ticker ticker;
  double elapsedSeconds = 0;
  UniverseType _selectedUniverseType = UniverseType.universe;

  @override
  void initState() {
    ticker = Ticker((elapsed) {
      setState(() {
        elapsedSeconds = elapsed.inMilliseconds.toDouble() / 1000;
      });
    });
    ticker.start();

    super.initState();
  }

  Widget _buildUniverse() {
    switch (_selectedUniverseType) {
      case UniverseType.universe:
        return Universe(elapsedSeconds: elapsedSeconds);
      case UniverseType.randomUniverse:
        return RandomUniverse(elapsedSeconds: elapsedSeconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planetarium',
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Planetarium')),
        body: Stack(
          children: [
            _buildUniverse(),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: DropdownButton<UniverseType>(
                  value: _selectedUniverseType,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (UniverseType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedUniverseType = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: UniverseType.universe,
                      child: Text('Universe'),
                    ),
                    DropdownMenuItem(
                      value: UniverseType.randomUniverse,
                      child: Text('Random Universe'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
