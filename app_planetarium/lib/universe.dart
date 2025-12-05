import 'dart:math';

import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/earth.dart';
import 'package:app_planetarium/planet/jupiter.dart';
import 'package:app_planetarium/planet/mars.dart';
import 'package:app_planetarium/planet/mercury.dart';
import 'package:app_planetarium/planet/moon.dart';
import 'package:app_planetarium/planet/neptune.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/planet/saturn.dart';
import 'package:app_planetarium/planet/star.dart';
import 'package:app_planetarium/planet/sun.dart';
import 'package:app_planetarium/planet/uranus.dart';
import 'package:app_planetarium/planet/venus.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// プラネタリウム全体を管理するメインウィジェット
class Universe extends StatefulWidget {
  const Universe({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  UniverseState createState() => UniverseState();
}

/// プラネタリウムの状態を管理するステートクラス
class UniverseState extends State<Universe> {
  static const domeRadius = 50.0;

  Scene scene = Scene();
  List<Planet> planets = [];
  List<ShiningStar> shiningStars = [];
  bool loaded = false;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      // 惑星を作成してシーンに追加
      final sun = Sun(position: vm.Vector3(0, 0, 0));
      final earth = Earth();
      planets = [
        sun,
        Mercury(),
        Venus(),
        earth,
        Moon(earth: earth),
        Mars(),
        Jupiter(),
        Saturn(),
        Uranus(),
        Neptune(),
      ];

      // 輝く星を作成してシーンに追加
      final random = Random();
      const radius = 100.0;
      shiningStars = List.generate(100, (i) {
        // 球体内にランダムな座標を生成
        final r = radius * pow(random.nextDouble(), 1 / 3);
        final theta = acos(2 * random.nextDouble() - 1);
        final phi = 2 * pi * random.nextDouble();

        final x = r * sin(theta) * cos(phi);
        final y = r * sin(theta) * sin(phi);
        final z = r * cos(theta);

        // 0 ~ 2π (360度) の範囲でランダムな角度を作成
        final rotX = random.nextDouble() * 2 * pi;
        final rotY = random.nextDouble() * 2 * pi;
        final rotZ = random.nextDouble() * 2 * pi;

        return ShiningStar(
          position: vm.Vector3(x, y, z),
          model: Models.pentagram,
          rotationX: rotX,
          rotationY: rotY,
          rotationZ: rotZ,
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

    return SizedBox.expand(
      child: CustomPaint(painter: _ScenePainter(scene, widget.elapsedSeconds)),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.elapsedSeconds);

  Scene scene;
  final double elapsedSeconds;

  @override
  void paint(Canvas canvas, Size size) {
    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 300, 0),
      target: vm.Vector3(0, 0, 1),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
