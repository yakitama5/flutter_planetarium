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
class RandomUniverse extends StatefulWidget {
  const RandomUniverse({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  RandomUniverseState createState() => RandomUniverseState();
}

/// プラネタリウムの状態を管理するステートクラス
class RandomUniverseState extends State<RandomUniverse> {
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

    /// 輝く星の更新処理
    /// Notes: CPUゲキ重ポイント
    /// flutter_gpuでGPUインスタンシングに対応した書き方であれば、負荷が軽減可能？
    /// FlutterScene自体はまだGPUインスタンシングに対応していない？
    // for (final s in shiningStars) {
    //   s.update(widget.elapsedSeconds);
    // }

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

    final camera = PerspectiveCamera(
      position: currentPos,
      target: targetPos,
      up: upVector, // ここを変更
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
