import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// 惑星を表す基底クラス
abstract class Planet {
  Planet({
    required this.rotationSpeed,
    required this.position,
    required this.node,
  });

  final double rotationSpeed;
  final Node node;
  Vector3 position;
  double rotation = 0;

  void updateNode() {
    // 位置と回転を再設定し続ける
    node.globalTransform =
        Matrix4.translation(position) * Matrix4.rotationY(rotation);
  }

  bool update(double deltaSeconds) {
    // 一定速度で回転させる
    rotation += rotationSpeed;
    updateNode();
    return true;
  }
}
