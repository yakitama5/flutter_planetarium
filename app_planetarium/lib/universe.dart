import 'package:app_planetarium/behaviors/behavior.dart';
import 'package:app_planetarium/behaviors/composite_behavior.dart';
import 'package:app_planetarium/behaviors/orbit_behavior.dart';
import 'package:app_planetarium/behaviors/rotation_behavior.dart';
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
  Scene scene = Scene();
  List<Planet> planets = [];
  final Map<Planet, Behavior> _behaviors = {};
  List<ShiningStar> shiningStars = [];
  bool loaded = false;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      // シーンを構築
      _buildSolarSystemUniverse();
      scene.addAll(planets.map((p) => p.node));

      // ロード完了
      setState(() {
        debugPrint('Scene loaded.');
        loaded = true;
      });
    });

    super.initState();
  }

  /// 太陽系（公転あり）を構築する
  void _buildSolarSystemUniverse() {
    final sun = Sun(position: vm.Vector3.zero());
    final earth = Earth(position: vm.Vector3(40, 0, 0));
    final moon = Moon(position: earth.position + vm.Vector3(8, 0, 0));

    planets = [
      sun,
      Mercury(position: vm.Vector3(20, 0, 0)),
      Venus(position: vm.Vector3(30, 0, 0)),
      earth,
      moon,
      Mars(position: vm.Vector3(50, 0, 0)),
      Jupiter(position: vm.Vector3(70, 0, 0)),
      Saturn(position: vm.Vector3(90, 0, 0)),
      Uranus(position: vm.Vector3(110, 0, 0)),
      Neptune(position: vm.Vector3(130, 0, 0)),
    ];

    _behaviors[sun] = RotationBehavior(rotationSpeed: 0.0005);
    _behaviors[planets[1]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.01),
        OrbitBehavior(distance: 20, orbitalSpeed: 0.8),
      ],
    );
    _behaviors[planets[2]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.005),
        OrbitBehavior(distance: 30, orbitalSpeed: 0.5),
      ],
    );
    _behaviors[earth] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.05),
        OrbitBehavior(distance: 40, orbitalSpeed: 0.2),
      ],
    );
    _behaviors[moon] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.01),
        OrbitBehavior(center: earth, distance: 8, orbitalSpeed: 1.0),
      ],
    );
    _behaviors[planets[5]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.04),
        OrbitBehavior(distance: 50, orbitalSpeed: 0.15),
      ],
    );
    _behaviors[planets[6]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.1),
        OrbitBehavior(distance: 70, orbitalSpeed: 0.08),
      ],
    );
    _behaviors[planets[7]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.09),
        OrbitBehavior(distance: 90, orbitalSpeed: 0.05),
      ],
    );
    _behaviors[planets[8]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.06),
        OrbitBehavior(distance: 110, orbitalSpeed: 0.03),
      ],
    );
    _behaviors[planets[9]] = CompositeBehavior(
      behaviors: [
        RotationBehavior(rotationSpeed: 0.05),
        OrbitBehavior(distance: 130, orbitalSpeed: 0.02),
      ],
    );
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
    // 月が地球の後に更新されるように順序を保証する
    final updateOrder = List<Planet>.from(planets);
    updateOrder.sort((a, b) {
      final aIsMoon =
          _behaviors[a] is CompositeBehavior &&
          (_behaviors[a] as CompositeBehavior).behaviors.any(
            (e) => e is OrbitBehavior && e.center != null,
          );
      final bIsMoon =
          _behaviors[b] is CompositeBehavior &&
          (_behaviors[b] as CompositeBehavior).behaviors.any(
            (e) => e is OrbitBehavior && e.center != null,
          );

      if (aIsMoon && !bIsMoon) {
        return 1;
      }
      if (!aIsMoon && bIsMoon) {
        return -1;
      }
      return 0;
    });

    for (final p in updateOrder) {
      // 振る舞いを適用
      _behaviors[p]?.update(p, widget.elapsedSeconds);
      // ノードを更新
      p.updateNode();
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
