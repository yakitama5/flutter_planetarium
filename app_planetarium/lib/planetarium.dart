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

const modelCheck = false;

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
      if (modelCheck) {
        // モデル確認用シーンを作成
        shiningStars = [
          ShiningStar(
            rotationSpeed: 0.005,
            position: vm.Vector3(0, 0, 4),
            node: ResourceCache.getModel(Models.pentagram),
          ),
        ];
        scene.add(shiningStars.first.node);

        // ロード完了
        setState(() {
          debugPrint('Scene loaded.');
          loaded = true;
        });
        return;
      }

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
          node: ResourceCache.getModel(Models.pentagram),
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
    for (final s in shiningStars) {
      s.update(widget.elapsedSeconds);
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
    if (modelCheck) {
      final camera = PerspectiveCamera(
        position: vm.Vector3(0, 0, 5.0),
        target: vm.Vector3(0, 0, 0),
      );

      scene.render(camera, canvas, viewport: Offset.zero & size);

      return;
    }

    // 1. 半径の設定
    // 宇宙全体が見えるように、少し距離を離しました (50 -> 80)
    const radius = 80.0;

    // 2. 回転速度の設定
    const speed = 0.5;

    // 3. 現在の角度を計算
    final angle = elapsedSeconds * speed;

    // 4. 座標変換 (YZ軸周りの回転に変更)
    // X: 固定 (少し横にずらすと立体感が出ます)
    // Y: sinで高さが変化
    // Z: cosで奥行きが変化
    final x = 10.0;
    final y = radius * sin(angle);
    final z = radius * cos(angle);

    final camera = PerspectiveCamera(
      position: vm.Vector3(x, y, z),

      // 視点を「中心より少し下」に向けることで、カメラ自体は上向き（見下ろす形）になりやすくなります
      // 0, -20, 0 あたりを見ると、画面の上の方に星空が広がる構図になります
      target: vm.Vector3(0, -20, 0),

      // 【重要】YZ軌道（縦回転）の場合、カメラの「上」をX軸(1, 0, 0)にすると安定します。
      // 通常の(0, 1, 0)のままだと、カメラが真上や真下に来た時に画面がカクっと反転してしまいます。
      up: vm.Vector3(1, 0, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
