import 'dart:math';

import 'package:app_planetarium/behaviors/behavior.dart';
import 'package:app_planetarium/behaviors/composite_behavior.dart';
import 'package:app_planetarium/behaviors/orbit_behavior.dart';
import 'package:app_planetarium/behaviors/rotation_behavior.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// プラネタリウム全体を管理するメインウィジェット
class RandomUniverse extends StatefulWidget {
  const RandomUniverse({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  RandomUniverseState createState() => RandomUniverseState();
}

/// プラネタリウムの状態を管理するステートクラス
class RandomUniverseState extends State<RandomUniverse> {
  Scene scene = Scene();
  List<Planet> planets = [];
  final Map<Planet, Behavior> _behaviors = {};
  List<ShiningStar> shiningStars = [];
  bool loaded = false;
  final FocusNode _focusNode = FocusNode();

  // カメラ制御用の定数
  static const double _maxPitch = 89.0;
  static const double _minPitch = -89.0;
  static const double _cameraSpeed = 2.0;
  static const double _rotationSpeed = 1.0;
  static const double _maxDistance = 100.0;

  // カメラの状態
  vm.Vector3 _cameraPosition = vm.Vector3(0, 0, 200);
  double _cameraYaw = -90.0; // Z軸の負の方向を向くように初期化
  double _cameraPitch = 0.0;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      _buildRandomUniverse();

      // 輝く星を作成してシーンに追加
      final random = Random();
      const radius = 80.0;
      shiningStars = List.generate(500, (i) {
        // 球体内にランダムな座標を生成
        final r = radius * pow(random.nextDouble(), 1 / 3);
        final theta = acos(2 * random.nextDouble() - 1);
        final phi = 2 * pi * random.nextDouble();

        final x = r * sin(theta) * cos(phi);
        final y = r * sin(theta) * sin(phi);
        final z = r * cos(theta);

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
    _focusNode.dispose();
    super.dispose();
  }

  /// ランダム配置の宇宙（公転あり）を構築する
  void _buildRandomUniverse() {
    final random = Random();
    const radius = 70.0;
    Planet? earth;

    // 月以外の惑星を生成
    final planetConstructors = <Planet Function(vm.Vector3)>[
      (p) => Sun(position: p),
      (p) => Mercury(position: p),
      (p) => Venus(position: p),
      (p) => Earth(position: p),
      (p) => Mars(position: p),
      (p) => Jupiter(position: p),
      (p) => Saturn(position: p),
      (p) => Uranus(position: p),
      (p) => Neptune(position: p),
    ];

    for (final constructor in planetConstructors) {
      final tempPlanet = constructor(vm.Vector3.zero());
      final position =
          _findNonOverlappingPosition(random, radius, tempPlanet.radius, planets);
      final newPlanet = constructor(position);
      planets.add(newPlanet);

      if (newPlanet is Earth) {
        earth = newPlanet;
      }
    }

    // 地球が存在すれば、その周りを公転する月を追加
    if (earth != null) {
      const moonDistance = 5.0; // 地球と月の距離
      final moonPosition = earth.position + vm.Vector3(moonDistance, 0, 0);
      final moon = Moon(position: moonPosition);
      planets.add(moon);

      // 月の振る舞い：公転＋自転
      _behaviors[moon] = CompositeBehavior(behaviors: [
        OrbitBehavior(
          center: earth,
          distance: moonDistance,
          orbitalSpeed: 0.5,
        ),
        RotationBehavior(rotationSpeed: 0.01), // 月の自転は遅い
      ]);
    }

    // 各惑星（月以外）の振る舞い（自転）を設定
    for (var planet in planets) {
      if (!_behaviors.containsKey(planet)) {
        _behaviors[planet] = RotationBehavior(rotationSpeed: 0.05);
      }
    }
  }

  /// 他と重ならないランダムな位置を見つける
  vm.Vector3 _findNonOverlappingPosition(Random random, double maxDistance,
      double newPlanetRadius, List<Planet> existingPlanets) {
    while (true) {
      final position = _randomPosition(random, maxDistance);
      bool overlaps = false;
      for (final existingPlanet in existingPlanets) {
        final distance = position.distanceTo(existingPlanet.position);
        // 2つの惑星の半径の合計より距離が小さい場合は衝突
        if (distance < existingPlanet.radius + newPlanetRadius + 5.0) { // 5.0のマージン
          overlaps = true;
          break;
        }
      }
      if (!overlaps) {
        return position;
      }
    }
  }

  vm.Vector3 _randomPosition(Random random, double maxDistance) {
    final r = maxDistance * pow(random.nextDouble(), 1 / 3);
    final theta = acos(2 * random.nextDouble() - 1);
    final phi = 2 * pi * random.nextDouble();
    return vm.Vector3(
      r * sin(theta) * cos(phi),
      r * sin(theta) * sin(phi),
      r * cos(theta),
    );
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // 状態を更新
      setState(() {
        vm.Vector3 cameraFront = vm.Vector3(
          cos(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
          sin(vm.radians(_cameraPitch)),
          sin(vm.radians(_cameraYaw)) * cos(vm.radians(_cameraPitch)),
        ).normalized();

        switch (event.logicalKey) {
          case LogicalKeyboardKey.keyW:
          case LogicalKeyboardKey.arrowUp:
            _cameraPitch += _rotationSpeed;
            if (_cameraPitch > _maxPitch) _cameraPitch = _maxPitch;
            break;
          case LogicalKeyboardKey.keyS:
          case LogicalKeyboardKey.arrowDown:
            _cameraPitch -= _rotationSpeed;
            if (_cameraPitch < _minPitch) _cameraPitch = _minPitch;
            break;
          case LogicalKeyboardKey.keyA:
          case LogicalKeyboardKey.arrowLeft:
            _cameraYaw -= _rotationSpeed;
            break;
          case LogicalKeyboardKey.keyD:
          case LogicalKeyboardKey.arrowRight:
            _cameraYaw += _rotationSpeed;
            break;
          case LogicalKeyboardKey.space:
            final newPosition = _cameraPosition + cameraFront * _cameraSpeed;
            if (newPosition.length < _maxDistance) {
              _cameraPosition = newPosition;
            }
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // シーンの更新
    for (final p in planets) {
      // 振る舞いを適用
      _behaviors[p]?.update(p, widget.elapsedSeconds);
      // ノードを更新
      p.updateNode();
    }
    // フォーカスを要求する
    FocusScope.of(context).requestFocus(_focusNode);

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: SizedBox.expand(
        child: CustomPaint(
            painter: _ScenePainter(
          scene: scene,
          cameraPosition: _cameraPosition,
          cameraYaw: _cameraYaw,
          cameraPitch: _cameraPitch,
        )),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.scene,
    required this.cameraPosition,
    required this.cameraYaw,
    required this.cameraPitch,
  });

  final Scene scene;
  final vm.Vector3 cameraPosition;
  final double cameraYaw;
  final double cameraPitch;

  @override
  void paint(Canvas canvas, Size size) {
    // カメラの向きから前面ベクトルを計算
    final cameraFront = vm.Vector3(
      cos(vm.radians(cameraYaw)) * cos(vm.radians(cameraPitch)),
      sin(vm.radians(cameraPitch)),
      sin(vm.radians(cameraYaw)) * cos(vm.radians(cameraPitch)),
    ).normalized();

    // カメラのターゲット位置
    final cameraTarget = cameraPosition + cameraFront;

    // カメラの上方向ベクトルを計算（ジンバルロック対策）
    final right = vm.Vector3(0, 1, 0).cross(cameraFront).normalized();
    final cameraUp = cameraFront.cross(right).normalized();

    final camera = PerspectiveCamera(
      position: cameraPosition,
      target: cameraTarget,
      up: cameraUp,
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}