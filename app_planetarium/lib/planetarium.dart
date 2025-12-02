import 'package:app_planetarium/resource_cache.dart';
import 'package:app_planetarium/sun.dart';
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
  final SunModel sunModel = SunModel(vm.Vector3.zero());
  bool loaded = false;

  @override
  void initState() {
    // キャッシュを初期化
    ResourceCache.preloadAll().then((_) {
      scene.add(SunModel(vm.Vector3(0, 0, 0)).node);

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
      position: vm.Vector3(0, 0, 5.0),
      // 正面を見る
      target: vm.Vector3(0, 0, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
