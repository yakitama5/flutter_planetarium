import 'dart:math' as math;

import 'package:app_planetarium/math_utils.dart';
import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

class SunModel {
  static const kRestingHeight = 1.5;

  SunModel(this.position) {
    _node = ResourceCache.getModel(Models.sun).clone();
  }

  late final Node _node;

  Node get node => _node;

  Vector3 position;
  double rotation = 0;

  double scale = 0;

  Vector3 startDestroyPosition = Vector3.zero();
  double destroyAnimation = 0;

  void updateNode() {
    _node.globalTransform =
        Matrix4.translation(position) *
        Matrix4.rotationY(rotation) *
        math.min(1.0, 3 - 3 * destroyAnimation) *
        scale;
  }

  /// Returns false when the spike has completed the destruction animation.
  /// Returns true if the spike is still active and should continue being
  /// updated.
  bool update(double deltaSeconds) {
    scale = lerpDeltaTime(scale, 1, 0.02, deltaSeconds);
    rotation += deltaSeconds * 2;

    updateNode();

    return true;
  }
}
