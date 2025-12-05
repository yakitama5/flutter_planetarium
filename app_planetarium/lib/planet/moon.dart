import 'dart:math';

import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/earth.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 月を表すクラス
class Moon extends Planet {
  Moon({required this.earth})
      : super(
          rotationSpeed: 0.01,
          node: ResourceCache.getModel(Models.moon),
          position: earth.position + vm.Vector3(distance, 0, 0),
        );

  final Earth earth;
  static const double distance = 8;
  static const double orbitalSpeed = 1.0;

  @override
  bool update(double elapsedSeconds) {
    final angle = elapsedSeconds * orbitalSpeed;
    // 地球の位置を基準に公転する
    position.x = earth.position.x + distance * cos(angle);
    position.y = earth.position.y; // Y座標を地球に合わせる
    position.z = earth.position.z + distance * sin(angle);
    return super.update(elapsedSeconds);
  }
}
