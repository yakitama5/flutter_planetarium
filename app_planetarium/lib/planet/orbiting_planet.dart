import 'dart:math';

import 'package:app_planetarium/planet/planet.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 公転する惑星を表す基底クラス
abstract class OrbitingPlanet extends Planet {
  OrbitingPlanet({
    required super.rotationSpeed,
    required super.node,
    required this.distance,
    required this.orbitalSpeed,
  }) : super(position: vm.Vector3(distance, 0, 0)); // 初期位置

  final double distance;
  final double orbitalSpeed;

  @override
  bool update(double elapsedSeconds) {
    final angle = elapsedSeconds * orbitalSpeed;
    position.x = distance * cos(angle);
    position.z = distance * sin(angle);
    // 基底クラスのupdateを呼び出して自転とノードの更新を行う
    return super.update(elapsedSeconds);
  }
}
