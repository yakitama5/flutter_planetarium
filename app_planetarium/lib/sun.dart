import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

class ExampleSun extends StatefulWidget {
  const ExampleSun({super.key, this.elapsedSeconds = 0});
  final double elapsedSeconds;

  @override
  ExampleSunState createState() => ExampleSunState();
}

class NodeState {
  NodeState(this.node, this.startTransform);

  Node node;
  vm.Matrix4 startTransform;
  double amount = 0;
}

class ExampleSunState extends State<ExampleSun> {
  Scene scene = Scene();
  bool loaded = false;

  double wheelRotation = 0;

  Map<String, NodeState> nodes = {};

  @override
  void initState() {
    // 太陽を上に配置 (Y軸を +10 ずらす)
    final sunModel = Node.fromAsset('build/models/sun.model').then((value) {
      value.name = 'Sun';
      // ↓↓↓ ここを追加 ↓↓↓
      // Matrix4.translation(x, y, z) で位置を指定します
      value.localTransform = vm.Matrix4.translation(vm.Vector3(0.0, 10.0, 0.0));
      // ↑↑↑ ここまで ↑↑↑

      scene.add(value);
      debugPrint('Model loaded: ${value.name}');
    });

    // 地球を下に配置 (Y軸を -10 ずらす)
    final earthModel = Node.fromAsset('build/models/sun.model').then((value) {
      value.name = 'Earth';
      value.localTransform = vm.Matrix4.translation(vm.Vector3(0.0, -10, 0.0));

      scene.add(value);
      debugPrint('Model loaded: ${value.name}');
    });

    Future.wait([sunModel, earthModel]).then((_) {
      debugPrint('Scene loaded.');
      setState(() {
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

    return SizedBox.expand(
      child: CustomPaint(painter: _ScenePainter(scene, widget.elapsedSeconds)),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.elapsedTime);
  Scene scene;
  double elapsedTime;

  @override
  void paint(Canvas canvas, Size size) {
    double rotationAmount = elapsedTime * 0.2;
    final camera = PerspectiveCamera(
      position:
          vm.Vector3(sin(rotationAmount) * 10, 0, cos(rotationAmount) * 10) * 2,
      target: vm.Vector3(0, 0, 0),
    );

    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
