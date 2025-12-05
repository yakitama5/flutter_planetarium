import 'package:app_planetarium/models.dart';
import 'package:app_planetarium/planet/planet.dart';
import 'package:app_planetarium/resource_cache.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// 太陽を表すクラス
class Sun extends Planet {
  /// 太陽の半径
  static const double radius = 13.0;

  Sun({required vm.Vector3 position})
      : super(position: position, node: ResourceCache.getModel(Models.sun));
}
