import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/earth.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/planet/star.dart';
import 'package:app_planetarium/planet/sun.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// プラネタリウム全体を管理するメインウィジェット
class Planetarium extends StatefulWidget {
  const Planetarium({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  PlanetariumState createState() => PlanetariumState();
}

/// プラネタリウムの状態を管理するステートクラス
class PlanetariumState extends State<Planetarium> {
  Scene scene = Scene();
  List<Planet> planets = [];
  List<ShiningStar> shiningStars = [];
  bool loaded = false;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      // 惑星を作成してシーンに追加
      planets = [
        Sun(position: vm.Vector3(0, 0, 0)),
        Earth(position: vm.Vector3(0, -15, 0)),
      ];

      // 輝く星を作成してシーンに追加
      shiningStars = List.generate(
        100,
        (i) => ShiningStar(
          rotationSpeed: 0.005,
          position: vm.Vector3(0, -15, 0),
          node: ResourceCache.getModel(Models.starSunglasses),
        ),
      );

      scene.addAll(planets.map((p) => p.node));

      // ロード完了
      setState(() {
        debugPrint('Scene loaded.');
        loaded = true;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    scene.removeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // シーンの更新
    for (final p in planets) {
      p.update(widget.elapsedSeconds);
    }

    return SizedBox.expand(child: CustomPaint(painter: _ScenePainter(scene)));
  }

  vm.Vector3 _calculatePlanetPosition(double angle, double distance) {
    final x = distance * cos(angle);
    final z = distance * sin(angle);
    return vm.Vector3(x, 0, z);
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene);
  Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      // 少し引いた位置にカメラを配置
      position: vm.Vector3(0, 0, 30.0),
      // 太陽を中心に少し下を見る
      target: vm.Vector3(0, -5, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
