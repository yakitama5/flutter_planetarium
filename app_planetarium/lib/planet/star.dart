import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

/// 輝く星を表す基底クラス
class ShiningStar {
  ShiningStar({
    required Models model,
    required Vector3 position,
    double rotationX = 0,
    double rotationY = 0,
    double rotationZ = 0,
  }) : node = ResourceCache.getModel(model)
         ..globalTransform =
             Matrix4.translation(position) *
             Matrix4.rotationX(rotationX) *
             Matrix4.rotationY(rotationY) *
             Matrix4.rotationZ(rotationZ);

  final Node node;
}
