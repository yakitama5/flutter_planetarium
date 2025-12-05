import 'dart:math';

import 'package:app_planetarium/behaviors/behavior.dart';
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

  /// ランダム配置の宇宙（公転なし）を構築する
  void _buildRandomUniverse() {
    final radius = 70.0;
    final random = Random();
    planets = [
      Sun(position: _randomPosition(random, radius)),
      Mercury(position: _randomPosition(random, radius)),
      Venus(position: _randomPosition(random, radius)),
      Earth(position: _randomPosition(random, radius)),
      Moon(position: _randomPosition(random, radius)),
      Mars(position: _randomPosition(random, radius)),
      Jupiter(position: _randomPosition(random, radius)),
      Saturn(position: _randomPosition(random, radius)),
      Uranus(position: _randomPosition(random, radius)),
      Neptune(position: _randomPosition(random, radius)),
    ];

    for (var planet in planets) {
      // ランダムな宇宙では自転だけさせる
      _behaviors[planet] = RotationBehavior(rotationSpeed: 0.05);
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
    const radius = 20.0;
    const speed = 0.5;
    final angle = elapsedSeconds * speed;

    // 1. カメラの現在位置
    final camX = 0.0; // くぐり抜けるならXはずらさず0の方が迫力が出ます
    final camY = radius * sin(angle);
    final camZ = radius * cos(angle);
    final currentPos = vm.Vector3(camX, camY, camZ);

    // 2. 「進行方向」のベクトル (接線)
    final forwardY = cos(angle);
    final forwardZ = -sin(angle);
    final forwardVector = vm.Vector3(0, forwardY, forwardZ);

    // 3. 「下方向（中心方向）」のベクトル
    final downY = -sin(angle);
    final downZ = -cos(angle);
    final downVector = vm.Vector3(0, downY, downZ);

    // 4. ターゲットの決定
    // 「進行方向」と「中心方向」を足して、斜め45度下（内側）を見る
    final lookDir = (forwardVector + downVector).normalized();
    final targetPos = currentPos + (lookDir * 50.0);

    // 【重要】カメラの上方向 (UPベクトル)
    // X軸固定をやめて、「中心から外側に向かうベクトル」をUPにします。
    // これで「足元が常に惑星側」「頭が宇宙の果て側」になり、ループしても自然な視点になります。
    // currentPos は (0,0,0) からのベクトルそのものなので、正規化するだけでOKです。
    final upVector = currentPos.normalized();

    // final camera = PerspectiveCamera(
    //   position: currentPos,
    //   target: targetPos,
    //   up: upVector, // ここを変更
    // );

    final camera = PerspectiveCamera(
      position: vm.Vector3(0, 0, 200),
      target: vm.Vector3(0, 0, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
