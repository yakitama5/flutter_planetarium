import 'dart:math';

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
  static const domeRadius = 100.0;

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
      final random = Random();
      shiningStars = List.generate(100, (i) {
        // 球体内にランダムな座標を生成
        final r = domeRadius * pow(random.nextDouble(), 1 / 3);
        final theta = acos(2 * random.nextDouble() - 1);
        final phi = 2 * pi * random.nextDouble();

        final x = r * sin(theta) * cos(phi);
        final y = r * sin(theta) * sin(phi);
        final z = r * cos(theta);

        return ShiningStar(
          rotationSpeed: 0.005,
          position: vm.Vector3(x, y, z),
          node: ResourceCache.getModel(Models.starSunglasses),
        );
      });

      scene.addAll(planets.map((p) => p.node));
      scene.addAll(shiningStars.map((s) => s.node));

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
    for (final s in shiningStars) {
      s.update(widget.elapsedSeconds);
    }

    return SizedBox.expand(child: CustomPaint(painter: _ScenePainter(scene)));
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene);
  Scene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      // 少し引いた位置にカメラを配置
      position: vm.Vector3(0, 0, 100.0),
      // 太陽を中心に少し下を見る
      target: vm.Vector3(0, 0, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
